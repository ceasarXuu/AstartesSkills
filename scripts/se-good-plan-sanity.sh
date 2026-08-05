#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[se-good-plan-sanity] checking bounded-validation and evidence-reconciliation contract"

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
    "Prefer Minimum Necessary Construction", "Make Benefit And Side Effects Explicit",
    "Use Minimum Sufficient Pre-Investment Validation", "Evidence Supersedes The Plan",
    "cheapest credible evidence ladder", "what is intentionally not proven",
    "Validation is not a shadow implementation", "After every material phase",
    "Preserve old conclusions", "needs-revision", "direction-supported",
    "Prefer Concise Structure",
]:
    require(combined, needle, "core contract")

work_header = (
    "| ID | Objective | Change Axis | Change Location | Target Object | "
    "Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | "
    "Safe Stop / Rollback | Plan Status |"
)
validation_header = (
    "| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | "
    "Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |"
)
reconciliation_header = (
    "| Phase | New Evidence | Affected Assumption / Prior Conclusion | Conclusion Update | "
    "Downstream Plan Change | Plan Validity | Next Action |"
)
for name in ["skill", "patterns", "contract", "exemplar"]:
    require(texts[name], work_header, name)
    require(texts[name], validation_header, name)
for name in ["skill", "patterns", "contract"]:
    require(texts[name], reconciliation_header, name)

for needle in [
    "Minimum Sufficient Pre-Investment Validation Contract",
    "Evidence Supersedes Plan Contract", "Phase Reconciliation Contract",
    "Plan Revision Traceability Contract", "heavy, unbounded, production-polluting",
    "continuing unchanged when plan validity needs revision",
]:
    require(texts["contract"], needle, "source contract")

for forbidden in [
    "1. Metadata\n2. Background", "Each phase must include entry criteria",
    "#### Entry Criteria Checks", "Only `landed` means complete",
]:
    if forbidden in texts["skill"]:
        fail(f"oversized legacy template remains: {forbidden}")

for needle in [
    "minimum-sufficient pre-investment validation", "what remains unproven",
    "Do not turn validation into shadow implementation", "reconcile evidence after each material phase",
    "current verified facts outrank the old plan", "Keep the document concise",
]:
    require(texts["agent"], needle, "agents/openai.yaml")

print("[se-good-plan-sanity] static contract checks passed")
PY

python3 -m py_compile "$repo_root/scripts/se-good-plan-quality-sanity.py"
python3 "$repo_root/scripts/se-good-plan-quality-sanity.py" "$repo_root"
echo "[se-good-plan-sanity] se-good-plan sanity passed"
