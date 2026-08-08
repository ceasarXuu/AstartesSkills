#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[docs-manager-sanity] checking adaptive docs governance contract"

python3 - <<'PY' "$repo_root"
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
skill = (root / "skills/docs-manager/SKILL.md").read_text(encoding="utf-8")
agent = (root / "skills/docs-manager/agents/openai.yaml").read_text(encoding="utf-8")
reference = (root / "skills/docs-manager/references/version-doc-templates.md").read_text(encoding="utf-8")
validator = (root / "skills/docs-manager/scripts/validate_docs_manager.py").read_text(encoding="utf-8")

def require(text: str, needle: str, context: str) -> None:
    if needle not in text and re.sub(r"\s+", " ", needle) not in re.sub(r"\s+", " ", text):
        raise AssertionError(f"{context} missing: {needle}")

for needle in [
    "Authority Precedence",
    "specialized artifact-owner workflow",
    "Never restructure, rename, duplicate, or relocate",
    "Artifact Ownership",
    "Confirmed Product Decisions",
    "se-good-plan",
    "Minimum Necessary Change",
    "--profile version-trio",
]:
    require(skill, needle, "SKILL.md")

for forbidden in [
    "keep exactly the version trio",
    "Enforce no files directly under `docs/`",
    "Do not keep a global PRD when version PRDs are the source of truth",
]:
    if forbidden in skill:
        raise AssertionError(f"obsolete fixed-layout rule remains: {forbidden}")

require(agent, "preserving existing source-of-truth relationships", "agent prompt")
require(agent, "do not impose a fixed PRD or engineering-plan layout", "agent prompt")
require(reference, "Optional Version-Trio Layout Profile", "optional profile reference")
require(reference, "must not override specialized artifact-owner contracts", "optional profile reference")
require(validator, 'default="generic"', "validator")
require(validator, 'choices=("generic", "version-trio")', "validator")
print("[docs-manager-sanity] static contract passed")
PY

python3 -m py_compile "$repo_root/skills/docs-manager/scripts/validate_docs_manager.py"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/docs"
printf '# Root\n\n[Doc](docs/a.md)\n' > "$tmp/README.md"
printf '# A\n' > "$tmp/docs/a.md"
python3 "$repo_root/skills/docs-manager/scripts/validate_docs_manager.py" --repo-root "$tmp" >/dev/null

printf '# Root\n\n[Missing](docs/missing.md)\n' > "$tmp/README.md"
if python3 "$repo_root/skills/docs-manager/scripts/validate_docs_manager.py" --repo-root "$tmp" >/dev/null 2>&1; then
  echo "[docs-manager-sanity] ERROR: broken local link unexpectedly passed" >&2
  exit 1
fi

rm -rf "$tmp/docs"
mkdir -p "$tmp/docs/v1.2.3"
printf '# PRD\n' > "$tmp/docs/v1.2.3/prd.md"
printf '# Design\n' > "$tmp/docs/v1.2.3/technical-design.md"
printf '# Plan\n' > "$tmp/docs/v1.2.3/engineering-plan.md"
printf '# Root\n' > "$tmp/README.md"
python3 "$repo_root/skills/docs-manager/scripts/validate_docs_manager.py" --repo-root "$tmp" --profile version-trio >/dev/null

echo "[docs-manager-sanity] docs-manager sanity passed"
