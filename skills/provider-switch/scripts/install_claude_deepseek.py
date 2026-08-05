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
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
ASSETS = SKILL_ROOT / "assets"
KEY_PLACEHOLDER = "<YOUR_DEEPSEEK_API_KEY>"
MINIMUM_CLAUDE_VERSION = (2, 1, 218)
DEFAULT_PROFILE = "claude-code-deepseek"


@dataclass(frozen=True)
class Profile:
    id: str
    settings_asset: str
    settings_name: str
    backup_name: str
    wrapper_name: str
    model: str
    fast_model: str


PROFILES = {
    "claude-code-deepseek": Profile(
        id="claude-code-deepseek",
        settings_asset="claude-code-deepseek.settings.json",
        settings_name="deepseek.settings.json",
        backup_name="claude-deepseek.settings.json",
        wrapper_name="claude-ds",
        model="deepseek-v4-pro[1m]",
        fast_model="deepseek-v4-flash",
    ),
    "claude-code-deepseek-flash": Profile(
        id="claude-code-deepseek-flash",
        settings_asset="claude-code-deepseek-flash.settings.json",
        settings_name="deepseek-flash.settings.json",
        backup_name="claude-deepseek-flash.settings.json",
        wrapper_name="claude-ds-flash",
        model="deepseek-v4-flash",
        fast_model="deepseek-v4-flash",
    ),
}


class InstallError(RuntimeError):
    pass


def log(event: str, message: str) -> None:
    print(f"[provider-switch] {event} {message}")


def parse_args(default_profile: str) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Install a temporary Claude Code profile for DeepSeek."
    )
    parser.add_argument("--claude-home", type=Path)
    parser.add_argument("--bin-dir", type=Path)
    parser.add_argument("--claude-command", default="claude")
    parser.add_argument("--version-timeout", type=float, default=10.0)
    parser.add_argument("--verified-claude-version")
    parser.add_argument("--api-key-env", default="DEEPSEEK_API_KEY")
    parser.add_argument("--profile", choices=sorted(PROFILES), default=default_profile)
    editor_group = parser.add_mutually_exclusive_group()
    editor_group.add_argument("--open-editor", dest="open_editor", action="store_true")
    editor_group.add_argument(
        "--no-open-editor", dest="open_editor", action="store_false"
    )
    parser.set_defaults(open_editor=True)
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


def check_claude(
    command: str, timeout: float, verified_version: str | None = None
) -> str:
    if timeout <= 0:
        raise InstallError("Claude version timeout must be greater than zero")
    resolved = resolve_command(command)
    source = "provided" if verified_version else "command"
    result: subprocess.CompletedProcess[str] | None = None
    if verified_version:
        output = verified_version
    else:
        try:
            result = subprocess.run(
                [resolved, "--version"],
                capture_output=True,
                text=True,
                check=False,
                timeout=timeout,
            )
        except subprocess.TimeoutExpired as exc:
            raise InstallError(
                f"Claude version check timed out after {timeout:g}s"
            ) from exc
        output = f"{result.stdout}\n{result.stderr}"
    match = re.search(r"(\d+)\.(\d+)\.(\d+)", output)
    if (result is not None and result.returncode != 0) or not match:
        raise InstallError(f"Could not read Claude Code version from: {resolved}")
    version = tuple(int(part) for part in match.groups())
    if version < MINIMUM_CLAUDE_VERSION:
        minimum = ".".join(str(part) for part in MINIMUM_CLAUDE_VERSION)
        raise InstallError(f"Claude Code {match.group(0)} is older than verified {minimum}")
    log(
        "validate",
        f"claude={match.group(0)} command={resolved} version_source={source}",
    )
    return resolved


def load_template(profile: Profile) -> dict[str, object]:
    path = ASSETS / profile.settings_asset
    try:
        settings = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise InstallError(f"Bundled Claude settings are invalid: {exc}") from exc
    env = settings.get("env")
    if not isinstance(env, dict) or env.get("ANTHROPIC_AUTH_TOKEN") != KEY_PLACEHOLDER:
        raise InstallError("Bundled Claude settings violate the credential contract")
    return settings


