#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[se-good-plan-benefit-sanity] checking benefit validation contract"

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
    raise AssertionError(f"[se-good-plan-benefit-sanity] ERROR: {message}")


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
    "Plans must state expected benefits, not only planned work.",
    "correctness validation and benefit validation",
    "speed, accuracy, reliability, cost, conversion, or operational-toil",
    "Each material goal must include the expected benefit",
    "Benefit Validation Contract",
    "Benefit Validation Table",
    "Correctness tests answer",
    "Benefit tests answer",
    "Unknown baselines or targets must be marked `Unknown`",
]:
    require(combined, needle, "benefit validation contract")

for needle in [
    "| Benefit Hypothesis | Metric | Baseline | Target | Measurement Method | Data Source | Observation Window | Pass / Fail Threshold |",
    "| Correctness |",
    "| Benefit |",
    "baseline, target, measurement method, data source, observation window",
]:
    require(combined, needle, "benefit validation table")

require_fixture(
    fixtures_dir / "benefit-validation-plan.md",
    [
        "State expected benefits separately from implementation deliverables.",
        "Include correctness validation for regressions, compatibility, and data safety.",
        "Include benefit validation for accuracy lift and latency reduction.",
        "Require metric, baseline, target, measurement method, data source",
        "Mark baseline and target as Unknown",
    ],
    [
        "Treat unit and integration tests as sufficient acceptance.",
        "Claim a specific accuracy lift or latency reduction without baseline data.",
        "Describe only what will be built without stating expected benefit.",
    ],
)
require_fixture(
    fixtures_dir / "performance-plan.md",
    ["Include benefit validation for latency, throughput, cost, or resource usage."],
    ["Treat local unit tests as sufficient proof of performance improvement."],
)

for needle in [
    "## Benefit Validation Strategy",
    "| Benefit Hypothesis | Metric | Baseline | Target | Measurement Method | Data Source | Observation Window | Pass / Fail Threshold |",
    "| Correctness | Contract |",
    "| Benefit | Success rate |",
    "No claimed benefit until baseline and target are known",
]:
    require(exemplar, needle, "Full Plan exemplar benefit validation")

expect_failure(
    "benefit contract disappears",
    lambda: require(
        skill.replace("Plans must state expected benefits, not only planned work.", ""),
        "Plans must state expected benefits, not only planned work.",
        "negative benefit contract",
    ),
)
expect_failure(
    "benefit table loses data source",
    lambda: require(
        patterns.replace("Data Source | Observation Window", "Observation Window"),
        "Data Source | Observation Window",
        "negative benefit table",
    ),
)

print("[se-good-plan-benefit-sanity] benefit validation sanity passed")
PY
