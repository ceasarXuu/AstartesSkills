"""Official macOS Harness bundle discovery and a guarded headless overlay."""

from __future__ import annotations

import json
import os
import plistlib
import tempfile
from contextlib import contextmanager
from pathlib import Path


def discover(app_path: str | None = None) -> tuple[str, str] | None:
    if app_path:
        candidates = [Path(app_path).expanduser()]
    else:
        roots = [Path(os.environ.get("AGENT_COMMANDER_APPLICATIONS_DIR", "/Applications"))]
        if "AGENT_COMMANDER_APPLICATIONS_DIR" not in os.environ:
            roots.append(Path.home() / "Applications")
        candidates = [app for root in roots for app in sorted(root.glob("DeepSeek Harness*.app"))]
    for app in candidates:
        try:
            with (app / "Contents/Info.plist").open("rb") as source:
                info = plistlib.load(source)
            launcher = app / "Contents/Resources/runtime/cli/bin/dsh"
            version = info.get("CFBundleShortVersionString", "")
            if (info.get("CFBundleIdentifier") == "com.deepseek.dsh"
                    and isinstance(version, str) and version
                    and launcher.is_file() and os.access(launcher, os.X_OK)):
                return str(launcher.resolve()), version
        except (OSError, ValueError, plistlib.InvalidFileException):
            continue
    return None


@contextmanager
def readonly_patch():
    """The runner cannot mount until the monotonic read-only guard is provided."""
    guard = Path(__file__).with_name("dsh_readonly.mjs").resolve()
    rows = [
        {"id": "tools", "config": {"mode": "native"}},
        {"id": "sandbox-policy", "config": {"mode": "read-only"}},
        {"id": "permission", "config": {
            "defaultPreset": "read-only",
            "presets": {
                "read-only": {"sandbox": "read-only", "approval": "ask"},
                "workspace-write": {"sandbox": "workspace-write", "approval": "ask"},
                "danger-full-access": {"sandbox": "danger-full-access", "approval": "never"},
            },
        }},
        # Reuse the desktop's already configured credentials; never log in here.
        *[{"id": name, "disabled": False}
          for name in ("credentials", "authorization", "deepseek-account")],
        {"insert": [{"id": "commander-readonly", "name": str(guard)}]},
        {"id": "headless-runner", "inject": ["headlessStartup", "commanderReadOnly"]},
    ]
    with tempfile.TemporaryDirectory(prefix="agent-commander-dsh-") as directory:
        path = Path(directory) / "readonly.patch.json"
        path.write_text(json.dumps(rows), encoding="utf-8")
        yield str(path)


def parse_events(events):
    session_id = None
    summary = ""
    for event in events:
        if event.get("type") == "session" and isinstance(event.get("sessionId"), str):
            session_id = event["sessionId"]
        if event.get("type") == "final" and isinstance(event.get("text"), str):
            summary = event["text"]
    return session_id, summary
