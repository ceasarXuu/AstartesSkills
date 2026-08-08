#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[clear-prd-sanity] checking clarification and product-authority contract"

python3 - <<'PY' "$repo_root"
import json
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
skill_dir = repo_root / "skills" / "clear-prd"
paths = {
    "skill": skill_dir / "SKILL.md",
    "agent": skill_dir / "agents" / "openai.yaml",
    "manifest": skill_dir / "markets" / "openai-compatible.json",
    "fixture": skill_dir / "references" / "interaction-fixtures.md",
    "registry": repo_root / "registry" / "skills.json",
}

def fail(message: str) -> None:
    raise AssertionError(f"[clear-prd-sanity] ERROR: {message}")

def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing file: {path.relative_to(repo_root)}")
    return path.read_text(encoding="utf-8")

def require(text: str, needle: str, context: str) -> None:
    if needle not in text and re.sub(r"\s+", " ", needle) not in re.sub(r"\s+", " ", text):
        fail(f"{context} missing required text: {needle}")

texts = {name: read(path) for name, path in paths.items()}
skill = texts["skill"]
agent = texts["agent"]
fixture = texts["fixture"]
manifest = json.loads(texts["manifest"])
registry = json.loads(texts["registry"])
registry_skill = next((x for x in registry.get("skills", []) if x.get("id") == "clear-prd"), None)
if not registry_skill:
    fail("registry missing clear-prd")

if len(skill.splitlines()) > 500:
    fail("SKILL.md exceeds 500 lines")

for needle in [
    "name: clear-prd",
    "Preserve the repository's existing PRD convention",
    "explicit user-requested path",
    "fallback `prd/YYYY-MM-DD-<short-topic>.md`",
    "Product Authority Contract",
    "Confirmed Product Decisions",
    "PROTECTED USER-AUTHORITY SECTION",
    "Agent self-approval is forbidden",
    "user-confirmed-direct:",
    "Stable decision IDs use `PD1`",
    "Allowed statuses are `active` and `superseded`",
    "Downstream engineering artifacts should reference these decision IDs instead of copying",
    "Partial answers are acceptable",
    "Status: Draft",
    "Ready for implementation",
]:
    require(skill, needle, "SKILL.md")

header = "| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |"
require(skill, header, "protected decision table")

for forbidden in [
    "Create `prd/` when missing. If the default file already exists",
    "## 12. Clarification Decision Log",
]:
    if forbidden in skill:
        fail(f"obsolete PRD contract remains: {forbidden}")

for needle in [
    "Partial Reply Downshift",
    "Custom Answer Normalization",
    "Confirmed decisions:",
    "Exceptions:",
    "Open questions:",
]:
    require(fixture, needle, "interaction fixture")

for needle in [
    "display_name: Clear PRD",
    "canonical product authority",
    "stable PD IDs",
    "Agent inference and user silence are not approval",
]:
    require(agent, needle, "agents/openai.yaml")

if manifest.get("source", {}).get("path") != "skills/clear-prd":
    fail("manifest source path mismatch")
if manifest.get("release") != registry_skill.get("release"):
    fail("manifest and registry release metadata differ")

print("[clear-prd-sanity] clear-prd sanity passed")
PY
