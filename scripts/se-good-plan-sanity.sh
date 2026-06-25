#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[se-good-plan-sanity] checking se-good-plan package contract"
echo "[se-good-plan-sanity] enforcing source contract: Software Engineering Plan Writing Skill Design v0.1"

python3 - <<'PY' "$repo_root"
import json
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
skill_dir = repo_root / "skills" / "se-good-plan"
skill_file = skill_dir / "SKILL.md"
agent_file = skill_dir / "agents" / "openai.yaml"
manifest_file = skill_dir / "markets" / "openai-compatible.json"
patterns_file = skill_dir / "references" / "plan-patterns.md"
source_contract_file = skill_dir / "references" / "source-contract.md"
fixtures_dir = repo_root / "tests" / "se-good-plan" / "fixtures"
exemplars_dir = repo_root / "tests" / "se-good-plan" / "exemplars"
registry_file = repo_root / "registry" / "skills.json"
readme_file = repo_root / "README.md"


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


def require_ordered(text: str, needles: list[str], context: str) -> None:
    offset = -1
    for needle in needles:
        next_offset = text.find(needle, offset + 1)
        if next_offset == -1:
            fail(f"{context} missing ordered item: {needle}")
        if next_offset <= offset:
            fail(f"{context} has item out of order: {needle}")
        offset = next_offset


def expect_failure(description: str, check) -> None:
    try:
        check()
    except AssertionError:
        return
    fail(f"negative fixture did not fail: {description}")


def require_semver(value: str, context: str) -> None:
    if not re.fullmatch(r"\d+\.\d+\.\d+", value):
        fail(f"{context} must use semver x.y.z: {value}")


def require_local_iso8601(value: str, context: str) -> None:
    pattern = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}"
    if not re.fullmatch(pattern, value):
        fail(f"{context} must use ISO 8601 local time with timezone: {value}")


def markdown_section(source: str, heading: str) -> str:
    match = re.search(
        rf"(?ms)^## {re.escape(heading)}\n(?P<body>.*?)(?=^## |\Z)",
        source,
    )
    if not match:
        fail(f"fixture missing section: {heading}")
    return match.group("body")


def require_plan_contract(skill_text: str, patterns_text: str, source_text: str) -> None:
    for needle in [
        "Software Engineering Plan Writing Skill Design",
        "## Trigger Contract",
        "## Context Honesty Contract",
        "## Standard Plan Required Sections",
        "## Full Plan Required Additions",
        "## Metadata Contract",
        "## Dependency Contract",
        "## Implementation Completeness Contract",
        "## Phase Contract",
    ]:
        require(source_text, needle, "source contract traceability")

    for needle in [
        "software engineering plan",
        "implementation plan",
        "refactor plan",
        "migration plan",
        "rollout plan",
        "bug-fix plan",
        "performance optimization plan",
        "security change plan",
        "DevOps / CI/CD plan",
        "review of an existing engineering plan",
    ]:
        require(skill_text, needle, "trigger contract")

    for needle in [
        "Do not invent project-specific facts",
        "Do not invent schedules, staffing, resource commitments, deadlines, launch",
        "Phase 0: Discovery",
    ]:
        require(skill_text, needle, "context honesty contract")
    require(source_text, "Missing context must be represented as assumptions, open questions", "source contract traceability")

    require_ordered(
        skill_text,
        [
            "1. Metadata",
            "2. Background",
            "3. Problem Definition",
            "4. Goals",
            "5. Non-goals",
            "6. Constraints And Assumptions",
            "7. Current State",
            "8. Plan Summary",
            "9. Overall Technical Design",
            "10. Phased Execution Plan",
            "11. Implementation Completeness Matrix",
            "12. Risks, Dependencies, And Mitigations",
            "13. Testing And Validation Strategy",
            "14. Release, Rollback, And Fallback Strategy",
            "15. Observability And Success Metrics",
            "16. Open Questions",
            "17. Change Log",
            "18. Plan Quality Checklist",
        ],
        "Standard Plan section inventory",
    )

    for needle in [
        "Complexity And Risk Assessment",
        "Alternatives And Tradeoffs",
        "Phase Gate Overview",
        "Data Migration Strategy",
        "API / Compatibility Strategy",
        "Security And Permission Review",
        "Post-release Verification And Cleanup",
        "Decision Log",
    ]:
        require(skill_text, needle, "Full Plan section inventory")

    for needle in [
        "| Low | Lightweight | 2-3 |",
        "| Medium | Standard | 4-5 |",
        "| High | Full | 6-8 |",
        "| Critical | Full with stronger review gates | 7-10 |",
    ]:
        require(skill_text, needle, "plan depth contract")

    for needle in [
        "- Created:",
        "- Updated:",
        "- Version:",
        "- Status: Draft | Reviewing | Approved | In Progress | Blocked | Completed | Deprecated",
        "- Owner / Responsible:",
        "- Related Systems:",
        "- Related Links:",
        "- Risk Level:",
        "- Plan Type: Lightweight | Standard | Full",
    ]:
        require(skill_text + "\n" + patterns_text, needle, "metadata contract")

    for needle in [
        "| Dependency | Type | Current Status | Blocking Risk | Handling Plan |",
        "system / person / data / environment / third-party",
        "Ready / Pending / Unknown",
    ]:
        require(skill_text + "\n" + patterns_text, needle, "dependency contract")

    for needle in [
        "| Plan Item | Expected Behavior | Production Code Path | Integration Entry | Test Evidence | Runtime / Log Evidence | Mock / Stub Exposure | Status |",
        "planned / landed / partial / stub-only / mock-only / deferred",
        "Only `landed` means complete",
        "protocols, interfaces, schemas, entry points, scaffolding, mock or fake data, demo scripts, and test-only wiring",
    ]:
        require(skill_text + "\n" + patterns_text + "\n" + source_text, needle, "implementation completeness contract")


