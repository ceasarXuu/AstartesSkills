#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[se-good-plan-sanity] checking decision-baseline and topic-artifact contract"

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
combined = "\n".join(texts.values())
if len(texts["skill"].splitlines()) > 380:
    fail("SKILL.md must stay concise and below 380 lines")

for needle in [
    "Maintain Two Required Topic Artifacts",
    "Use A Product Decision Baseline",
    "docs/releases/<confirmed-version>/<topic-slug>/",
    "decisions.md", "plan.md", "Only user-confirmed decisions may be `active`",
    "Must Do", "Must Not Do", "Violation Signal", "Confirmation",
    "`plan.md` contains both `## Design` and `## Work Units`",
    "Evidence supersedes stale technical planning",
    "cannot silently rewrite user intent",
    "Use Minimum Sufficient Pre-Investment Validation",
    "Evidence Supersedes The Plan", "Prefer Concise Structure",
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
    "| Phase | New Evidence | Affected Assumption / Prior Conclusion | "
    "Decision Baseline Impact | Conclusion Update | Downstream Plan Change | "
    "Plan Validity | Next Action |"
)
decision_header = (
    "| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | "
    "Violation Signal | Confirmation | Status |"
)
for name in ["skill", "patterns", "contract", "exemplar", "artifact_plan"]:
    require(texts[name], work_header, name)
for name in ["skill", "patterns", "contract", "exemplar"]:
    require(texts[name], validation_header, name)
for name in ["skill", "patterns", "contract"]:
    require(texts[name], reconciliation_header, name)
for name in ["skill", "patterns", "contract", "artifact_decisions"]:
    require(texts[name], decision_header, name)

for needle in [
    "Required Topic Artifact Contract", "Product Decision Baseline Contract",
    "Evidence And Decision Authority Contract",
    "missing `decisions.md` or `plan.md`",
    "active decision without user confirmation",
    "full product decision baseline must not be merged into `plan.md`",
]:
    require(texts["contract"], needle, "source contract")

for forbidden in [
    "1. Metadata\n2. Background", "Each phase must include entry criteria",
    "#### Entry Criteria Checks", "Only `landed` means complete",
    "docs/workstreams/<topic-slug>",
]:
    if forbidden in texts["skill"]:
        fail(f"oversized or obsolete contract remains: {forbidden}")

for needle in [
    "exactly two independent, cross-linked topic artifacts",
    "Only user-confirmed decisions may be active",
    "Verified evidence may revise the technical plan",
    "add fixed supporting artifacts beyond the required two",
]:
    require(texts["agent"], needle, "agents/openai.yaml")

if texts["artifact_plan"].count("# Product Decision Baseline") > 0:
    fail("valid plan fixture merged the decision baseline")
if "## Design" not in texts["artifact_plan"] or "## Work Units" not in texts["artifact_plan"]:
    fail("valid plan fixture lacks Design or Work Units")

print("[se-good-plan-sanity] static contract checks passed")
PY

python3 -m py_compile "$repo_root/scripts/se-good-plan-quality-sanity.py"
python3 "$repo_root/scripts/se-good-plan-quality-sanity.py" "$repo_root"
echo "[se-good-plan-sanity] se-good-plan sanity passed"
