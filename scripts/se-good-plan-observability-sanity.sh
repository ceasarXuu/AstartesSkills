#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[se-good-plan-observability-sanity] checking logging design contract"

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
    raise AssertionError(f"[se-good-plan-observability-sanity] ERROR: {message}")


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
    "Plans must include logging design for the affected change chain.",
    "key states, success signals, failure signals, and failure reasons",
    "Logging Design Contract",
    "Change-Chain Logging Matrix",
    "Logging And Observability Design",
    "trigger to side effect",
    "privacy, security, or cost reason",
]:
    require(combined, needle, "logging design contract")

for needle in [
    "| Change Link | Key State | Success Signal | Failure Signal | Failure Reason Field | Correlation / Trace Field | Log Level | Consumer |",
    "request_id / job_id / trace_id / entity_id",
    "error_code / reason / exception / validation_error",
    "where in the chain the state is emitted",
    "who consumes the signal during rollout, debugging, audit, or support",
    "Avoid sensitive data, secrets, raw tokens",
]:
    require(combined, needle, "change-chain logging matrix")

require_fixture(
    fixtures_dir / "logging-design-plan.md",
    [
        "Include a change-chain logging matrix",
        "Capture key states such as received, validated, queued, started",
        "Define success signals, failure signals, and structured failure reason fields",
        "Include correlation or trace fields",
        "Validate that logs, traces, metrics, or audit events can prove success",
    ],
    [
        "Say \"add logging\" without specifying chain links",
        "Log only the final result",
        "Treat metrics alone as sufficient",
        "Include sensitive payment details",
    ],
)
require_fixture(
    fixtures_dir / "performance-plan.md",
    [
        "Include logging or tracing for request ingress, bottleneck link",
    ],
    [
        "List latency metrics without a chain-state logging design.",
    ],
)
require_fixture(
    fixtures_dir / "devops-cicd-plan.md",
    [
        "Include pipeline logging for build, test, artifact, deploy",
    ],
    [
        "Treat pipeline logs as generic console output",
    ],
)

for needle in [
    "## Logging And Observability Design",
    "| Change Link | Key State | Success Signal | Failure Signal | Failure Reason Field | Correlation / Trace Field | Log Level | Consumer |",
    "| API ingress | received / rejected |",
    "| Compatibility route | old route / new route |",
    "| Rollback | rollback started / completed |",
    "Logs must show request state, selected route, fallback reason, rollback state",
]:
    require(exemplar, needle, "Full Plan exemplar logging design")

expect_failure(
    "logging contract disappears",
    lambda: require(
        skill.replace("Plans must include logging design for the affected change chain.", ""),
        "Plans must include logging design for the affected change chain.",
        "negative logging contract",
    ),
)
expect_failure(
    "logging matrix loses failure reason",
    lambda: require(
        patterns.replace("Failure Reason Field | Correlation", "Correlation"),
        "Failure Reason Field | Correlation",
        "negative logging matrix",
    ),
)

print("[se-good-plan-observability-sanity] logging design sanity passed")
PY