def require_fixture(path: Path, expected: list[str], forbidden: list[str]) -> None:
    text = read(path)
    input_body = markdown_section(text, "Input")
    expected_body = markdown_section(text, "Expected Behavior")
    forbidden_body = markdown_section(text, "Forbidden Behavior")
    if len(input_body.strip()) < 20:
        fail(f"fixture has thin input: {path.relative_to(repo_root)}")
    for needle in expected:
        require(expected_body, needle, f"{path.name} expected behavior")
    for needle in forbidden:
        require(forbidden_body, needle, f"{path.name} forbidden behavior")
    for needle in forbidden:
        if needle in expected_body:
            fail(f"{path.name} expected behavior contains forbidden behavior: {needle}")


def require_exemplar_shape(path: Path) -> None:
    text = read(path)
    for needle in [
        "- Status: Draft",
        "- Plan Type: Full",
        "## Background",
        "## Problem Definition",
        "## Goals",
        "## Non-goals",
        "## Constraints And Assumptions",
        "## Current State",
        "## Complexity And Risk Assessment",
        "## Plan Summary",
        "## Overall Technical Design",
        "## Alternatives And Tradeoffs",
        "## Phased Execution Plan",
        "## Implementation Completeness Matrix",
        "### Phase 0: Discovery",
        "#### Entry Criteria Checks",
        "#### Implementation Completeness Evidence",
        "#### Testing And Validation",
        "#### Gate To Next Phase",
        "## Phase Gate Overview",
        "## Dependencies",
        "| Dependency | Type | Current Status | Blocking Risk | Handling Plan |",
        "## Risks, Dependencies, And Mitigations",
        "## Data Migration Strategy",
        "## API / Compatibility Strategy",
        "## Testing And Validation Strategy",
        "## Security And Permission Review",
        "## Release, Rollback, And Fallback Strategy",
        "## Observability And Success Metrics",
        "## Post-release Verification And Cleanup",
        "## Open Questions",
        "## Decision Log",
        "## Change Log",
        "## Plan Quality Checklist",
    ]:
        require(text, needle, f"{path.name} exemplar shape")


skill = read(skill_file)
agent = read(agent_file)
manifest_text = read(manifest_file)
patterns = read(patterns_file)
source_contract = read(source_contract_file)
registry_text = read(registry_file)
readme = read(readme_file)

if len(skill.splitlines()) > 500:
    fail("SKILL.md exceeds 500 lines")

manifest = json.loads(manifest_text)
registry = json.loads(registry_text)
registry_skill = next(
    (item for item in registry.get("skills", []) if item.get("id") == "se-good-plan"),
    None,
)
if not registry_skill:
    fail("registry/skills.json missing se-good-plan entry")

for needle in [
    "name: se-good-plan",
    "phased, executable, verifiable, reviewable, rollback-aware",
    "Do not invent project-specific facts",
    "If context is missing, keep moving by adding a Discovery phase",
    "Production-impacting work must include release, rollback",
    "Data changes must include migration, idempotency",
    "Security-sensitive work must include permission boundaries",
    "Implementation plans must include plan-to-code completeness evidence",
    "references/plan-patterns.md",
]:
    require(skill, needle, "SKILL.md")

