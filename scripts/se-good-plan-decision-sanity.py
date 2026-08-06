#!/usr/bin/env python3
"""Validate se-good-plan product-decision authority and phase delta controls."""

from __future__ import annotations

import re
import sys
from pathlib import Path

DECISION_HEADER = [
    "ID", "Confirmed Decision", "Must Do", "Must Not Do", "Rationale",
    "Violation Signal", "Confirmation", "Status",
]
DELTA_HEADER = [
    "Phase", "Decision Surface", "Implemented / Observed Semantics",
    "Baseline Coverage", "Classification", "Required Action",
]
RECONCILIATION_HEADER = [
    "Phase", "New Evidence", "Affected Assumption / Prior Conclusion",
    "Decision Baseline Impact", "Conclusion Update", "Downstream Plan Change",
    "Plan Validity", "Next Action",
]
EXECUTION_HEADER = [
    "Work Unit", "Execution Status", "Evidence", "Missing Evidence", "Decision",
]
DECISION_STATUSES = {"active", "superseded"}
DELTA_CLASSIFICATIONS = {"covered", "engineering-only", "provisional", "conflict"}


class DecisionSanityError(AssertionError):
    pass


def split_row(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def first_table(text: str) -> tuple[list[str], list[list[str]]]:
    lines = [line for line in text.splitlines() if line.lstrip().startswith("|")]
    if len(lines) < 2:
        raise DecisionSanityError("decision baseline must contain a decision table")
    header = split_row(lines[0])
    rows = [split_row(line) for line in lines[2:]] if len(lines) > 2 else []
    return header, rows


def table_after_heading(text: str, heading: str) -> tuple[list[str], list[list[str]]]:
    match = re.search(rf"(?ms)^## {re.escape(heading)}\s*$\n(?P<body>.*?)(?=^## |\Z)", text)
    if not match:
        raise DecisionSanityError(f"missing section: {heading}")
    lines = [line for line in match.group("body").splitlines() if line.lstrip().startswith("|")]
    if len(lines) < 3:
        raise DecisionSanityError(f"{heading} must contain a header and at least one row")
    return split_row(lines[0]), [split_row(line) for line in lines[2:]]


def metadata(text: str, label: str) -> str:
    match = re.search(rf"(?mi)^- {re.escape(label)}:\s*(.*?)\s*$", text)
    if not match:
        raise DecisionSanityError(f"missing metadata: {label}")
    return match.group(1).strip()


def expected_error(path: Path) -> str:
    match = re.search(r"<!--\s*expected-error:\s*(.*?)\s*-->", path.read_text(encoding="utf-8"))
    if not match:
        raise AssertionError(f"missing expected-error marker: {path}")
    return match.group(1)


def validate_baseline(text: str) -> None:
    required_marker = "PROTECTED USER-AUTHORITY ARTIFACT"
    required_rule = "MUST NOT be created, modified, deleted, reinterpreted"
    if required_marker not in text or required_rule not in text:
        raise DecisionSanityError("decisions.md must declare protected user authority")
    if metadata(text, "Authority") != "User":
        raise DecisionSanityError("decisions.md authority must be User")
    if metadata(text, "Write Gate") != "Explicit user approval required":
        raise DecisionSanityError("decisions.md write gate must require explicit user approval")
    if metadata(text, "Agent Self-Approval") != "Forbidden":
        raise DecisionSanityError("decisions.md must forbid Agent self-approval")
    if "## Pending Product Decisions" in text:
        raise DecisionSanityError("pending product decisions must remain in plan.md")

    header, rows = first_table(text)
    if header != DECISION_HEADER:
        raise DecisionSanityError("product decision baseline table header is invalid")
    for index, row in enumerate(rows, start=1):
        if len(row) != len(DECISION_HEADER):
            raise DecisionSanityError(f"decision row {index} has invalid cell count")
        decision_id, decision, must_do, must_not, rationale, signal, confirmation, status = row
        if not decision_id:
            raise DecisionSanityError(f"decision row {index} has no ID")
        if status not in DECISION_STATUSES:
            raise DecisionSanityError("pending product decisions must remain in plan.md")
        if not confirmation.lower().startswith("user-confirmed-direct:"):
            raise DecisionSanityError("baseline decision requires direct user confirmation")
        if min(len(decision), len(must_do), len(must_not), len(rationale), len(signal)) < 8:
            raise DecisionSanityError(f"{decision_id}: decision row is too thin")


def validate_plan_contract(text: str) -> None:
    match = re.search(r"(?ms)^## Execution Contract\s*$\n(?P<body>.*?)(?=^## |\Z)", text)
    if not match:
        raise DecisionSanityError("plan.md must persist the Execution Contract")
    body = match.group("body")
    required = [
        "explicit user approval",
        "Agent self-approval is forbidden",
        "provisional",
        "Product Decision Delta",
        "Dependent work cannot continue",
    ]
    for needle in required:
        if needle.lower() not in body.lower():
            raise DecisionSanityError(f"plan.md Execution Contract missing: {needle}")
    if "## Design" not in text or "## Work Units" not in text:
        raise DecisionSanityError("plan.md must contain Design and Work Units")


def validate_product_decision_delta(text: str) -> None:
    execution_header, execution_rows = table_after_heading(text, "Execution Tracking")
    if execution_header != EXECUTION_HEADER:
        raise DecisionSanityError("execution tracking table header is invalid")
    verified = any(len(row) == len(EXECUTION_HEADER) and row[1] == "verified" for row in execution_rows)
    if not verified:
        return

    if "## Product Decision Delta" not in text:
        raise DecisionSanityError("verified material phase requires Product Decision Delta audit")
    delta_header, delta_rows = table_after_heading(text, "Product Decision Delta")
    if delta_header != DELTA_HEADER:
        raise DecisionSanityError("Product Decision Delta table header is invalid")

    unresolved = False
    for index, row in enumerate(delta_rows, start=1):
        if len(row) != len(DELTA_HEADER):
            raise DecisionSanityError(f"decision delta row {index} has invalid cell count")
        phase, surface, semantics, coverage, classification, action = row
        if not phase or len(surface) < 4 or len(semantics) < 12:
            raise DecisionSanityError(f"decision delta row {index} is too thin")
        if classification not in DELTA_CLASSIFICATIONS:
            raise DecisionSanityError(f"decision delta row {index} has invalid classification")
        if classification == "covered" and not re.search(r"\bD\d+\b", coverage):
            raise DecisionSanityError("covered decision delta must cite an active decision ID")
        if classification == "engineering-only" and coverage.lower() not in {"n/a", "na", "none"}:
            raise DecisionSanityError("engineering-only decision delta should not claim product authority")
        if classification in {"provisional", "conflict"}:
            unresolved = True
            if not re.search(r"(?i)\b(user|confirm|pause|decision)\b", action):
                raise DecisionSanityError("unresolved product decision delta must name a user decision action")

    recon_header, recon_rows = table_after_heading(text, "Phase Reconciliation")
    if recon_header != RECONCILIATION_HEADER:
        raise DecisionSanityError("phase reconciliation table header is invalid")
    if unresolved:
        for row in recon_rows:
            if len(row) != len(RECONCILIATION_HEADER):
                continue
            baseline_impact = row[3]
            next_action = row[7]
            if next_action == "continue":
                raise DecisionSanityError("unresolved provisional product decision cannot continue dependent work")
            if baseline_impact == "aligned":
                raise DecisionSanityError("unresolved product decision delta cannot be reconciled as aligned")


def validate_invalid_cases(directory: Path, validator) -> int:
    paths = sorted(directory.glob("invalid-*.md"))
    if not paths:
        raise AssertionError(f"missing invalid fixtures: {directory}")
    for path in paths:
        expected = expected_error(path)
        try:
            validator(path.read_text(encoding="utf-8"))
        except DecisionSanityError as exc:
            if expected not in str(exc):
                raise AssertionError(f"{path.name}: expected {expected!r}, got {str(exc)!r}") from exc
        else:
            raise AssertionError(f"invalid fixture unexpectedly passed: {path.name}")
    return len(paths)


def main() -> int:
    repo_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
    valid_topic = (
        repo_root / "tests" / "se-good-plan" / "artifact-bundles" / "valid-topic" /
        "docs" / "releases" / "v1.2.3" / "account-locale"
    )
    validate_baseline((valid_topic / "decisions.md").read_text(encoding="utf-8"))
    validate_plan_contract((valid_topic / "plan.md").read_text(encoding="utf-8"))

    valid_reconciliation = repo_root / "tests" / "se-good-plan" / "quality" / "valid-reconciliation.md"
    validate_product_decision_delta(valid_reconciliation.read_text(encoding="utf-8"))

    authority_count = validate_invalid_cases(
        repo_root / "tests" / "se-good-plan" / "decision-authority",
        lambda text: validate_plan_contract(text) if "Engineering Plan" in text else validate_baseline(text),
    )
    audit_count = validate_invalid_cases(
        repo_root / "tests" / "se-good-plan" / "decision-audit",
        validate_product_decision_delta,
    )

    print(
        "[se-good-plan-decision] validated protected baseline + Execution Contract + "
        f"bounded decision delta; {authority_count} authority and {audit_count} audit adversarial cases"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
