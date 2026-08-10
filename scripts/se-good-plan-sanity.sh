#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[se-good-plan-sanity] checking product authority, decision delta, and pre-phase plan rebase controls"

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
    "artifact_plan": repo_root / "tests" / "se-good-plan" / "artifact-bundles" / "valid-topic" / "docs" / "releases" / "v1.2.3" / "account-locale" / "plan.md",
    "artifact_decisions": repo_root / "tests" / "se-good-plan" / "artifact-bundles" / "valid-topic" / "docs" / "releases" / "v1.2.3" / "account-locale" / "decisions.md",
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
combined = "\n".join([texts["skill"], texts["patterns"], texts["contract"]])
if len(texts["skill"].splitlines()) > 380:
    fail("SKILL.md must stay concise and below 380 lines")

for needle in [
    "Product Authority Source",
    "canonical PRD",
    "Confirmed Product Decisions",
    "Do not copy confirmed PRD decisions into `decisions.md`",
    "fallback `decisions.md`",
    "PROTECTED USER-AUTHORITY ARTIFACT",
    "Write Gate: Explicit user approval required",
    "Agent Self-Approval: Forbidden",
    "user-confirmed-direct:",
    "blocked-on-user-decision",
    "Product Decision Delta",
    "covered", "engineering-only", "provisional", "conflict",
    "Pre-Phase Plan Rebase Gate",
    "blocked-on-plan-approval",
    "user-approved-plan-direct:",
    "completed implementation + remaining plan",
    "Minimum Sufficient Pre-Investment Validation",
    "Evidence And Product Authority",
]:
    require(combined, needle, "core contract")

work_header = (
    "| ID | Objective | Change Axis | Change Location | Target Object | "
    "Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | "
    "Safe Stop / Rollback | Plan Status |"
)
decision_header = (
    "| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | "
    "Violation Signal | Confirmation | Status |"
)
for name in ["skill", "patterns", "exemplar", "artifact_plan"]:
    require(texts[name], work_header, name)
for name in ["skill", "patterns", "contract", "artifact_decisions"]:
    require(texts[name], decision_header, name)

for forbidden in [
    "Maintain Two Required Topic Artifacts",
    "A formal repository plan maintains exactly two required topic artifacts",
    "exactly two independent, cross-linked topic artifacts",
]:
    if forbidden in combined or forbidden in texts["agent"]:
        fail(f"obsolete duplicated-authority contract remains: {forbidden}")

for needle in [
    "protected product authority",
    "prefer an existing canonical PRD",
    "Never copy canonical PRD decisions into fallback authority",
    "Product Decision Delta",
    "Pre-Phase Plan Rebase Gate",
    "blocked-on-plan-approval",
    "explicit direct user approval",
]:
    require(texts["agent"], needle, "agents/openai.yaml")

for name in ["artifact_plan", "exemplar"]:
    require(texts[name], "## Execution Contract", name)
    require(texts[name], "Before every material phase", name)
    require(texts[name], "Pre-Phase Plan Rebase Gate", name)
if "## Design" not in texts["artifact_plan"] or "## Work Units" not in texts["artifact_plan"]:
    fail("valid fallback plan fixture lacks Design or Work Units")
if "#### Pre-Phase Plan Rebase Gate" not in texts["exemplar"]:
    fail("multi-phase exemplar lacks persisted per-Phase rebase gate")

print("[se-good-plan-sanity] static contract checks passed")
PY

python3 -m py_compile "$repo_root/scripts/se-good-plan-quality-sanity.py"
python3 -m py_compile "$repo_root/scripts/se-good-plan-decision-sanity.py"
python3 -m py_compile "$repo_root/scripts/se-good-plan-product-authority-sanity.py"
python3 -m py_compile "$repo_root/scripts/se-good-plan-phase-rebase-sanity.py"
python3 "$repo_root/scripts/se-good-plan-quality-sanity.py" "$repo_root"
python3 "$repo_root/scripts/se-good-plan-decision-sanity.py" "$repo_root"
python3 "$repo_root/scripts/se-good-plan-product-authority-sanity.py"
python3 "$repo_root/scripts/se-good-plan-phase-rebase-sanity.py" "$repo_root"
echo "[se-good-plan-sanity] se-good-plan sanity passed"
