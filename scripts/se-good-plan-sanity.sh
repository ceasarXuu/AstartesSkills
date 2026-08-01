#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[se-good-plan-sanity] checking minimum-construction and side-effect contract"

python3 - <<'PY' "$repo_root"
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
skill_dir = repo_root / "skills" / "se-good-plan"
files = {
    "skill": skill_dir / "SKILL.md",
    "patterns": skill_dir / "references" / "plan-patterns.md",
    "contract": skill_dir / "references" / "source-contract.md",
    "agent": skill_dir / "agents" / "openai.yaml",
    "exemplar": repo_root / "tests" / "se-good-plan" / "exemplars" / "full-plan-shape.md",
}

def fail(message):
    raise AssertionError(f"[se-good-plan-sanity] ERROR: {message}")

def read(path):
    if not path.is_file():
        fail(f"missing file: {path.relative_to(repo_root)}")
    return path.read_text(encoding="utf-8")

def require(text, needle, context):
    if needle not in text and re.sub(r"\s+", " ", needle) not in re.sub(r"\s+", " ", text):
        fail(f"{context} missing required text: {needle}")

texts = {name: read(path) for name, path in files.items()}
combined = "\n".join(texts.values())
if len(texts["skill"].splitlines()) > 380:
    fail("SKILL.md must stay concise and below 380 lines")

for needle in [
    "Plans Must Be Executable", "Use The Smallest Closed-Loop Engineering Unit",
    "Prefer Minimum Necessary Construction", "delete or simplify existing logic",
    "A possible future requirement is not sufficient evidence",
    "Make Every Unit's Benefit Understandable", "State Side Effects, Not Only Risks",
    "Complexity:", "Reach / cost:", "expected consequence or continuing obligation",
    "Cross-unit side effects", "Separate Plan Authoring From Execution Tracking",
    "Keep Artifact And Code Status Models Separate", "Prefer Concise Structure",
]:
    require(combined, needle, "core contract")

header = (
    "| ID | Objective | Change Axis | Change Location | Target Object | "
    "Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | "
    "Safe Stop / Rollback | Plan Status |"
)
for name in ["skill", "patterns", "contract", "exemplar"]:
    require(texts[name], header, name)

for needle in [
    "Minimum Necessary Construction Contract", "Side Effects Contract",
    "speculative construction without a current need",
    "missing/generic/incomplete Side Effects",
    "an abstraction around one current implementation without justification",
]:
    require(texts["contract"], needle, "source contract")

for forbidden in [
    "1. Metadata\n2. Background", "Each phase must include entry criteria",
    "#### Entry Criteria Checks", "Only `landed` means complete",
]:
    if forbidden in texts["skill"]:
        fail(f"oversized legacy template remains: {forbidden}")

for needle in [
    "Prefer deleting, changing, or reusing existing logic",
    "Side Effects must state both Complexity delta", "smallest closed-loop units",
    "Plan Authoring separate from Execution Tracking",
]:
    require(texts["agent"], needle, "agents/openai.yaml")

print("[se-good-plan-sanity] static contract checks passed")
PY

python3 -m py_compile "$repo_root/scripts/se-good-plan-quality-sanity.py"
python3 "$repo_root/scripts/se-good-plan-quality-sanity.py" "$repo_root"
echo "[se-good-plan-sanity] se-good-plan sanity passed"
