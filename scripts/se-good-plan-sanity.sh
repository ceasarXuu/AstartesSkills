#!/usr/bin/env bash

set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[se-good-plan-sanity] checking protected product authority, bounded validation, and decision-delta controls"

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
    "Treat `decisions.md` As A Protected User-Authority Artifact",
    "Keep Unconfirmed Product Decisions In `plan.md`",
    "Materialize The Execution Contract In `plan.md`",
    "PROTECTED USER-AUTHORITY ARTIFACT",
    "Write Gate: Explicit user approval required",
    "Agent Self-Approval: Forbidden",
    "user-confirmed-direct:",
    "blocked-on-user-decision",
    "Product Decision Delta",
    "covered", "engineering-only", "provisional", "conflict",
    "not an unbounded rescan of the whole project",
    "Use Minimum Sufficient Pre-Investment Validation",
    "Evidence Supersedes The Technical Plan",
]:
    require(combined, needle, "core contract")

work_header = (
    "| ID | Objective | Change Axis | Change Location | Target Object | "
    "Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | "
    "Safe Stop / Rollback | Plan Status |"
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
delta_header = (
    "| Phase | Decision Surface | Implemented / Observed Semantics | "
    "Baseline Coverage | Classification | Required Action |"
)
for name in ["skill", "patterns", "contract", "exemplar", "artifact_plan"]:
    require(texts[name], work_header, name)
for name in ["skill", "patterns", "contract"]:
    require(texts[name], reconciliation_header, name)
    require(texts[name], delta_header, name)
for name in ["skill", "patterns", "contract", "artifact_decisions"]:
    require(texts[name], decision_header, name)

for needle in [
    "Protected Product Decision Baseline Contract",
    "Unconfirmed Product Decision Contract",
    "Plan Execution Contract",
    "Product Decision Delta Contract",
    "baseline row not backed by direct user confirmation",
    "material phase with no Product Decision Delta audit",
]:
    require(texts["contract"], needle, "source contract")

for forbidden in [
    "Product decisions: `proposed`",
    "Decision statuses are `proposed`",
    "Agent inference remains `proposed`",
    "docs/workstreams/<topic-slug>",
]:
    if forbidden in texts["skill"] or forbidden in texts["contract"]:
        fail(f"obsolete decision-authority contract remains: {forbidden}")

for needle in [
    "protected user-authority product baseline",
    "Agent self-approval is forbidden",
    "user silence are not approval",
    "Product Decision Delta",
    "provisional", "conflict",
    "no fixed artifacts beyond the required two",
]:
    require(texts["agent"], needle, "agents/openai.yaml")

for name in ["artifact_plan", "exemplar"]:
    require(texts[name], "## Execution Contract", name)
if "## Design" not in texts["artifact_plan"] or "## Work Units" not in texts["artifact_plan"]:
    fail("valid plan fixture lacks Design or Work Units")
if texts["artifact_plan"].count("# Product Decision Baseline") > 0:
    fail("valid plan fixture merged the decision baseline")

print("[se-good-plan-sanity] static contract checks passed")
PY

python3 -m py_compile "$repo_root/scripts/se-good-plan-quality-sanity.py"
python3 -m py_compile "$repo_root/scripts/se-good-plan-decision-sanity.py"
python3 "$repo_root/scripts/se-good-plan-quality-sanity.py" "$repo_root"
python3 "$repo_root/scripts/se-good-plan-decision-sanity.py" "$repo_root"
echo "[se-good-plan-sanity] se-good-plan sanity passed"
