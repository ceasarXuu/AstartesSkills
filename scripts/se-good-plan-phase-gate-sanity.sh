#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[se-good-plan-phase-gate-sanity] checking strict phase gate contract"

python3 - <<'PY' "$repo_root"
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
skill_dir = repo_root / "skills" / "se-good-plan"
skill_file = skill_dir / "SKILL.md"
patterns_file = skill_dir / "references" / "plan-patterns.md"
source_contract_file = skill_dir / "references" / "source-contract.md"
fixtures_dir = repo_root / "tests" / "se-good-plan" / "fixtures"
exemplar_file = repo_root / "tests" / "se-good-plan" / "exemplars" / "full-plan-shape.md"


def fail(message: str) -> None:
    raise AssertionError(f"[se-good-plan-phase-gate-sanity] ERROR: {message}")


def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing file: {path.relative_to(repo_root)}")
    return path.read_text(encoding="utf-8")


def require(text: str, needle: str, context: str) -> None:
    normalized_text = re.sub(r"\s+", " ", text)
    normalized_needle = re.sub(r"\s+", " ", needle)
    if needle not in text and normalized_needle not in normalized_text:
        fail(f"{context} missing required text: {needle}")


def section(source: str, heading: str) -> str:
    match = re.search(rf"(?ms)^## {re.escape(heading)}\n(?P<body>.*?)(?=^## |\Z)", source)
    if not match:
        fail(f"missing section: {heading}")
    return match.group("body")


def require_fixture(path: Path, expected: list[str], forbidden: list[str]) -> None:
    text = read(path)
    expected_body = section(text, "Expected Behavior")
    forbidden_body = section(text, "Forbidden Behavior")
    for needle in expected:
        require(expected_body, needle, f"{path.name} expected behavior")
    for needle in forbidden:
        require(forbidden_body, needle, f"{path.name} forbidden behavior")
    for needle in forbidden:
        if needle in expected_body:
            fail(f"{path.name} expected behavior contains forbidden behavior: {needle}")


def expect_failure(description: str, check) -> None:
    try:
        check()
    except AssertionError:
        return
    fail(f"negative fixture did not fail: {description}")


skill = read(skill_file)
patterns = read(patterns_file)
source_contract = read(source_contract_file)
exemplar = read(exemplar_file)
combined = "\n".join([skill, patterns, source_contract])

for needle in [
    "Each phase must be independently verifiable.",
    "A phase cannot require a later phase to prove its own exit criteria",
    "Do not proceed to the next phase unless the current phase is 100% complete",
    "Phase Dependency And Gate Matrix",
    "Phase boundaries must be strict.",
    "The default decision for an incomplete, blocked, ambiguous, or future-dependent phase is `pause`.",
]:
    require(combined, needle, "phase gate contract")

for needle in [
    "| Phase | Independent Verification | Forbidden Future Dependency | Exit Evidence | Completion Required Before Next Phase | Proceed Decision |",
    "| Gate Condition | Verification Evidence | Completion Status | User Approval Required | Proceed Decision |",
    "100% complete or explicit user approval with recorded residual risk",
    "proceed / pause",
]:
    require(combined, needle, "phase gate tables")

require_fixture(
    fixtures_dir / "phase-gate-plan.md",
    [
        "Reject the inverted dependency where Phase 2 can only close after Phase 3.",
        "Require every phase to be independently verifiable before the next phase starts.",
        "Require 100% phase completion before proceeding",
        "Record missing evidence, residual risk, user approval status, and a proceed or pause decision",
        "Prefer pausing over continuing",
    ],
    [
        "Allow Phase 2 to close based on Phase 3 UI validation.",
        "Continue to Phase 3 when Phase 2 lacks local test",
        "Treat partial completion, future validation, or assumed follow-up work as a completed phase gate.",
        "Proceed without explicit user approval when residual risk remains.",
    ],
)

for needle in [
    "## Phase Gate Overview",
    "| Phase | Independent Verification | Forbidden Future Dependency | Exit Evidence | Completion Required Before Next Phase | Proceed Decision |",
    "| Phase 0 | API inventory and caller evidence available in Discovery |",
    "| Phase 1 | Target design review and compatibility evidence available before implementation |",
    "| Gate Condition | Verification Evidence | Completion Status | User Approval Required | Proceed Decision |",
    "No future-phase dependency closes Phase 0",
]:
    require(exemplar, needle, "Full Plan exemplar phase gates")

expect_failure(
    "independent phase contract disappears",
    lambda: require(
        skill.replace("Each phase must be independently verifiable.", ""),
        "Each phase must be independently verifiable.",
        "negative phase contract",
    ),
)
expect_failure(
    "phase gate matrix loses future-dependency column",
    lambda: require(
        patterns.replace("Forbidden Future Dependency | Exit Evidence", "Exit Evidence"),
        "Forbidden Future Dependency | Exit Evidence",
        "negative phase gate matrix",
    ),
)

print("[se-good-plan-phase-gate-sanity] strict phase gate sanity passed")
PY
