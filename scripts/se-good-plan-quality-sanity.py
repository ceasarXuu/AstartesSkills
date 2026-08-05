#!/usr/bin/env python3
"""Validate representative se-good-plan outputs against behavioral quality rules."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ALLOWED_AXES = {
    "discovery", "design", "internal", "api", "data", "cache", "client",
    "deployment", "observability", "cleanup", "security",
}
PLANNING_STATUSES = {"planned", "blocked-on-discovery", "deferred"}
VALIDATION_STATUSES = {
    "planned", "direction-supported", "direction-rejected", "inconclusive",
    "budget-exhausted",
}
EXECUTION_STATUSES = {
    "not-started", "in-progress", "verified", "blocked", "failed", "rolled-back",
}
PLAN_VALIDITIES = {"valid", "valid-with-qualifications", "needs-revision", "invalidated"}
NEXT_ACTIONS = {"continue", "revise", "pause", "stop"}
CONCLUSION_PREFIXES = {
    "current", "qualified", "superseded", "invalidated", "needs-revalidation",
}
ARTIFACT_KINDS = {"discovery", "design"}
ARTIFACT_STATUSES = {"planned", "drafted", "reviewed", "verified"}
EVIDENCE_LEVELS = {
    "Static Evidence", "Observed Evidence", "Mock Evidence", "Sandbox Evidence",
    "Prototype Evidence", "Production Evidence",
}
ACTION_VERBS = {
    "add", "change", "remove", "replace", "move", "split", "route",
    "migrate", "wire", "validate", "rename", "introduce", "update",
    "create", "delete", "configure",
}
VAGUE_ACTIONS = {"refactor", "optimize", "improve", "handle", "support", "complete"}
VAGUE_LOCATIONS = {"backend", "frontend", "system", "codebase", "service", "module", "several services"}
VAGUE_OBJECTS = {"logic", "module", "flow", "system", "feature", "cache layer", "backend"}
GENERIC_BENEFITS = {
    "improves quality", "add value", "adds value", "helps the project",
    "makes the system better", "better system", "improves maintainability",
    "delivers the feature",
}
GENERIC_SIDE_EFFECTS = {
    "none", "no side effects", "n a", "na", "minimal impact", "low risk",
    "minor changes", "small change", "no major impact", "some code added",
}
SPECULATIVE_PHRASES = {
    "for future use", "future integrations", "possible future", "potential future",
    "might need", "may need", "just in case", "future proof", "future-proof",
    "for flexibility", "possible requirements",
}
ABSTRACTION_TERMS = {
    "interface", "factory", "provider", "registry", "framework", "plugin",
    "strategy", "event bus", "base class", "abstraction",
}
SINGLE_IMPLEMENTATION_MARKERS = {
    "only current", "single current", "only existing", "single existing",
    "only implementation", "single implementation",
}
CURRENT_NEED_MARKERS = {
    "required by", "two existing", "multiple existing", "current variants",
    "existing variants", "current consumers", "existing consumers",
}
HEAVY_VALIDATION_PHRASES = {
    "full production integration", "complete production integration",
    "production-ready implementation", "implement all error paths",
    "implement all edge cases", "full compatibility matrix",
    "deploy the completed feature", "production schema migration",
    "complete observability stack", "build the full solution",
}
UNBOUNDED_BUDGET_PHRASES = {
    "as needed", "unlimited", "until complete", "whatever it takes",
    "no limit", "no restrictions",
}

WORK_UNIT_HEADER = [
    "ID", "Objective", "Change Axis", "Change Location", "Target Object",
    "Concrete Action", "Resulting Behavior", "Benefit", "Side Effects",
    "Verification", "Safe Stop / Rollback", "Plan Status",
]
LEGACY_WORK_UNIT_HEADER = [
    "ID", "Objective", "Change Axis", "Change Location", "Target Object",
    "Concrete Action", "Resulting Behavior", "Benefit", "Verification",
    "Safe Stop / Rollback", "Plan Status",
]
ARTIFACT_HEADER = ["Artifact", "Kind", "Expected Output", "Status"]
VALIDATION_HEADER = [
    "ID", "Critical Assumption", "Decision Unlocked", "Cheapest Credible Method",
    "Enough Evidence / Not Proven", "Budget / Isolation", "Stop / Cleanup", "Status",
]
EXECUTION_HEADER = [
    "Work Unit", "Execution Status", "Evidence", "Missing Evidence", "Decision",
]
RECONCILIATION_HEADER = [
    "Phase", "New Evidence", "Affected Assumption / Prior Conclusion",
    "Conclusion Update", "Downstream Plan Change", "Plan Validity", "Next Action",
]


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
    return split_row(lines[0]), [split_row(line) for line in lines[2:]]


def declared_mode(text: str) -> str:
    match = re.search(r"(?mi)^- Mode:\s*(Plan Authoring|Execution Tracking)\s*$", text)
    if not match:
        raise PlanQualityError("document must declare Plan Authoring or Execution Tracking mode")
    return match.group(1)


def count_action_verbs(action: str) -> int:
    normalized = action.lower().strip()
    first = re.match(r"([a-zA-Z-]+)", normalized)
    count = 1 if first and first.group(1) in ACTION_VERBS else 0
    alternatives = "|".join(sorted(ACTION_VERBS))
    count += len(re.findall(rf"\b(?:and|then)\s+(?:{alternatives})\b", normalized))
    return count


def normalize_sentence(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", value.lower()).strip()


def validate_side_effects(unit_id: str, side_effects: str, behavior: str, benefit: str) -> None:
    normalized = normalize_sentence(side_effects)
    if len(side_effects) < 32 or normalized in GENERIC_SIDE_EFFECTS:
        raise PlanQualityError(f"{unit_id}: side effects are missing or too generic: {side_effects}")
    if not re.search(r"(?i)\bcomplexity\s*:", side_effects) or not re.search(r"(?i)\breach\s*/\s*cost\s*:", side_effects):
        raise PlanQualityError(f"{unit_id}: side effects must cover complexity delta and reach/cost")
    if normalized in {normalize_sentence(behavior), normalize_sentence(benefit)}:
        raise PlanQualityError(f"{unit_id}: side effects merely repeat behavior or benefit")


def validate_construction(unit_id: str, combined: str) -> None:
    normalized = normalize_sentence(combined)
    if any(phrase in normalized for phrase in SPECULATIVE_PHRASES):
        raise PlanQualityError(f"{unit_id}: speculative construction is not justified by a current need")
    has_abstraction = any(term in normalized for term in ABSTRACTION_TERMS)
    has_single = any(marker in normalized for marker in SINGLE_IMPLEMENTATION_MARKERS)
    has_current_need = any(marker in normalized for marker in CURRENT_NEED_MARKERS)
    if has_abstraction and has_single and not has_current_need:
        raise PlanQualityError(f"{unit_id}: new abstraction for one current implementation lacks justification")


def normalize_legacy_invalid_fixture(text: str) -> str:
    """Keep older adversarial fixtures focused on their original failure."""
    lines = text.splitlines()
    for index, line in enumerate(lines):
        if not line.lstrip().startswith("|") or split_row(line) != LEGACY_WORK_UNIT_HEADER:
            continue
        lines[index] = "| " + " | ".join(WORK_UNIT_HEADER) + " |"
        if index + 1 < len(lines):
            lines[index + 1] = "|" + "---|" * len(WORK_UNIT_HEADER)
        row_index = index + 2
        while row_index < len(lines) and lines[row_index].lstrip().startswith("|"):
            cells = split_row(lines[row_index])
            if len(cells) == len(LEGACY_WORK_UNIT_HEADER):
                cells.insert(8, "Complexity: legacy adversarial fixture adds no extra construction beyond its tested row; Reach/Cost: fixture-only normalization has no production impact")
                lines[row_index] = "| " + " | ".join(cells) + " |"
            row_index += 1
        return "\n".join(lines) + ("\n" if text.endswith("\n") else "")
    return text


def validate_work_units(text: str) -> None:
    header, rows = table_after_heading(text, "Work Units")
    if header != WORK_UNIT_HEADER:
        raise PlanQualityError("work-unit table header does not match the executable contract")

    ids: set[str] = set()
    for index, row in enumerate(rows, start=1):
        if len(row) != len(WORK_UNIT_HEADER):
            raise PlanQualityError(f"work unit row {index} has {len(row)} cells, expected {len(WORK_UNIT_HEADER)}")
        (
            unit_id, objective, axis, location, target, action, behavior, benefit,
            side_effects, verification, safe_stop, plan_status,
        ) = row

        if not unit_id or unit_id in ids:
            raise PlanQualityError(f"work unit row {index} has a missing or duplicate ID")
        ids.add(unit_id)
        if len(objective) < 8:
            raise PlanQualityError(f"{unit_id}: objective is too thin")
        if axis.lower() not in ALLOWED_AXES:
            raise PlanQualityError(f"{unit_id}: multiple or unsupported change axes: {axis}")
        if location.lower() in VAGUE_LOCATIONS or location.lower() == "unknown":
            raise PlanQualityError(f"{unit_id}: change location is vague: {location}")
        if not any(token in location for token in ("/", ".", "::", "#", ":")):
            raise PlanQualityError(f"{unit_id}: change location is not concrete enough: {location}")
        if target.lower() in VAGUE_OBJECTS or target.lower() == "unknown" or len(target) < 3:
            raise PlanQualityError(f"{unit_id}: target object is vague: {target}")

        action_verbs = count_action_verbs(action)
        if action_verbs == 0:
            if any(re.search(rf"\b{word}\b", action.lower()) for word in VAGUE_ACTIONS):
                raise PlanQualityError(f"{unit_id}: vague action without engineering mechanics: {action}")
            raise PlanQualityError(f"{unit_id}: concrete action has no explicit engineering operation: {action}")
        if action_verbs > 1 or ";" in action:
            raise PlanQualityError(f"{unit_id}: multiple primary actions are coupled in one work unit: {action}")
        if len(behavior) < 10:
            raise PlanQualityError(f"{unit_id}: resulting behavior is too thin")

        benefit_normalized = normalize_sentence(benefit)
        if len(benefit) < 16 or benefit_normalized in GENERIC_BENEFITS:
            raise PlanQualityError(f"{unit_id}: benefit is missing or too generic: {benefit}")
        if benefit_normalized == normalize_sentence(behavior):
            raise PlanQualityError(f"{unit_id}: benefit merely repeats resulting behavior")

        validate_side_effects(unit_id, side_effects, behavior, benefit)
        validate_construction(unit_id, " ".join([objective, target, action, benefit, side_effects]))

        if verification.lower() in {"run tests", "test", "verify", "check"} or len(verification) < 12:
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


def validate_preinvestment(text: str) -> None:
    material = bool(re.search(r"(?mi)^- Material Uncertainty:\s*yes\s*$", text))
    has_section = "## Pre-Investment Validation" in text
    if material and not has_section:
        raise PlanQualityError("material uncertainty requires bounded pre-investment validation")
    if not has_section:
        return

    header, rows = table_after_heading(text, "Pre-Investment Validation")
    if header != VALIDATION_HEADER:
        raise PlanQualityError("pre-investment validation table header is invalid")

    for index, row in enumerate(rows, start=1):
        if len(row) != len(VALIDATION_HEADER):
            raise PlanQualityError(f"validation row {index} has invalid cell count")
        item_id, assumption, decision, method, threshold, budget, stop, status = row
        if len(assumption) < 16 or len(decision) < 12:
            raise PlanQualityError(f"{item_id}: validation assumption or decision is too thin")
        if not any(level.lower() in method.lower() for level in EVIDENCE_LEVELS):
            raise PlanQualityError(f"{item_id}: validation method must name an evidence level")
        method_normalized = normalize_sentence(method)
        if any(phrase in method_normalized for phrase in HEAVY_VALIDATION_PHRASES):
            raise PlanQualityError(f"{item_id}: validation method is shadow implementation rather than minimum sufficient evidence")
        if not re.search(r"(?i)\benough\s*:", threshold) or not re.search(r"(?i)\bnot proven\s*:", threshold):
            raise PlanQualityError(f"{item_id}: validation must state enough evidence and what remains unproven")
        if not all(re.search(rf"(?i)\b{label}\s*:", budget) for label in ("Budget", "Allowed", "Forbidden")):
            raise PlanQualityError(f"{item_id}: validation budget/isolation must state Budget, Allowed, and Forbidden")
        budget_normalized = normalize_sentence(budget)
        if any(phrase in budget_normalized for phrase in UNBOUNDED_BUDGET_PHRASES):
            raise PlanQualityError(f"{item_id}: validation budget or isolation is unbounded")
        if re.search(r"(?i)\bforbidden\s*:\s*(none|nothing|n/a|na)\b", budget):
            raise PlanQualityError(f"{item_id}: validation must forbid production-changing scope")
        if not re.search(r"(?i)\bstop\s*:", stop) or not re.search(r"(?i)\bcleanup\s*/\s*promotion\s*:", stop):
            raise PlanQualityError(f"{item_id}: validation must state stop and cleanup/promotion")
        if status not in VALIDATION_STATUSES:
            raise PlanQualityError(f"{item_id}: invalid validation state or implementation evidence claim: {status}")


def validate_authoring_state(text: str) -> None:
    for pattern in [
        r"(?mi)^- Proceed Decision:\s*proceed\s*$",
        r"(?mi)^- Phase Status:\s*(complete|verified|landed)\s*$",
    ]:
        if re.search(pattern, text):
            raise PlanQualityError("execution result claimed in Plan Authoring mode")


def validate_execution_tracking(text: str) -> bool:
    header, rows = table_after_heading(text, "Execution Tracking")
    if header != EXECUTION_HEADER:
        raise PlanQualityError("execution tracking table header is invalid")
    verified = False
    for index, row in enumerate(rows, start=1):
        if len(row) != len(EXECUTION_HEADER):
            raise PlanQualityError(f"execution row {index} has invalid cell count")
        unit, status, evidence, missing, decision = row
        if not unit or status not in EXECUTION_STATUSES:
            raise PlanQualityError(f"execution row {index} has invalid work unit or status")
        if status == "verified":
            verified = True
            if len(evidence) < 16 or normalize_sentence(evidence) in {"tests pass", "verified", "done"}:
                raise PlanQualityError(f"{unit}: verified execution needs specific evidence")
        if decision not in {"proceed", "pause", "n/a"}:
            raise PlanQualityError(f"{unit}: invalid execution decision: {decision}")
        if status in {"blocked", "failed"} and decision == "proceed":
            raise PlanQualityError(f"{unit}: blocked or failed execution cannot proceed")
    return verified


def validate_reconciliation(text: str, *, required: bool) -> None:
    has_section = "## Phase Reconciliation" in text
    if required and not has_section:
        raise PlanQualityError("verified material phase requires evidence reconciliation before continuing")
    if not has_section:
        return

    header, rows = table_after_heading(text, "Phase Reconciliation")
    if header != RECONCILIATION_HEADER:
        raise PlanQualityError("phase reconciliation table header is invalid")

    for index, row in enumerate(rows, start=1):
        if len(row) != len(RECONCILIATION_HEADER):
            raise PlanQualityError(f"reconciliation row {index} has invalid cell count")
        phase, evidence, affected, update, downstream, validity, action = row
        if not phase or len(evidence) < 16:
            raise PlanQualityError(f"reconciliation row {index} has thin phase evidence")
        no_delta = "no material evidence delta" in evidence.lower()
        if not no_delta and len(affected) < 12:
            raise PlanQualityError(f"{phase}: affected assumption or prior conclusion is not traceable")
        prefix_match = re.match(r"(?i)^([a-z-]+)\s*:", update)
        if not prefix_match or prefix_match.group(1).lower() not in CONCLUSION_PREFIXES:
            raise PlanQualityError(f"{phase}: conclusion update must preserve a recognized validity status")
        conclusion_status = prefix_match.group(1).lower()
        if validity not in PLAN_VALIDITIES or action not in NEXT_ACTIONS:
            raise PlanQualityError(f"{phase}: invalid plan validity or next action")
        if len(downstream) < 4:
            raise PlanQualityError(f"{phase}: downstream plan change is missing")
        if validity in {"needs-revision", "invalidated"} and action == "continue":
            raise PlanQualityError(f"{phase}: stale downstream plan cannot continue after material invalidating evidence")
        if conclusion_status in {"superseded", "invalidated", "needs-revalidation"} and action == "continue":
            raise PlanQualityError(f"{phase}: changed prior conclusion requires revision, pause, or stop")
        if no_delta and validity != "valid":
            raise PlanQualityError(f"{phase}: no material evidence delta should not invalidate the plan")


def validate_plan(path: Path, *, allow_legacy_invalid: bool = False) -> None:
    text = path.read_text(encoding="utf-8")
    if allow_legacy_invalid:
        text = normalize_legacy_invalid_fixture(text)
    mode = declared_mode(text)
    if mode == "Plan Authoring":
        validate_authoring_state(text)
        validate_work_units(text)
        validate_artifacts(text)
        validate_preinvestment(text)
    else:
        verified = validate_execution_tracking(text)
        validate_reconciliation(text, required=verified)


def expected_error(path: Path) -> str:
    match = re.search(r"<!--\s*expected-error:\s*(.*?)\s*-->", path.read_text(encoding="utf-8"))
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
            validate_plan(path, allow_legacy_invalid=True)
        except PlanQualityError as exc:
            if expected not in str(exc):
                raise AssertionError(f"{path.name}: expected {expected!r}, got {str(exc)!r}") from exc
        else:
            raise AssertionError(f"invalid fixture unexpectedly passed: {path.name}")
    print(f"[se-good-plan-quality] validated {len(valid_files)} valid and {len(invalid_files)} invalid representative plan outputs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
