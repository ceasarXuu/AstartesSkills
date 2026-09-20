#!/usr/bin/env python3
"""Run supported local coding agents through one read-only JSON contract."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, Callable


PROVIDERS = ("command-code", "claude-code", "opencode", "pi", "deepseek-harness")
EXECUTABLES = {
    "command-code": ("command-code", "cmdc"),
    "claude-code": ("claude",),
    "opencode": ("opencode",),
    "pi": ("pi",),
    "deepseek-harness": ("dsh",),
}
READ_ONLY_PREFIX = (
    "You are a read-only delegated agent. Do not create, edit, delete, rename, "
    "commit, or push files. Do not run commands that change repository or external "
    "state. Inspect the requested material and return evidence-backed findings only.\n\n"
)
STDERR_LIMIT = 4000


def provider_environment(provider: str) -> dict[str, str]:
    environment = os.environ.copy()
    if provider == "claude-code":
        environment["DISABLE_AUTOUPDATER"] = "1"
    return environment


def emit(payload: dict[str, Any], exit_code: int) -> int:
    print(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))
    return exit_code


def resolve_executable(provider: str) -> str | None:
    for candidate in EXECUTABLES[provider]:
        resolved = shutil.which(candidate)
        if resolved:
            return resolved
    return None


def resolve_check_command(
    provider: str,
) -> tuple[list[str] | None, str | None, str | None]:
    executable = resolve_executable(provider)
    if executable:
        return [executable], executable, None
    if provider == "deepseek-harness":
        npm = shutil.which("npm")
        if npm:
            return (
                [
                    npm,
                    "exec",
                    "--offline",
                    "--yes=false",
                    "--package=@deepseek-ai/dsh",
                    "--",
                    "dsh",
                ],
                npm,
                "npm-cache",
            )
    return None, None, None


def check_provider(provider: str) -> dict[str, Any]:
    command, executable, discovery = resolve_check_command(provider)
    result: dict[str, Any] = {
        "provider": provider,
        "available": command is not None,
        "executable": executable,
        "experimental": provider == "deepseek-harness",
    }
    if discovery:
        result["discovery"] = discovery
        result["command"] = command
    if command is None:
        result["candidates"] = list(EXECUTABLES[provider])
        return result

    version_args = command + ["--version"]
    if provider == "command-code":
        version_args.insert(1, "--no-auto-update")
    try:
        completed = subprocess.run(
            version_args,
            text=True,
            capture_output=True,
            timeout=3,
            env=provider_environment(provider),
        )
        if discovery == "npm-cache" and completed.returncode != 0:
            result["available"] = False
            result["version"] = None
            result["candidates"] = list(EXECUTABLES[provider])
            return result
        version_text = (completed.stdout or completed.stderr).strip().splitlines()
        result["version"] = version_text[0][:200] if version_text else None
    except (OSError, subprocess.TimeoutExpired):
        result["version"] = None
    return result


def build_command(
    provider: str,
    executable: str,
    prompt: str,
    cwd: str,
    session_id: str | None,
) -> list[str]:
    safe_prompt = READ_ONLY_PREFIX + prompt
    if provider == "command-code":
        command = [
            executable,
            "--no-auto-update",
            "-p",
            safe_prompt,
            "--output-format",
            "json",
        ]
        if session_id:
            command[3:3] = ["--resume", session_id]
        return command
    if provider == "claude-code":
        command = [
            executable,
            "-p",
            "--output-format",
            "json",
            "--permission-mode",
            "plan",
            "--tools",
            "Read,Glob,Grep",
        ]
        if session_id:
            command.extend(["--resume", session_id])
        command.append(safe_prompt)
        return command
    if provider == "opencode":
        command = [
            executable,
            "run",
            "--format",
            "json",
            "--dir",
            cwd,
            "--agent",
            "plan",
        ]
        if session_id:
            command.extend(["--session", session_id])
        command.append(safe_prompt)
        return command
    if provider == "pi":
        command = [
            executable,
            "--mode",
            "json",
            "--tools",
            "read,grep,find,ls",
            "-p",
        ]
        if session_id:
            command.extend(["--session", session_id])
        command.append(safe_prompt)
        return command
    raise ValueError(f"provider '{provider}' cannot be executed in v0.2.1")


def parse_json_lines(stdout: str) -> list[dict[str, Any]]:
    events: list[dict[str, Any]] = []
    for line in stdout.splitlines():
        try:
            value = json.loads(line)
        except json.JSONDecodeError:
            continue
        if isinstance(value, dict):
            events.append(value)
    return events


def parse_command_code(events: list[dict[str, Any]]) -> tuple[str | None, str]:
    for event in reversed(events):
        if event.get("type") == "result":
            return event.get("sessionId"), str(event.get("finalText") or "")
    return None, ""


def parse_claude_code(events: list[dict[str, Any]]) -> tuple[str | None, str]:
    for event in reversed(events):
        if event.get("type") == "result":
            return event.get("session_id"), str(event.get("result") or "")
    return None, ""


def parse_opencode(events: list[dict[str, Any]]) -> tuple[str | None, str]:
    session_id: str | None = None
    texts: list[str] = []
    for event in events:
        if isinstance(event.get("sessionID"), str):
            session_id = event["sessionID"]
        part = event.get("part")
        if (
            event.get("type") == "text"
            and isinstance(part, dict)
            and isinstance(part.get("text"), str)
        ):
            texts.append(part["text"])
    return session_id, "".join(texts)


def parse_pi(events: list[dict[str, Any]]) -> tuple[str | None, str]:
    session_id: str | None = None
    texts: list[str] = []
    for event in events:
        if event.get("type") == "session" and isinstance(event.get("id"), str):
            session_id = event["id"]
        update = event.get("assistantMessageEvent")
        if (
            event.get("type") == "message_update"
            and isinstance(update, dict)
            and update.get("type") == "text_delta"
            and isinstance(update.get("delta"), str)
        ):
            texts.append(update["delta"])
    return session_id, "".join(texts)


PARSERS: dict[str, Callable[[list[dict[str, Any]]], tuple[str | None, str]]] = {
    "command-code": parse_command_code,
    "claude-code": parse_claude_code,
    "opencode": parse_opencode,
    "pi": parse_pi,
}


def positive_integer(raw_value: str) -> int:
    value = int(raw_value)
    if value < 1:
        raise argparse.ArgumentTypeError("must be a positive integer")
    return value


def run_provider(args: argparse.Namespace) -> int:
    if args.provider == "deepseek-harness":
        return emit(
            {
                "provider": args.provider,
                "status": "unsupported",
                "session_ref": None,
                "summary": "",
                "error": (
                    "deepseek-harness execution is experimental and disabled in v0.2.1 "
                    "because its minimal SDK profile exposes a danger-full-access shell"
                ),
            },
            2,
        )

    executable = resolve_executable(args.provider)
    if executable is None:
        return emit(
            {
                "provider": args.provider,
                "status": "unavailable",
                "session_ref": None,
                "summary": "",
                "error": f"no supported executable found: {', '.join(EXECUTABLES[args.provider])}",
            },
            3,
        )

    cwd = Path(args.cwd).expanduser().resolve()
    if not cwd.is_dir():
        return emit(
            {
                "provider": args.provider,
                "status": "failed",
                "session_ref": None,
                "summary": "",
                "error": f"working directory does not exist: {cwd}",
            },
            2,
        )

    command = build_command(
        args.provider, executable, args.prompt, str(cwd), args.session_id
    )
    try:
        completed = subprocess.run(
            command,
            cwd=str(cwd),
            text=True,
            capture_output=True,
            timeout=args.timeout,
            env=provider_environment(args.provider),
        )
    except subprocess.TimeoutExpired as error:
        return emit(
            {
                "provider": args.provider,
                "status": "timeout",
                "session_ref": None,
                "summary": "",
                "error": f"provider exceeded {args.timeout} seconds",
                "stderr": (error.stderr or "")[-STDERR_LIMIT:],
            },
            4,
        )
    except OSError as error:
        return emit(
            {
                "provider": args.provider,
                "status": "failed",
                "session_ref": None,
                "summary": "",
                "error": str(error),
            },
            3,
        )

    events = parse_json_lines(completed.stdout)
    session_id, summary = PARSERS[args.provider](events)
    if completed.returncode != 0:
        status = "failed"
    elif summary:
        status = "completed"
    else:
        status = "partial"
    payload = {
        "provider": args.provider,
        "status": status,
        "session_ref": (
            {"provider": args.provider, "id": session_id} if session_id else None
        ),
        "summary": summary,
        "exit_code": completed.returncode,
        "stderr": completed.stderr[-STDERR_LIMIT:],
    }
    return emit(payload, 0 if status in {"completed", "partial"} else 5)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Delegate read-only tasks to supported local coding agents."
    )
    subparsers = parser.add_subparsers(dest="operation", required=True)

    check = subparsers.add_parser("check", help="Check provider availability")
    check.add_argument("--provider", choices=("all",) + PROVIDERS, default="all")

    for operation in ("run", "follow-up"):
        command = subparsers.add_parser(operation)
        command.add_argument("--provider", choices=PROVIDERS, required=True)
        command.add_argument("--cwd", required=True)
        command.add_argument("--prompt", required=True)
        command.add_argument("--timeout", type=positive_integer, default=300)
        if operation == "follow-up":
            command.add_argument("--session-id", required=True)
        else:
            command.add_argument("--session-id")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    if args.operation == "check":
        selected = PROVIDERS if args.provider == "all" else (args.provider,)
        return emit({"providers": [check_provider(item) for item in selected]}, 0)
    return run_provider(args)


if __name__ == "__main__":
    sys.exit(main())