require_plan_contract(skill, patterns, source_contract)

require_ordered(
    skill,
    [
        "### 1. Classify The Task",
        "### 2. Assess Complexity And Risk",
        "### 3. Choose Output Depth",
        "### 4. Extract Context Honestly",
        "### 5. Define The Problem And Goals",
        "### 6. Build The Phased Plan",
        "### 7. Add Review And Evidence Gates",
        "### 8. Review Existing Plans",
    ],
    "generation workflow",
)

for needle in [
    "production data migration",
    "authentication, authorization, permission",
    "payment, billing, accounting, order, asset",
    "core API compatibility risk",
    "irreversible or hard-to-rollback change",
    "cross-system architecture migration",
    "external dependency replacement",
]:
    require(skill, needle, "forced Full Plan rules")

phase_schema = re.search(
    r"### 6\. Build The Phased Plan(?P<body>.*?)### 7\. Add Review And Evidence Gates",
    skill,
    re.S,
)
if not phase_schema:
    fail("missing phase schema section")
for needle in [
    "#### Objective",
    "#### Entry Criteria",
    "#### Entry Criteria Checks",
    "#### Implementation Tasks",
    "#### Implementation Completeness Evidence",
    "#### Testing And Validation",
    "#### Exit Criteria",
    "#### Review Plan",
    "#### Risks And Fallback",
    "#### Gate To Next Phase",
]:
    require(phase_schema.group("body"), needle, "phase schema")

for heading in [
    "### Feature Development",
    "### Bug Fix",
    "### Refactor",
    "### Data Migration",
    "### Architecture Migration",
    "### Performance Optimization",
    "### Security Change",
    "### DevOps / CI/CD",
    "### Risk Table",
    "### Testing And Validation Table",
    "### Release, Rollback, And Fallback",
    "### Observability And Success Metrics",
    "### Metadata Block",
    "### Dependency Table",
    "### Implementation Completeness Matrix",
    "## Wording Guardrails",
    "## Anti-Patterns",
]:
    require(patterns, heading, "plan patterns reference")

for needle in [
    "migration, idempotency, retry/resume behavior",
    "p50, p95, and p99 latency",
    "Threat Model",
    "rollback unavailable",
    "implementation plans that treat protocols, scaffolds, mocks",
    "project-specific facts that were not provided or verified",
    "Do not invent owner, deadline, staffing, release date, or launch window values.",
]:
    require(patterns, needle, "plan patterns reference")

require(agent, "display_name: SE Good Plan", "agents/openai.yaml")
require(agent, "Use $se-good-plan", "agents/openai.yaml")
require(agent, "Lightweight, Standard, or Full", "agents/openai.yaml")
for needle in ["performance optimization", "security change", "DevOps / CI/CD", "do not invent schedules or staffing"]:
    require(agent, needle, "agents/openai.yaml")
for needle in ["plan-to-code completeness evidence", "production implementation", "mocks, fake data, demo scripts"]:
    require(agent, needle, "agents/openai.yaml")

release = manifest.get("release")
if not isinstance(release, dict):
    fail("manifest missing release metadata")
require_semver(release.get("version", ""), "manifest release version")
require_local_iso8601(release.get("published_at", ""), "manifest published_at")
if manifest.get("source", {}).get("path") != "skills/se-good-plan":
    fail("manifest source path mismatch")
if manifest.get("release") != registry_skill.get("release"):
    fail("manifest and registry release metadata differ")
if "rollback-aware" not in manifest.get("description", ""):
    fail("manifest description must mention rollback-aware plans")
if "rollback-aware" not in registry_skill.get("summary", ""):
    fail("registry summary must mention rollback-aware plans")
if "plan-to-code completeness" not in manifest.get("description", ""):
    fail("manifest description must mention plan-to-code completeness")
if "plan-to-code completeness" not in registry_skill.get("summary", ""):
    fail("registry summary must mention plan-to-code completeness")

require(readme, "`se-good-plan`", "README skill table")
require(readme, "./scripts/test-repo.sh se-good-plan", "README testing docs")
require(readme, "checked-in source contract", "README testing docs")

