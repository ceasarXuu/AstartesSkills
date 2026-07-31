#!/usr/bin/env python3
"""Validate representative se-good-plan outputs against behavioral quality rules."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ALLOWED_AXES = {
    "discovery",
    "design",
    "internal",
    "api",
    "data",
    "cache",
    "client",
    "deployment",
    "observability",
    "cleanup",
    "security",
}
PLANNING_STATUSES = {"planned", "blocked-on-discovery", "deferred"}
ARTIFACT_KINDS = {"discovery", "design"}
ARTIFACT_STATUSES = {"planned", "drafted", "reviewed", "verified"}
ACTION_VERBS = {
    "add",
    "change",
    "remove",
    "replace",
    "move",
    "split",
    "route",
    "migrate",
    "wire",
    "validate",
    "rename",
    "introduce",
    "update",
    "create",
    "delete",
    "configure",
}
VAGUE_ACTIONS = {"refactor", "optimize", "improve", "handle", "support", "complete"}
VAGUE_LOCATIONS = {"backend", "frontend", "system", "codebase", "service", "module", "several services"}
VAGUE_OBJECTS = {"logic", "module", "flow", "system", "feature", "cache layer", "backend"}

WORK_UNIT_HEADER = [
    "ID",
    "Objective",
    "Change Axis",
    "Change Location",
    "Target Object",
    "Concrete Action",
    "Resulting Behavior",
    "Verification",
    "Safe Stop / Rollback",
    "Plan Status",
]
ARTIFACT_HEADER = ["Artifact", "Kind", "Expected Output", "Status"]


class PlanQualityError(AssertionError):
    pass


def split_row(line: str) -> list[str]:
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def table_after_heading(text: str, heading: str) -> tuple[list[str], list[list[str]]]:
    match = re.search(rf"(?ms)^## {re.escape(heading)}\s*$\n(?P<body>.*?)(?=^## |\Z)", text)
    if not match:
        raise PlanQualityError(f"missing section: {heading}")
    lines = [line for line in match.group("body").splitlines() if line.lstrip().startswith("|")]
    if len(lines) < 3:
        raise PlanQualityError(f"{heading} must contain a header and at least one row")
    header = split_row(lines[0])
    rows = [split_row(line) for line in lines[2:]]
    return header, rows


def count_action_verbs(action: str) -> int:
    normalized = action.lower().strip()
    first = re.match(r"([a-zA-Z-]+)", normalized)
    count = 1 if first and first.group(1) in ACTION_VERBS else 0
    alternatives = "|".join(sorted(ACTION_VERBS))
    count += len(re.findall(rf"\b(?:and|then)\s+(?:{alternatives})\b", normalized))
    return count


def validate_work_units(text: str) -> None:
    header, rows = table_after_heading(text, "Work Units")
    if header != WORK_UNIT_HEADER:
        raise PlanQualityError("work-unit table header does not match the executable contract")

    ids: set[str] = set()
    for index, row in enumerate(rows, start=1):
        if len(row) != len(WORK_UNIT_HEADER):
            raise PlanQualityError(f"work unit row {index} has {len(row)} cells, expected {len(WORK_UNIT_HEADER)}")
        (
            unit_id,
            objective,
            axis,
            location,
            target,
            action,
            behavior,
            verification,
            safe_stop,
            plan_status,
        ) = row

        if not unit_id or unit_id in ids:
            raise PlanQualityError(f"work unit row {index} has a missing or duplicate ID")
        ids.add(unit_id)

        if len(objective) < 8:
            raise PlanQualityError(f"{unit_id}: objective is too thin")

        axis_normalized = axis.lower()
        if axis_normalized not in ALLOWED_AXES:
            raise PlanQualityError(f"{unit_id}: multiple or unsupported change axes: {axis}")

        location_normalized = location.lower()
        if location_normalized in VAGUE_LOCATIONS or location_normalized == "unknown":
            raise PlanQualityError(f"{unit_id}: change location is vague: {location}")
        if not any(token in location for token in ("/", ".", "::", "#", ":")):
            raise PlanQualityError(f"{unit_id}: change location is not concrete enough: {location}")

        target_normalized = target.lower()
        if target_normalized in VAGUE_OBJECTS or target_normalized == "unknown" or len(target) < 3:
            raise PlanQualityError(f"{unit_id}: target object is vague: {target}")

        action_verbs = count_action_verbs(action)
        if action_verbs == 0:
            vague = sorted(word for word in VAGUE_ACTIONS if re.search(rf"\b{word}\b", action.lower()))
            if vague:
                raise PlanQualityError(f"{unit_id}: vague action without engineering mechanics: {action}")
            raise PlanQualityError(f"{unit_id}: concrete action has no explicit engineering operation: {action}")
        if action_verbs > 1 or ";" in action:
            raise PlanQualityError(f"{unit_id}: multiple primary actions are coupled in one work unit: {action}")

        if len(behavior) < 10:
            raise PlanQualityError(f"{unit_id}: resulting behavior is too thin")

        verification_normalized = verification.lower()
        if verification_normalized in {"run tests", "test", "verify", "check"} or len(verification) < 12:
            raise PlanQualityError(f"{unit_id}: verification is not exact enough: {verification}")

        if len(safe_stop) < 8:
            raise PlanQualityError(f"{unit_id}: safe-stop or rollback boundary is missing")

        if plan_status not in PLANNING_STATUSES:
            raise PlanQualityError(f"{unit_id}: execution state used in Plan Authoring: {plan_status}")


def validate_artifacts(text: str) -> None:
    if "## Planning Artifacts" not in text:
        return
    header, rows = table_after_heading(text, "Planning Artifacts")
    if header != ARTIFACT_HEADER:
        raise PlanQualityError("planning-artifact table header is invalid")
    for index, row in enumerate(rows, start=1):
        if len(row) != len(ARTIFACT_HEADER):
            raise PlanQualityError(f"artifact row {index} has invalid cell count")
        artifact, kind, expected_output, status = row
        if not artifact or not expected_output:
            raise PlanQualityError(f"artifact row {index} is incomplete")
        if kind not in ARTIFACT_KINDS:
            raise PlanQualityError(f"artifact row {index} has invalid kind: {kind}")
        if status not in ARTIFACT_STATUSES:
            raise PlanQualityError(f"artifact row {index}: production-code state applied to planning artifact: {status}")


def validate_authoring_state(text: str) -> None:
    if not re.search(r"(?mi)^- Mode:\s*Plan Authoring\s*$", text):
        raise PlanQualityError("fixture must declare Plan Authoring mode")
    forbidden_lines = [
        r"(?mi)^- Proceed Decision:\s*proceed\s*$",
        r"(?mi)^- Phase Status:\s*(complete|verified|landed)\s*$",
    ]
    for pattern in forbidden_lines:
        if re.search(pattern, text):
            raise PlanQualityError("execution result claimed in Plan Authoring mode")


def validate_plan(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    validate_authoring_state(text)
    validate_work_units(text)
    validate_artifacts(text)


def expected_error(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"<!--\s*expected-error:\s*(.*?)\s*-->", text)
    if not match:
        raise AssertionError(f"invalid fixture missing expected-error marker: {path}")
    return match.group(1)


def main() -> int:
    repo_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
    fixture_dir = repo_root / "tests" / "se-good-plan" / "quality"
    exemplar = repo_root / "tests" / "se-good-plan" / "exemplars" / "full-plan-shape.md"

    valid_files = sorted(fixture_dir.glob("valid-*.md")) + [exemplar]
    invalid_files = sorted(fixture_dir.glob("invalid-*.md"))
    if not valid_files or not invalid_files:
        raise AssertionError("quality fixtures are missing")

    for path in valid_files:
        validate_plan(path)

    for path in invalid_files:
        expected = expected_error(path)
        try:
            validate_plan(path)
        except PlanQualityError as exc:
            if expected not in str(exc):
                raise AssertionError(
                    f"{path.name}: expected error containing {expected!r}, got {str(exc)!r}"
                ) from exc
        else:
            raise AssertionError(f"invalid fixture unexpectedly passed: {path.name}")

    print(
        f"[se-good-plan-quality] validated {len(valid_files)} valid and "
        f"{len(invalid_files)} invalid representative plan outputs"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
