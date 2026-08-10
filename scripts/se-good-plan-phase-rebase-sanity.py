#!/usr/bin/env python3
"""Validate durable pre-phase plan rebase gates for se-good-plan."""

from __future__ import annotations

import re
import sys
from pathlib import Path

GATE_STATES = {"pending", "ready", "blocked-on-plan-approval"}
PLAN_DELTA_VALUES = {"pending", "none", "material"}
PLAN_DELTA_HEADER = [
    "ID", "Before Phase", "Previous Plan", "Current Fact", "Proposed Change",
    "Impact", "User Approval", "Status",
]


class PhaseRebaseError(AssertionError):
    pass


def split_row(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def field(block: str, label: str) -> str:
    match = re.search(rf"(?mi)^- {re.escape(label)}:\s*(.*?)\s*$", block)
    if not match:
        raise PhaseRebaseError(f"Pre-Phase Plan Rebase Gate missing field: {label}")
    return match.group(1).strip()


def expected_error(path: Path) -> str:
    match = re.search(r"<!--\s*expected-error:\s*(.*?)\s*-->", path.read_text(encoding="utf-8"))
    if not match:
        raise AssertionError(f"missing expected-error marker: {path}")
    return match.group(1)


def execution_contract(text: str) -> str:
    match = re.search(r"(?ms)^## Execution Contract\s*$\n(?P<body>.*?)(?=^## |\Z)", text)
    if not match:
        raise PhaseRebaseError("plan.md must persist the Execution Contract")
    body = match.group("body")
    for needle in [
        "before every material phase",
        "Pre-Phase Plan Rebase Gate",
        "Material Plan Delta",
        "user approval",
    ]:
        if needle.lower() not in body.lower():
            raise PhaseRebaseError(f"Execution Contract missing pre-phase rebase rule: {needle}")
    return body


def phase_blocks(text: str) -> list[tuple[str, str]]:
    match = re.search(r"(?ms)^## Phases\s*$\n(?P<body>.*?)(?=^## |\Z)", text)
    if not match:
        return []
    body = match.group("body")
    matches = list(re.finditer(r"(?m)^### (Phase\s+[^\n]+)\s*$", body))
    blocks: list[tuple[str, str]] = []
    for index, item in enumerate(matches):
        start = item.end()
        end = matches[index + 1].start() if index + 1 < len(matches) else len(body)
        blocks.append((item.group(1), body[start:end]))
    return blocks


def plan_delta_rows(text: str) -> dict[str, list[str]]:
    match = re.search(r"(?ms)^## Plan Delta History\s*$\n(?P<body>.*?)(?=^## |\Z)", text)
    if not match:
        return {}
    lines = [line for line in match.group("body").splitlines() if line.lstrip().startswith("|")]
    if len(lines) < 3 or split_row(lines[0]) != PLAN_DELTA_HEADER:
        raise PhaseRebaseError("Plan Delta History table header is invalid")
    rows: dict[str, list[str]] = {}
    for line in lines[2:]:
        cells = split_row(line)
        if len(cells) != len(PLAN_DELTA_HEADER):
            raise PhaseRebaseError("Plan Delta History row has invalid cell count")
        rows[cells[0]] = cells
    return rows


def validate_gate(phase: str, block: str, delta_rows: dict[str, list[str]]) -> None:
    if "#### Pre-Phase Plan Rebase Gate" not in block:
        raise PhaseRebaseError(f"{phase}: material Phase lacks Pre-Phase Plan Rebase Gate")

    scope = field(block, "Rebase scope")
    delta = field(block, "Material plan delta")
    record = field(block, "Plan delta record")
    approval = field(block, "User approval")
    gate = field(block, "Gate status")
    execution = re.search(r"(?mi)^- Execution status:\s*(.*?)\s*$", block)
    execution_status = execution.group(1).strip() if execution else "not-started"

    scope_lower = scope.lower()
    if "completed implementation" not in scope_lower or "remaining plan" not in scope_lower:
        raise PhaseRebaseError(f"{phase}: rebase scope must cover completed implementation and remaining plan")
    if delta not in PLAN_DELTA_VALUES:
        raise PhaseRebaseError(f"{phase}: invalid material plan delta state")
    if gate not in GATE_STATES:
        raise PhaseRebaseError(f"{phase}: invalid rebase gate state")

    if execution_status in {"in-progress", "verified", "complete", "completed"} and gate != "ready":
        raise PhaseRebaseError(f"{phase}: Phase cannot execute before Pre-Phase Plan Rebase Gate is ready")

    if delta == "pending":
        if record != "pending" or approval != "pending-if-material" or gate != "pending":
            raise PhaseRebaseError(f"{phase}: pending rebase must keep the Phase gate pending")
        return

    if delta == "none":
        if record != "not-required" or approval != "not-required" or gate != "ready":
            raise PhaseRebaseError(f"{phase}: no material Plan Delta must resolve directly to ready")
        return

    if record in {"pending", "not-required", ""}:
        raise PhaseRebaseError(f"{phase}: material Plan Delta requires a recorded delta ID")
    if record not in delta_rows:
        raise PhaseRebaseError(f"{phase}: material Plan Delta requires preserved Plan Delta History")

    history = delta_rows[record]
    history_approval = history[6]
    history_status = history[7]

    if gate == "blocked-on-plan-approval":
        if approval != "required-pending" or history_status != "proposed":
            raise PhaseRebaseError(f"{phase}: blocked material Plan Delta must remain pending user approval")
        return

    if gate != "ready":
        raise PhaseRebaseError(f"{phase}: material Plan Delta must be blocked or directly approved before ready")
    if not approval.lower().startswith("user-approved-plan-direct:"):
        raise PhaseRebaseError(f"{phase}: material Plan Delta ready state requires direct user plan approval")
    if not history_approval.lower().startswith("user-approved-plan-direct:"):
        raise PhaseRebaseError(f"{phase}: Plan Delta History must preserve direct user plan approval")
    if history_status != "approved-applied":
        raise PhaseRebaseError(f"{phase}: approved material Plan Delta must be recorded as approved-applied")


def validate_plan(text: str) -> None:
    execution_contract(text)
    blocks = phase_blocks(text)
    if not blocks:
        return
    delta_rows = plan_delta_rows(text)
    for phase, block in blocks:
        validate_gate(phase, block, delta_rows)


def validate_invalid_cases(directory: Path) -> int:
    paths = sorted(directory.glob("invalid-*.md"))
    if not paths:
        raise AssertionError(f"missing invalid phase-rebase fixtures: {directory}")
    for path in paths:
        expected = expected_error(path)
        try:
            validate_plan(path.read_text(encoding="utf-8"))
        except PhaseRebaseError as exc:
            if expected not in str(exc):
                raise AssertionError(f"{path.name}: expected {expected!r}, got {str(exc)!r}") from exc
        else:
            raise AssertionError(f"invalid phase-rebase fixture unexpectedly passed: {path.name}")
    return len(paths)


def main() -> int:
    repo_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
    exemplar = repo_root / "tests" / "se-good-plan" / "exemplars" / "full-plan-shape.md"
    valid_execution = repo_root / "tests" / "se-good-plan" / "phase-rebase" / "valid-approved-material-delta.md"

    validate_plan(exemplar.read_text(encoding="utf-8"))
    validate_plan(valid_execution.read_text(encoding="utf-8"))
    invalid_count = validate_invalid_cases(repo_root / "tests" / "se-good-plan" / "phase-rebase")

    print(
        "[se-good-plan-phase-rebase] validated persisted per-Phase gates, direct plan approval, "
        f"and Plan Delta history; {invalid_count} adversarial cases"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