require_fixture(
    fixtures_dir / "low-risk-lightweight.md",
    [
        "Classify the task as Low complexity.",
        "Choose Lightweight Plan.",
        "Keep the plan to 2-3 phases",
        "Risks and rollback",
    ],
    [
        "Generate an 8-phase Full Plan",
        "Invent a release date, staffing plan, or maintenance window.",
    ],
)
require_fixture(
    fixtures_dir / "security-full-plan.md",
    [
        "Force Full Plan",
        "Security And Permission Review",
        "Threat Model",
        "Audit Logging And Alerts",
    ],
    [
        "Treat the request as Standard only",
        "Skip audit logging or abuse cases.",
    ],
)
require_fixture(
    fixtures_dir / "missing-context-discovery.md",
    [
        "Use Phase 0: Discovery",
        "List assumptions with verification methods.",
        "Open Questions",
        "Unknown unless provided",
        "idempotency, retry or resume behavior",
    ],
    [
        "Invent MySQL, Redis, table names, traffic level, or production data volume.",
        "Invent a deadline, staffing plan, release date, or maintenance window.",
    ],
)
require_fixture(
    fixtures_dir / "review-mode-flawed-plan.md",
    [
        "Lead with findings before a summary.",
        "phase gates",
        "rollback",
        "observability",
        "Full Plan triggers",
    ],
    [
        "Approve the plan because it contains build, test, and launch steps.",
        "Treat `Run tests` as a sufficient validation strategy.",
    ],
)
require_fixture(
    fixtures_dir / "performance-plan.md",
    [
        "Require baseline collection before implementation.",
        "Require a bottleneck hypothesis",
        "p50, p95, and p99 latency",
        "load-test comparison and production observation",
    ],
    [
        "Start with implementation before measuring the baseline.",
        "Promise a specific latency target without provided data.",
    ],
)
require_fixture(
    fixtures_dir / "devops-cicd-plan.md",
    [
        "Cover environment separation.",
        "release permissions",
        "secret management",
        "failure-mode and regression validation",
        "artifact management",
    ],
    [
        "Treat CI green status as the only release gate.",
        "Omit secret handling.",
    ],
)
require_exemplar_shape(exemplars_dir / "full-plan-shape.md")

negative_checks = [
    ("Standard Plan inventory loses Metadata", lambda: require_plan_contract(skill.replace("1. Metadata", "1. Meta"), patterns, source_contract)),
    ("Standard Plan inventory loses Plan Summary", lambda: require_plan_contract(skill.replace("8. Plan Summary", "8. Summary"), patterns, source_contract)),
    ("Full Plan loses Alternatives And Tradeoffs", lambda: require_plan_contract(skill.replace("Alternatives And Tradeoffs", "Tradeoff Notes"), patterns, source_contract)),
    ("Full Plan loses Decision Log", lambda: require_plan_contract(skill.replace("Decision Log", "Decision Notes"), patterns, source_contract)),
    ("Standard Plan loses Implementation Completeness Matrix", lambda: require_plan_contract(skill.replace("11. Implementation Completeness Matrix", "11. Implementation Notes"), patterns, source_contract)),
    ("Implementation completeness status loses stub-only", lambda: require_plan_contract(skill.replace("planned / landed / partial / stub-only / mock-only / deferred", "planned / landed / deferred"), patterns.replace("planned / landed / partial / stub-only / mock-only / deferred", "planned / landed / deferred"), source_contract.replace("`planned`, `partial`, `stub-only`, and", "`planned`, `partial`, and"))),
    ("Metadata status enum disappears", lambda: require_plan_contract(skill.replace("Draft | Reviewing | Approved | In Progress | Blocked | Completed | Deprecated", "Draft | Done"), patterns.replace("Draft | Reviewing | Approved | In Progress | Blocked | Completed | Deprecated", "Draft | Done"), source_contract)),
    ("Context honesty permits invented schedules", lambda: require_plan_contract(skill.replace("Do not invent schedules, staffing, resource commitments, deadlines, launch", "Do not invent project schedules only when explicitly forbidden, launch"), patterns, source_contract)),
    ("Release version rejects non-semver fixture", lambda: require_semver("1.0", "negative fixture release version")),
    ("Release timestamp rejects missing timezone fixture", lambda: require_local_iso8601("2026-06-04T20:23:07", "negative fixture published_at")),
]
for description, check in negative_checks:
    expect_failure(description, check)

print("[se-good-plan-sanity] se-good-plan sanity passed")
PY
"$repo_root/scripts/se-good-plan-benefit-sanity.sh"
"$repo_root/scripts/se-good-plan-observability-sanity.sh"