def read_existing_key(path: Path, log_preserve: bool = True) -> str | None:
    if not path.exists():
        return None
    try:
        existing = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise InstallError(f"Existing Claude DeepSeek settings are invalid: {exc}") from exc
    env = existing.get("env")
    value = env.get("ANTHROPIC_AUTH_TOKEN") if isinstance(env, dict) else None
    if isinstance(value, str) and value and value != KEY_PLACEHOLDER:
        if log_preserve:
            log("preserve", "credential=existing-provider-token")
        return value
    return None


def render_settings(
    target: Path, claude_home: Path, api_key_env: str, profile: Profile
) -> bytes:
    settings = load_template(profile)
    env = settings["env"]
    assert isinstance(env, dict)
    credential = read_existing_key(target)
    if credential is None:
        for sibling in PROFILES.values():
            sibling_path = claude_home / "provider-switch" / sibling.settings_name
            if sibling.id == profile.id or not sibling_path.exists():
                continue
            credential = read_existing_key(sibling_path, log_preserve=False)
            if credential is not None:
                log("import", f"credential=sibling-profile profile={sibling.id}")
                break
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


def render_wrapper(settings_path: Path, profile: Profile) -> bytes:
    template = (ASSETS / "claude-ds").read_text(encoding="utf-8")
    rendered = template.replace(
        "__SETTINGS_PATH__", shlex.quote(str(settings_path))
    )
    rendered = rendered.replace("__MODEL__", profile.model)
    rendered = rendered.replace("__FAST_MODEL__", profile.fast_model)
    return rendered.encode()


def maybe_open_editor(settings_path: Path, requested: bool, dry_run: bool) -> None:
    if not requested:
        return
    command: list[str] | None = None
    opener = ""
    code = shutil.which("code")
    if code:
        command = [code, "--reuse-window", "--goto", f"{settings_path}:5"]
        opener = "code"
    elif sys.platform == "darwin" and shutil.which("open"):
        command = [shutil.which("open") or "open", str(settings_path)]
        opener = "open"
    elif shutil.which("xdg-open"):
        command = [shutil.which("xdg-open") or "xdg-open", str(settings_path)]
        opener = "xdg-open"
    if command is None:
        log("warning", f"no editor opener found; edit={settings_path}")
        return
    log("editor", f"target={settings_path} opener={opener}")
    if not dry_run:
        try:
            subprocess.Popen(command)
        except OSError as exc:
            log("warning", f"editor launch failed target={settings_path} error={exc}")


def main(default_profile: str = DEFAULT_PROFILE) -> int:
    args = parse_args(default_profile)
    try:
        check_claude(
            args.claude_command,
            args.version_timeout,
            args.verified_claude_version,
        )
        profile = PROFILES[args.profile]
        claude_home = (args.claude_home or Path("~/.claude")).expanduser()
        bin_dir = (args.bin_dir or Path("~/.local/bin")).expanduser()
        settings_path = claude_home / "provider-switch" / profile.settings_name
        wrapper_path = bin_dir / profile.wrapper_name
        settings = render_settings(
            settings_path, claude_home, args.api_key_env, profile
        )
        wrapper = render_wrapper(settings_path, profile)
        backup = BackupStore(claude_home, args.dry_run)

        install_bytes(
            settings_path,
            settings,
            0o600,
            backup,
            profile.backup_name,
            args.dry_run,
        )
        install_bytes(
            wrapper_path,
            wrapper,
            0o755,
            backup,
            profile.wrapper_name,
            args.dry_run,
        )
        needs_key = KEY_PLACEHOLDER.encode() in settings
        log(
            "complete",
            f"command={wrapper_path} profile={profile.id} dry_run={str(args.dry_run).lower()}",
        )
        if needs_key:
            log("next", f"add-provider-key={settings_path}")
        if backup.created:
            log("recovery", f"backup={backup.path}")
        maybe_open_editor(settings_path, args.open_editor and needs_key, args.dry_run)
        return 0
    except (InstallError, OSError) as exc:
        log("ERROR", str(exc))
        return 1


if __name__ == "__main__":
    sys.exit(main())
