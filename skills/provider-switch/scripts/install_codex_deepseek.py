#!/usr/bin/env python3
"""Install a Codex + DeepSeek side-load without changing global auth."""

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
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
ASSETS = SKILL_ROOT / "assets"
SETUP_URL = "https://cdn.deepseek.com/api-docs/codex-deepseek-setup.sh"
CATALOG_NAME = "deepseek-models.json"
KEY_PLACEHOLDER = "<YOUR_DEEPSEEK_API_KEY>"
MINIMUM_CODEX_VERSION = (0, 144, 0)
DEFAULT_PROFILE = "codex-deepseek-flash"
START_MARKER = "cat > \"$TMP_MODELS\" <<'CODEX_MODELS_JSON'\n"
END_MARKER = "\nCODEX_MODELS_JSON\n"


@dataclass(frozen=True)
class Profile:
    id: str
    name: str
    config_asset: str
    config_name: str
    wrapper_asset: str
    wrapper_name: str
    model: str


PROFILES = {
    "codex-deepseek-flash": Profile(
        id="codex-deepseek-flash",
        name="deepseek-flash",
        config_asset="codex-deepseek-flash.config.toml",
        config_name="deepseek-flash.config.toml",
        wrapper_asset="codex-ds-flash",
        wrapper_name="codex-ds-flash",
        model="deepseek-v4-flash",
    ),
    "codex-deepseek-pro": Profile(
        id="codex-deepseek-pro",
        name="deepseek-pro",
        config_asset="codex-deepseek-pro.config.toml",
        config_name="deepseek-pro.config.toml",
        wrapper_asset="codex-ds-pro",
        wrapper_name="codex-ds-pro",
        model="deepseek-v4-pro",
    ),
}


class InstallError(RuntimeError):
    pass


def log(event: str, message: str) -> None:
    print(f"[provider-switch] {event} {message}")


def parse_args(default_profile: str) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Install a temporary Codex profile for DeepSeek V4."
    )
    parser.add_argument("--codex-home", type=Path)
    parser.add_argument("--bin-dir", type=Path)
    parser.add_argument("--setup-script", type=Path)
    parser.add_argument("--codex-command", default="codex")
    parser.add_argument("--profile", choices=sorted(PROFILES), default=default_profile)
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
    for slug in ("deepseek-v4-flash", "deepseek-v4-pro"):
        model = by_slug[slug]
        if model.get("context_window") != 1048576 or model.get("shell_type") != "shell_command":
            raise InstallError(f"{slug} metadata does not match the verified contract")
        levels = model.get("supported_reasoning_levels")
        efforts = (
            [level.get("effort") for level in levels if isinstance(level, dict)]
            if isinstance(levels, list)
            else []
        )
        if model.get("default_reasoning_level") != "high" or efforts != [
            "low",
            "high",
            "max",
        ]:
            raise InstallError(f"{slug} reasoning levels do not match low,high,max")
    log("validate", "catalog=valid models=deepseek-v4-flash,deepseek-v4-pro")
    return payload


def toml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def read_existing_key(text: str | None, log_preserve: bool = True) -> str | None:
    if not text:
        return None
    match = re.search(
        r'(?m)^experimental_bearer_token\s*=\s*"([^"\n]*)"[ \t]*$', text
    )
    if match and match.group(1) and match.group(1) != KEY_PLACEHOLDER:
        if log_preserve:
            log("preserve", "credential=existing-provider-bearer")
        return match.group(1)
    return None


def render_config(
    catalog_path: Path,
    existing: str | None,
    sibling_configs: list[Path],
    profile: Profile,
) -> str:
    template = (ASSETS / profile.config_asset).read_text(encoding="utf-8")
    rendered = template.replace("__MODEL_CATALOG_PATH__", toml_string(str(catalog_path)))
    credential = read_existing_key(existing)
    if credential is None:
        for sibling_path in sibling_configs:
            if not sibling_path.exists():
                continue
            credential = read_existing_key(
                sibling_path.read_text(encoding="utf-8"), log_preserve=False
            )
            if credential is not None:
                log("import", f"credential=sibling-profile target={sibling_path}")
                break
    if credential is not None:
        rendered = re.sub(
            r'(?m)^experimental_bearer_token\s*=.*$',
            f"experimental_bearer_token = {toml_string(credential)}",
            rendered,
            count=1,
        )
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


def main(default_profile: str = DEFAULT_PROFILE) -> int:
    args = parse_args(default_profile)
    try:
        check_codex(args.codex_command)
        profile = PROFILES[args.profile]
        configured_home = os.environ.get("CODEX_HOME") or "~/.codex"
        codex_home = (args.codex_home or Path(configured_home)).expanduser()
        bin_dir = (args.bin_dir or Path("~/.local/bin")).expanduser()
        config_path = codex_home / profile.config_name
        catalog_path = codex_home / CATALOG_NAME
        wrapper_path = bin_dir / profile.wrapper_name

        setup_script = read_setup_script(args.setup_script)
        catalog = extract_catalog(setup_script)
        existing_config = (
            config_path.read_text(encoding="utf-8") if config_path.exists() else None
        )
        sibling_configs = [
            codex_home / sibling.config_name
            for sibling in PROFILES.values()
            if sibling.id != profile.id
        ]
        config = render_config(catalog_path, existing_config, sibling_configs, profile)
        wrapper = (ASSETS / profile.wrapper_asset).read_bytes()
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
            profile.config_name,
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
        maybe_open_editor(
            config_path,
            args.open_editor and KEY_PLACEHOLDER in config,
            args.dry_run,
        )
        log(
            "complete",
            f"command={wrapper_path} profile={profile.name} model={profile.model} dry_run={str(args.dry_run).lower()}",
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
