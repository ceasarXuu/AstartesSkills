#!/usr/bin/env python3
"""Validate Claude Code's DeepSeek settings against a local Anthropic mock."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any
from urllib.parse import parse_qs, urlsplit


DIAGNOSTIC_TOKEN = "provider-switch-local-mock-token"


def log(event: str, message: str) -> None:
    print(f"[provider-switch-mock] {event} {message}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run a no-network Claude Code request against a local mock."
    )
    parser.add_argument("--claude-command", default="claude")
    parser.add_argument(
        "--settings",
        type=Path,
        default=Path("~/.claude/provider-switch/deepseek.settings.json").expanduser(),
    )
    parser.add_argument(
        "--effort",
        choices=("low", "high", "max"),
        help="Override effort for this local request, matching Claude /effort levels.",
    )
    return parser.parse_args()


class Capture:
    request: dict[str, Any] | None = None
    authorization_present = False
    anthropic_beta = ""
    path: str | None = None
    response_model = "deepseek-v4-pro"


class Handler(BaseHTTPRequestHandler):
    server_version = "provider-switch-mock"

    def log_message(self, _format: str, *_args: object) -> None:
        return

    def do_POST(self) -> None:  # noqa: N802 - required by BaseHTTPRequestHandler
        length = int(self.headers.get("Content-Length", "0"))
        payload = self.rfile.read(length)
        Capture.path = self.path
        Capture.authorization_present = bool(
            self.headers.get("Authorization") or self.headers.get("X-Api-Key")
        )
        Capture.anthropic_beta = self.headers.get("Anthropic-Beta", "")
        try:
            Capture.request = json.loads(payload)
        except json.JSONDecodeError:
            self.send_error(400, "invalid JSON")
            return

        if Capture.request.get("stream"):
            self._send_stream()
        else:
            self._send_json()

    def _send_json(self) -> None:
        response = {
            "id": "msg_provider_switch_mock",
            "type": "message",
            "role": "assistant",
            "model": Capture.response_model,
            "content": [{"type": "text", "text": "MOCK_OK"}],
            "stop_reason": "end_turn",
            "stop_sequence": None,
            "usage": {"input_tokens": 1, "output_tokens": 1},
        }
        encoded = json.dumps(response).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def _send_stream(self) -> None:
        events = [
            (
                "message_start",
                {
                    "type": "message_start",
                    "message": {
                        "id": "msg_provider_switch_mock",
                        "type": "message",
                        "role": "assistant",
                        "model": Capture.response_model,
                        "content": [],
                        "stop_reason": None,
                        "stop_sequence": None,
                        "usage": {"input_tokens": 1, "output_tokens": 0},
                    },
                },
            ),
            (
                "content_block_start",
                {
                    "type": "content_block_start",
                    "index": 0,
                    "content_block": {"type": "text", "text": ""},
                },
            ),
            (
                "content_block_delta",
                {
                    "type": "content_block_delta",
                    "index": 0,
                    "delta": {"type": "text_delta", "text": "MOCK_OK"},
                },
            ),
            ("content_block_stop", {"type": "content_block_stop", "index": 0}),
            (
                "message_delta",
                {
                    "type": "message_delta",
                    "delta": {"stop_reason": "end_turn", "stop_sequence": None},
                    "usage": {"output_tokens": 1},
                },
            ),
            ("message_stop", {"type": "message_stop"}),
        ]
        body = "".join(
            f"event: {name}\ndata: {json.dumps(data)}\n\n" for name, data in events
        ).encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def load_mock_settings(source: Path, base_url: str) -> dict[str, Any]:
    data = json.loads(source.read_text(encoding="utf-8"))
    env = data.get("env")
    if not isinstance(env, dict):
        raise ValueError("settings have no env object")
    env["ANTHROPIC_BASE_URL"] = base_url
    env["ANTHROPIC_AUTH_TOKEN"] = DIAGNOSTIC_TOKEN
    return data


def main() -> int:
    args = parse_args()
    resolved = shutil.which(args.claude_command) if os.sep not in args.claude_command else args.claude_command
    if not resolved or not os.access(resolved, os.X_OK):
        log("ERROR", f"claude command is not executable: {args.claude_command}")
        return 1
    if not args.settings.is_file():
        log("ERROR", f"settings are missing: {args.settings}")
        return 1

    Capture.request = None
    Capture.authorization_present = False
    Capture.anthropic_beta = ""
    Capture.path = None
    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    port = server.server_address[1]
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        with tempfile.TemporaryDirectory(prefix="provider-switch-claude-mock-") as root:
            root_path = Path(root)
            settings_path = root_path / "settings.json"
            settings = load_mock_settings(
                args.settings, f"http://127.0.0.1:{port}/anthropic"
            )
            configured_model = str(settings["env"]["ANTHROPIC_MODEL"])
            expected_effort = args.effort or str(settings.get("effortLevel", "high"))
            expected_model = configured_model.removesuffix("[1m]")
            Capture.response_model = expected_model
            settings_path.write_text(
                json.dumps(settings, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )
            command = [
                resolved,
                "--settings",
                str(settings_path),
                "--safe-mode",
                "--print",
                "--tools",
                "",
                "--max-turns",
                "1",
                "--no-session-persistence",
            ]
            if args.effort:
                command.extend(["--effort", args.effort])
            command.append("Reply with exactly: MOCK_OK")
            result = subprocess.run(
                command,
                cwd=root_path,
                text=True,
                capture_output=True,
                timeout=45,
                check=False,
            )
    finally:
        server.shutdown()
        server.server_close()
        thread.join(timeout=5)

    request = Capture.request or {}
    prompt_dump = json.dumps(request.get("messages", []), ensure_ascii=False)
    parsed_path = urlsplit(Capture.path or "")
    beta_query = parse_qs(parsed_path.query).get("beta") == ["true"]
    extended_context = "context-1m" in Capture.anthropic_beta
    expected_extended_context = configured_model.endswith("[1m]")
    checks = {
        "exit-zero": result.returncode == 0,
        "response": "MOCK_OK" in result.stdout,
        "messages-path": parsed_path.path.endswith("/v1/messages"),
        "beta-query": beta_query,
        "extended-context": extended_context == expected_extended_context,
        "authorization": Capture.authorization_present,
        "model": request.get("model") == expected_model,
        "effort": request.get("output_config", {}).get("effort") == expected_effort,
        "prompt": "Reply with exactly: MOCK_OK" in prompt_dump,
    }
    for name, passed in checks.items():
        log("validate", f"check={name} passed={str(passed).lower()}")
    if not all(checks.values()):
        log(
            "diagnostic",
            f"request-path={Capture.path or '<missing>'} model={request.get('model', '<missing>')} effort={request.get('output_config', {}).get('effort', '<missing>')} anthropic-beta={Capture.anthropic_beta or '<missing>'}",
        )
        sanitized_stderr = result.stderr.replace(DIAGNOSTIC_TOKEN, "<redacted>")
        if sanitized_stderr:
            log("diagnostic", sanitized_stderr.strip()[:2000])
        return 1
    log(
        "complete",
        f"request=local-mock network=loopback credential=diagnostic model={expected_model} effort={expected_effort}",
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
