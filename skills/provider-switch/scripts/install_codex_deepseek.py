#!/usr/bin/env python3
"""Install the Codex + DeepSeek Flash side-load without changing global auth."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
ASSETS = SKILL_ROOT / "assets"
SETUP_URL = "https://cdn.deepseek.com/api-docs/codex-deepseek-setup.sh"
PROFILE_NAME = "deepseek-flash"
CONFIG_NAME = f"{PROFILE_NAME}.config.toml"
CATALOG_NAME = "deepseek-models.json"
WRAPPER_NAME = "codex-ds-flash"
KEY_PLACEHOLDER = "<YOUR_DEEPSEEK_API_KEY>"
MINIMUM_CODEX_VERSION = (0, 144, 0)
START_MARKER = "cat > \"$TMP_MODELS\" <<'CODEX_MODELS_JSON'\n"
END_MARKER = "\nCODEX_MODELS_JSON\n"


class InstallError(RuntimeError):
    pass


def log(event: str, message: str) -> None:
    print(f"[provider-switch] {event} {message}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Install a temporary Codex profile for DeepSeek V4 Flash."
    )
    parser.add_argument("--codex-home", type=Path)
    parser.add_argument("--bin-dir", type=Path)
    parser.add_argument("--setup-script", type=Path)
    parser.add_argument("--codex-command", default="codex")
    parser.add_argument("--open-editor", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    return parser.parse_args()


def resolve_command(command: str) -> str:
    if os.sep in command:
        path = Path(command).expanduser()
        if path.is_file() and os.access(path, os.X_OK):
            return str(path)
        raise InstallError(f"Codex command is not executable: {path}")
    resolved = shutil.which(command)
    if not resolved:
        raise InstallError(f"Codex command is not available on PATH: {command}")
    return resolved


def check_codex(command: str) -> str:
    resolved = resolve_command(command)
    result = subprocess.run(
        [resolved, "--version"], capture_output=True, text=True, check=False
    )
    output = f"{result.stdout}\n{result.stderr}"
    match = re.search(r"(\d+)\.(\d+)\.(\d+)", output)
    if result.returncode != 0 or not match:
        raise InstallError(f"Could not read Codex version from: {resolved}")
    version = tuple(int(part) for part in match.groups())
    if version < MINIMUM_CODEX_VERSION:
        minimum = ".".join(str(part) for part in MINIMUM_CODEX_VERSION)
        raise InstallError(f"Codex {match.group(0)} is older than required {minimum}")
    log("validate", f"codex={match.group(0)} command={resolved}")
    return resolved


def read_setup_script(path: Path | None) -> str:
    if path:
        log("source", f"setup-script={path}")
        return path.read_text(encoding="utf-8")
    log("download", f"url={SETUP_URL}")
    request = urllib.request.Request(
        SETUP_URL, headers={"User-Agent": "AstartesSkills-provider-switch/1.0"}
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def extract_catalog(setup_script: str) -> str:
    start = setup_script.find(START_MARKER)
    end = setup_script.find(END_MARKER, start + len(START_MARKER))
    if start < 0 or end < 0:
        raise InstallError("Official setup script does not contain the models.json block")
    payload = setup_script[start + len(START_MARKER) : end].rstrip() + "\n"
    try:
        catalog = json.loads(payload)
    except json.JSONDecodeError as exc:
        raise InstallError(f"Official models.json is invalid: {exc}") from exc
    models = catalog.get("models")
    if not isinstance(models, list):
        raise InstallError("Official models.json has no models array")
    by_slug = {item.get("slug"): item for item in models if isinstance(item, dict)}
    for slug in ("deepseek-v4-flash", "deepseek-v4-pro"):
        if slug not in by_slug:
            raise InstallError(f"Official models.json is missing {slug}")
    flash = by_slug["deepseek-v4-flash"]
    if flash.get("context_window") != 1048576 or flash.get("shell_type") != "shell_command":
        raise InstallError("DeepSeek Flash metadata does not match the verified contract")
    log("validate", "catalog=valid models=deepseek-v4-flash,deepseek-v4-pro")
    return payload


def toml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def render_config(catalog_path: Path, existing: str | None) -> str:
    template = (ASSETS / "codex-deepseek-flash.config.toml").read_text(
        encoding="utf-8"
    )
    rendered = template.replace("__MODEL_CATALOG_PATH__", toml_string(str(catalog_path)))
    if not existing:
        return rendered
    match = re.search(
        r'(?m)^experimental_bearer_token\s*=\s*"([^"\n]*)"[ \t]*$', existing
    )
    if match and match.group(1) and match.group(1) != KEY_PLACEHOLDER:
        rendered = re.sub(
            r'(?m)^experimental_bearer_token\s*=.*$',
            match.group(0),
            rendered,
            count=1,
        )
        log("preserve", "credential=existing-provider-bearer")
    return rendered


class BackupStore:
    def __init__(self, codex_home: Path, dry_run: bool) -> None:
        timestamp = datetime.now().astimezone().strftime("%Y%m%d-%H%M%S-%f")
        self.path = codex_home / "provider-switch-backups" / timestamp
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


def maybe_open_editor(config_path: Path, requested: bool, dry_run: bool) -> None:
    if not requested:
        return
    editor = shutil.which("code")
    if not editor:
        log("warning", f"VS Code CLI not found; edit={config_path}")
        return
    log("editor", f"target={config_path}")
    if not dry_run:
        subprocess.Popen([editor, "--reuse-window", "--goto", f"{config_path}:13"])


def main() -> int:
    args = parse_args()
    try:
        check_codex(args.codex_command)
        configured_home = os.environ.get("CODEX_HOME") or "~/.codex"
        codex_home = (args.codex_home or Path(configured_home)).expanduser()
        bin_dir = (args.bin_dir or Path("~/.local/bin")).expanduser()
        config_path = codex_home / CONFIG_NAME
        catalog_path = codex_home / CATALOG_NAME
        wrapper_path = bin_dir / WRAPPER_NAME

        setup_script = read_setup_script(args.setup_script)
        catalog = extract_catalog(setup_script)
        existing_config = (
            config_path.read_text(encoding="utf-8") if config_path.exists() else None
        )
        config = render_config(catalog_path, existing_config)
        wrapper = (ASSETS / "codex-ds-flash").read_bytes()
        backup = BackupStore(codex_home, args.dry_run)

        install_bytes(
            catalog_path,
            catalog.encode("utf-8"),
            0o600,
            backup,
            "deepseek-models.json",
            args.dry_run,
        )
        install_bytes(
            config_path,
            config.encode("utf-8"),
            0o600,
            backup,
            "deepseek-flash.config.toml",
            args.dry_run,
        )
        install_bytes(
            wrapper_path,
            wrapper,
            0o755,
            backup,
            "codex-ds-flash",
            args.dry_run,
        )
        maybe_open_editor(config_path, args.open_editor, args.dry_run)
        log(
            "complete",
            f"command={wrapper_path} profile={PROFILE_NAME} dry_run={str(args.dry_run).lower()}",
        )
        if KEY_PLACEHOLDER in config:
            log("next", f"add-provider-key={config_path}")
        if backup.created:
            log("recovery", f"backup={backup.path}")
        return 0
    except (InstallError, OSError, urllib.error.URLError) as exc:
        log("ERROR", str(exc))
        return 1


if __name__ == "__main__":
    sys.exit(main())
