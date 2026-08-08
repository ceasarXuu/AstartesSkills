#!/usr/bin/env python3
"""Validate the canonical-PRD product-authority mode for se-good-plan."""

from __future__ import annotations

import re

DECISION_HEADER = [
    "ID", "Confirmed Decision", "Must Do", "Must Not Do", "Rationale",
    "Violation Signal", "Confirmation", "Status",
]


class AuthorityError(AssertionError):
    pass


def split_row(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def metadata(text: str, label: str) -> str:
    match = re.search(rf"(?mi)^- {re.escape(label)}:\s*(.*?)\s*$", text)
    if not match:
        raise AuthorityError(f"missing metadata: {label}")
    return match.group(1).strip()


def active_prd_decisions(prd: str) -> set[str]:
    match = re.search(
        r"(?ms)^## Confirmed Product Decisions\s*$\n(?P<body>.*?)(?=^## |\Z)",
        prd,
    )
    if not match:
        raise AuthorityError("canonical PRD lacks Confirmed Product Decisions")
    body = match.group("body")
    if "PROTECTED USER-AUTHORITY SECTION" not in body or "Agent self-approval is forbidden" not in body:
        raise AuthorityError("canonical PRD decision section is not protected")

    lines = [line for line in body.splitlines() if line.lstrip().startswith("|")]
    if len(lines) < 3:
        raise AuthorityError("canonical PRD decision section has no decision rows")
    if split_row(lines[0]) != DECISION_HEADER:
        raise AuthorityError("canonical PRD decision table header is invalid")

    active: set[str] = set()
    for row in lines[2:]:
        cells = split_row(row)
        if len(cells) != len(DECISION_HEADER):
            raise AuthorityError("canonical PRD decision row has invalid cell count")
        decision_id, _, _, _, _, _, confirmation, status = cells
        if not re.fullmatch(r"PD\d+", decision_id):
            raise AuthorityError("canonical PRD decision IDs must use stable PD numbers")
        if status not in {"active", "superseded"}:
            raise AuthorityError("canonical PRD decision status is invalid")
        if status == "active":
            if not confirmation.lower().startswith(("user-confirmed-direct:", "user-approved-prd:")):
                raise AuthorityError("active canonical PRD decision lacks direct user confirmation")
            active.add(decision_id)
    return active


def validate_plan(plan: str, prd: str) -> None:
    authority = metadata(plan, "Product Authority")
    if authority == "./decisions.md":
        raise AuthorityError("PRD-authority mode must not point to fallback decisions.md")
    if "Decision Baseline: ./decisions.md" in plan:
        raise AuthorityError("plan declares duplicate fallback authority alongside canonical PRD")
    if "## Execution Contract" not in plan or "## Design" not in plan or "## Work Units" not in plan:
        raise AuthorityError("plan lacks required execution sections")

    applicable_raw = metadata(plan, "Applicable Decisions")
    applicable = {
        item.strip().strip("`")
        for item in applicable_raw.split(",")
        if item.strip() and item.strip().lower() not in {"none", "n/a", "na"}
    }
    active = active_prd_decisions(prd)
    if not applicable.issubset(active):
        raise AuthorityError("plan references a decision that is not active canonical PRD authority")


VALID_PRD = """# PRD: Account Locale

## Confirmed Product Decisions

> PROTECTED USER-AUTHORITY SECTION
> Rows in this section require explicit user approval.
> Agent self-approval is forbidden.

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| PD1 | Locale remains optional | Preserve null-compatible reads | Do not require backfill before rollout | Existing accounts remain compatible | Existing null rows fail unchanged reads | user-confirmed-direct: keep compatibility | active |
| PD2 | User controls locale | Keep an explicit settings control | Do not silently overwrite locale | Preserve user control | Background writes change locale without action | user-approved-prd: reviewed PRD | active |
"""

VALID_PLAN = """# Account Locale Engineering Plan

- Product Authority: ../../../../prd/account-locale.md#confirmed-product-decisions
- Applicable Decisions: PD1, PD2

## Execution Contract

- Product authority requires explicit user approval.

## Design

Use the existing account settings flow.

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Store account locale | data | db/accounts.sql | accounts.locale | Add nullable locale | Locale can be stored | Enables locale preference | Complexity: one field; Reach/Cost: migration | Inspect schema | Revert migration | planned |
"""


def expect_error(plan: str, expected: str) -> None:
    try:
        validate_plan(plan, VALID_PRD)
    except AuthorityError as exc:
        if expected not in str(exc):
            raise AssertionError(f"expected {expected!r}, got {str(exc)!r}") from exc
    else:
        raise AssertionError("invalid PRD-authority plan unexpectedly passed")


def main() -> int:
    validate_plan(VALID_PLAN, VALID_PRD)
    expect_error(
        VALID_PLAN.replace(
            "- Applicable Decisions: PD1, PD2",
            "- Applicable Decisions: PD1, PD9",
        ),
        "not active canonical PRD authority",
    )
    expect_error(
        VALID_PLAN.replace(
            "- Applicable Decisions: PD1, PD2",
            "- Applicable Decisions: PD1, PD2\n- Decision Baseline: ./decisions.md",
        ),
        "duplicate fallback authority",
    )
    print("[se-good-plan-product-authority] canonical PRD authority mode passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
