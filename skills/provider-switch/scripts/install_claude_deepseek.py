#!/usr/bin/env python3
"""Install a Claude Code + DeepSeek side-load without changing global settings."""

from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
ASSETS = SKILL_ROOT / "assets"
SETTINGS_NAME = "deepseek.settings.json"
WRAPPER_NAME = "claude-ds"
KEY_PLACEHOLDER = "<YOUR_DEEPSEEK_API_KEY>"
MINIMUM_CLAUDE_VERSION = (2, 1, 218)


class InstallError(RuntimeError):
    pass


def log(event: str, message: str) -> None:
    print(f"[provider-switch] {event} {message}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Install a temporary Claude Code profile for DeepSeek."
    )
    parser.add_argument("--claude-home", type=Path)
    parser.add_argument("--bin-dir", type=Path)
    parser.add_argument("--claude-command", default="claude")
    parser.add_argument("--api-key-env", default="DEEPSEEK_API_KEY")
    parser.add_argument("--open-editor", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def resolve_command(command: str) -> str:
    if os.sep in command:
        path = Path(command).expanduser()
        if path.is_file() and os.access(path, os.X_OK):
            return str(path)
        raise InstallError(f"Claude command is not executable: {path}")
    resolved = shutil.which(command)
    if not resolved:
        raise InstallError(f"Claude command is not available on PATH: {command}")
    return resolved


def check_claude(command: str) -> str:
    resolved = resolve_command(command)
    result = subprocess.run(
        [resolved, "--version"], capture_output=True, text=True, check=False
    )
    output = f"{result.stdout}\n{result.stderr}"
    match = re.search(r"(\d+)\.(\d+)\.(\d+)", output)
    if result.returncode != 0 or not match:
        raise InstallError(f"Could not read Claude Code version from: {resolved}")
    version = tuple(int(part) for part in match.groups())
    if version < MINIMUM_CLAUDE_VERSION:
        minimum = ".".join(str(part) for part in MINIMUM_CLAUDE_VERSION)
        raise InstallError(f"Claude Code {match.group(0)} is older than verified {minimum}")
    log("validate", f"claude={match.group(0)} command={resolved}")
    return resolved


def load_template() -> dict[str, object]:
    path = ASSETS / "claude-code-deepseek.settings.json"
    try:
        settings = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise InstallError(f"Bundled Claude settings are invalid: {exc}") from exc
    env = settings.get("env")
    if not isinstance(env, dict) or env.get("ANTHROPIC_AUTH_TOKEN") != KEY_PLACEHOLDER:
        raise InstallError("Bundled Claude settings violate the credential contract")
    return settings


def read_existing_key(path: Path) -> str | None:
    if not path.exists():
        return None
    try:
        existing = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise InstallError(f"Existing Claude DeepSeek settings are invalid: {exc}") from exc
    env = existing.get("env")
    value = env.get("ANTHROPIC_AUTH_TOKEN") if isinstance(env, dict) else None
    if isinstance(value, str) and value and value != KEY_PLACEHOLDER:
        log("preserve", "credential=existing-provider-token")
        return value
    return None


def render_settings(target: Path, api_key_env: str) -> bytes:
    settings = load_template()
    env = settings["env"]
    assert isinstance(env, dict)
    credential = read_existing_key(target)
    if credential is None:
        candidate = os.environ.get(api_key_env)
        if candidate:
            credential = candidate
            log("import", f"credential=environment name={api_key_env}")
    if credential is not None:
        env["ANTHROPIC_AUTH_TOKEN"] = credential
    return (json.dumps(settings, ensure_ascii=False, indent=2) + "\n").encode()


class BackupStore:
    def __init__(self, claude_home: Path, dry_run: bool) -> None:
        timestamp = datetime.now().astimezone().strftime("%Y%m%d-%H%M%S-%f")
        self.path = claude_home / "provider-switch-backups" / timestamp
        self.dry_run = dry_run
        self.created = False

    def copy(self, source: Path, label: str) -> None:
        target = self.path / label
        log("backup", f"source={source} target={target}")
        if self.dry_run:
            return
        self.path.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
        self.created = True


def install_bytes(
    target: Path,
    content: bytes,
    mode: int,
    backup: BackupStore,
    label: str,
    dry_run: bool,
) -> str:
    if target.exists() and target.read_bytes() == content:
        log("unchanged", f"target={target}")
        if not dry_run:
            target.chmod(mode)
        return "unchanged"
    action = "update" if target.exists() else "create"
    if target.exists():
        backup.copy(target, label)
    log(action, f"target={target} mode={oct(mode)}")
    if dry_run:
        return action
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=target.parent, delete=False) as handle:
        temp_path = Path(handle.name)
        handle.write(content)
        handle.flush()
        os.fsync(handle.fileno())
    try:
        temp_path.chmod(mode)
        os.replace(temp_path, target)
    finally:
        if temp_path.exists():
            temp_path.unlink()
    return action


def render_wrapper(settings_path: Path) -> bytes:
    template = (ASSETS / "claude-ds").read_text(encoding="utf-8")
    return template.replace("__SETTINGS_PATH__", shlex.quote(str(settings_path))).encode()


def maybe_open_editor(settings_path: Path, requested: bool, dry_run: bool) -> None:
    if not requested:
        return
    editor = shutil.which("code")
    if not editor:
        log("warning", f"VS Code CLI not found; edit={settings_path}")
        return
    log("editor", f"target={settings_path}")
    if not dry_run:
        subprocess.Popen([editor, "--reuse-window", "--goto", f"{settings_path}:5"])


def main() -> int:
    args = parse_args()
    try:
        check_claude(args.claude_command)
        claude_home = (args.claude_home or Path("~/.claude")).expanduser()
        bin_dir = (args.bin_dir or Path("~/.local/bin")).expanduser()
        settings_path = claude_home / "provider-switch" / SETTINGS_NAME
        wrapper_path = bin_dir / WRAPPER_NAME
        settings = render_settings(settings_path, args.api_key_env)
        wrapper = render_wrapper(settings_path)
        backup = BackupStore(claude_home, args.dry_run)

        install_bytes(
            settings_path,
            settings,
            0o600,
            backup,
            "claude-deepseek.settings.json",
            args.dry_run,
        )
        install_bytes(
            wrapper_path,
            wrapper,
            0o755,
            backup,
            WRAPPER_NAME,
            args.dry_run,
        )
        maybe_open_editor(settings_path, args.open_editor, args.dry_run)
        log(
            "complete",
            f"command={wrapper_path} profile=claude-code-deepseek dry_run={str(args.dry_run).lower()}",
        )
        if KEY_PLACEHOLDER.encode() in settings:
            log("next", f"add-provider-key={settings_path}")
        if backup.created:
            log("recovery", f"backup={backup.path}")
        return 0
    except (InstallError, OSError) as exc:
        log("ERROR", str(exc))
        return 1


if __name__ == "__main__":
    sys.exit(main())
