#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[se-good-plan-sanity] checking concise executable-plan contract"

python3 - <<'PY' "$repo_root"
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
skill_dir = repo_root / "skills" / "se-good-plan"
skill_file = skill_dir / "SKILL.md"
patterns_file = skill_dir / "references" / "plan-patterns.md"
source_contract_file = skill_dir / "references" / "source-contract.md"
agent_file = skill_dir / "agents" / "openai.yaml"
exemplar_file = repo_root / "tests" / "se-good-plan" / "exemplars" / "full-plan-shape.md"


def fail(message: str) -> None:
    raise AssertionError(f"[se-good-plan-sanity] ERROR: {message}")


def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing file: {path.relative_to(repo_root)}")
    return path.read_text(encoding="utf-8")


def require(text: str, needle: str, context: str) -> None:
    normalized_text = re.sub(r"\s+", " ", text)
    normalized_needle = re.sub(r"\s+", " ", needle)
    if needle not in text and normalized_needle not in normalized_text:
        fail(f"{context} missing required text: {needle}")


skill = read(skill_file)
patterns = read(patterns_file)
source_contract = read(source_contract_file)
agent = read(agent_file)
exemplar = read(exemplar_file)
combined = "\n".join([skill, patterns, source_contract])

if len(skill.splitlines()) > 340:
    fail("SKILL.md must stay concise and below 340 lines")

for needle in [
    "Plans Must Be Executable",
    "Change location:",
    "Target object:",
    "Concrete action:",
    "Use The Smallest Closed-Loop Engineering Unit",
    "one primary engineering objective or invariant",
    "one primary change axis",
    "Separate Plan Authoring From Execution Tracking",
    "Keep Artifact And Code Status Models Separate",
    "Prefer Concise Structure Over Template Ceremony",
    "Plan Authoring",
    "Execution Tracking",
    "blocked-on-discovery",
    "runtime-verified",
]:
    require(combined, needle, "core contract")

work_unit_header = (
    "| ID | Objective | Change Axis | Change Location | Target Object | "
    "Concrete Action | Resulting Behavior | Verification | Safe Stop / Rollback | Plan Status |"
)
for text, context in [
    (skill, "SKILL.md"),
    (patterns, "plan-patterns.md"),
    (source_contract, "source-contract.md"),
    (exemplar, "full-plan-shape.md"),
]:
    require(text, work_unit_header, context)

for needle in [
    "planned",
    "blocked-on-discovery",
    "deferred",
    "not-started",
    "in-progress",
    "verified",
    "blocked",
    "failed",
    "rolled-back",
]:
    require(combined, needle, "state model")

for needle in [
    "Discovery and design artifacts use:",
    "Code-bearing implementation uses:",
    "Discovery inventories, design documents, decision records",
]:
    require(source_contract, needle, "artifact/code status contract")

for needle in [
    "vague actions without concrete engineering mechanics",
    "multiple primary change axes or actions in one unit",
    "execution-complete states in a Plan Authoring document",
    "production-code states applied to discovery or design artifacts",
]:
    require(source_contract, needle, "behavioral validation contract")

for forbidden in [
    "1. Metadata\n2. Background",
    "Each phase must include entry criteria, checks, tasks, deliverables",
    "#### Entry Criteria Checks",
    "#### Implementation Completeness Evidence",
    "#### Logging And Observability Design",
    "Only `landed` means complete",
]:
    if forbidden in skill:
        fail(f"SKILL.md still contains the oversized legacy template: {forbidden}")

for needle in [
    "concrete change location, target object, engineering action",
    "smallest closed-loop engineering units",
    "Plan Authoring mode",
    "discovery and design artifact states separate",
]:
    require(agent, needle, "agents/openai.yaml")

print("[se-good-plan-sanity] static contract checks passed")
PY

python3 -m py_compile "$repo_root/scripts/se-good-plan-quality-sanity.py"
python3 "$repo_root/scripts/se-good-plan-quality-sanity.py" "$repo_root"

echo "[se-good-plan-sanity] se-good-plan sanity passed"
