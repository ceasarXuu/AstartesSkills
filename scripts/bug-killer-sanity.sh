#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[bug-killer-sanity] checking bug-killer package contract"

python3 - <<'PY' "$repo_root"
import json
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
skill_dir = repo_root / "skills" / "bug-killer"
skill_file = skill_dir / "SKILL.md"
agent_file = skill_dir / "agents" / "openai.yaml"
manifest_file = skill_dir / "markets" / "openai-compatible.json"
template_file = skill_dir / "templates" / "case-template.md"
fixtures_file = skill_dir / "references" / "interaction-fixtures.md"
registry_file = repo_root / "registry" / "skills.json"
readme_file = repo_root / "README.md"
readme_zh_file = repo_root / "README.zh-CN.md"
test_repo_file = repo_root / "scripts" / "test-repo.sh"
validate_repo_file = repo_root / "scripts" / "validate-repo.sh"


def fail(message: str) -> None:
    raise AssertionError(f"[bug-killer-sanity] ERROR: {message}")


def read(path: Path) -> str:
    if not path.is_file():
        fail(f"missing file: {path.relative_to(repo_root)}")
    return path.read_text(encoding="utf-8")


def require(text: str, needle: str, context: str) -> None:
    normalized_text = re.sub(r"\s+", " ", text)
    normalized_needle = re.sub(r"\s+", " ", needle)
    if needle not in text and normalized_needle not in normalized_text:
        fail(f"{context} missing required text: {needle}")


def require_absent(text: str, needle: str, context: str) -> None:
    if needle in text:
        fail(f"{context} must not contain: {needle}")


def require_ordered(text: str, needles: list[str], context: str) -> None:
    offset = -1
    for needle in needles:
        next_offset = text.find(needle, offset + 1)
        if next_offset == -1:
            fail(f"{context} missing ordered item: {needle}")
        if next_offset <= offset:
            fail(f"{context} has item out of order: {needle}")
        offset = next_offset


def markdown_section(source: str, heading: str) -> str:
    match = re.search(
        rf"(?ms)^## {re.escape(heading)}\n(?P<body>.*?)(?=^## |\Z)",
        source,
    )
    if not match:
        fail(f"fixture missing section: {heading}")
    return match.group("body")


def fixture_bucket(fixture_body: str, bucket: str, context: str) -> str:
    match = re.search(
        rf"(?ms)^- {re.escape(bucket)}:\n(?P<body>.*?)(?=^- [A-Z][^:]+:|\Z)",
        fixture_body,
    )
    if not match:
        fail(f"{context} missing bucket: {bucket}")
    return match.group("body")


def simple_yaml_value(source: str, key: str) -> str:
    match = re.search(rf"(?m)^{re.escape(key)}:\s*(?P<value>.+)$", source)
    if not match:
        fail(f"missing YAML key: {key}")
    return match.group("value").strip().strip('"').strip("'")


def fenced_block_after(source: str, anchor: str, context: str) -> str:
    start = source.find(anchor)
    if start == -1:
        fail(f"missing anchor for {context}: {anchor}")
    match = re.search(r"```[a-zA-Z0-9_-]*\n(?P<body>.*?)(?=```)", source[start:], re.S)
    if not match:
        fail(f"missing fenced block for {context}")
    return match.group("body")


skill = read(skill_file)
agent = read(agent_file)
manifest = json.loads(read(manifest_file))
template = read(template_file)
fixtures = read(fixtures_file)
registry = json.loads(read(registry_file))
readme = read(readme_file)
readme_zh = read(readme_zh_file)
test_repo = read(test_repo_file)
validate_repo = read(validate_repo_file)

if len(skill.splitlines()) > 500:
    fail("SKILL.md exceeds 500 lines")

required_skill_sections = [
    "## Non-Negotiable Rules",
    "## Activation Gate",
    "## Case Artifact",
    "## Node Model",
    "### 1. Locate Or Create The Case",
    "### 4. Run Independent Research Paths",
    "### 6. Candidate Root-Cause Evidence Gate",
    "### 9. Repair Design Gate",
    "### 10. Implement And Validate The Fix",
    "## Anti-Patterns",
]
for section in required_skill_sections:
    require(skill, section, "SKILL.md")

require_ordered(
    skill,
    [
        "### 5. Generate Falsifiable Hypotheses",
        "### 6. Candidate Root-Cause Evidence Gate",
        "### 7. Record Evidence Before Changing Status",
        "### 8. Synthesize By Evidence Weight",
        "### 9. Repair Design Gate",
        "### 10. Implement And Validate The Fix",
    ],
    "debug workflow gate order",
)

for needle in [
    "/coe/YYYY-MM-DD-HH-mm-<short-bug-title>.md",
    "Bug Killer is a heavy debugging process",
    "Do not use this skill for every bug",
    "Run a lightweight debug path instead",
    "the user explicitly asks for `bug-killer`",
    "crosses two or more modules, services, platforms, data",
    "at least two repair attempts, hotfixes, or user-feedback cycles have failed",
    "production, customer-visible workflows, data correctness",
    "deep state machine, data mutation",
    "Case files may contain only `Problem`, `Hypothesis`, and `Evidence` nodes",
    "tied to a predeclared prediction or diagnostic-plan",
    "Repair design is forbidden until the candidate root cause passes the",
    "diagnostic evidence gate requires a planned signal and actual evidence",
    "If instrumentation is needed, make a diagnostic-only change first",
    "Compare findings by evidence quality, not by majority vote or agent agreement",
    "If confidence is low, ask for the next diagnostic experiment instead of",
    "Please confirm whether I should start the fix.",
    "Do not add a `Research Packet`, `Plan`, `Notes`, or any other free-form heading",
    "Do not count two shallow reads of the same file or log as independent paths",
    "exact falsifiable prediction or diagnostic evidence-plan clause",
    "fix-validation evidence exists",
    "references/interaction-fixtures.md",
]:
    require(skill, needle, "SKILL.md")

low_confidence_index = skill.find("For low confidence, use this instead:")
confirm_index = skill.find("Please confirm whether I should start the fix.")
if low_confidence_index == -1 or confirm_index == -1:
    fail("missing low-confidence or repair confirmation text")
repair_ready_block = fenced_block_after(skill, "Only after a hypothesis is `confirmed`", "repair-ready summary")
low_confidence_block = fenced_block_after(skill, "For low confidence, use this instead:", "low-confidence summary")
for needle in [
    "Root cause summary:",
    "- Cause:",
    "- Diagnostic evidence:",
    "- Ruled out:",
    "- Confidence: high | medium",
    "- Repair design direction:",
    "- Observability impact:",
    "- Remaining risk:",
    "Please confirm whether I should start the fix.",
]:
    require(repair_ready_block, needle, "repair-ready summary")
for needle in [
    "Root cause status:",
    "- Current hypothesis:",
    "- Missing proof:",
    "- Next diagnostic experiment:",
    "Repair status: not ready; repair design is blocked by the evidence gate.",
    "Should I continue investigation with this diagnostic experiment?",
]:
    require(low_confidence_block, needle, "low-confidence summary")
require_absent(low_confidence_block, "Please confirm whether I should start the fix.", "low-confidence summary")

for forbidden in [
    "if the cause seems obvious, go ahead and implement",
    "go ahead and implement the fix",
    "repair design may begin before evidence",
    "diagnostic instrumentation may be mixed with the repair",
]:
    require_absent((skill + "\n" + agent).lower(), forbidden, "skill and agent contract")

for node in ["# Problem P-001", "## Hypothesis H-001", "## Evidence E-001"]:
    require(template, node, "case template")
for needle in [
    "Diagnostic evidence plan:",
    "Prediction or clause under test:",
    "Signal:",
    "Capture method:",
    "Event name or marker:",
    "Correlation keys:",
    "Supports if:",
    "Refutes if:",
    "Instrumentation lifecycle:",
    "Evidence gate: pending | satisfied | blocked",
    "Repair design readiness: blocked until Status is confirmed and Evidence gate is satisfied",
    "Prediction or plan link:",
    "Matched signal:",
    "diagnostic-log",
    "user-feedback",
    "fix-validation",
]:
    require(template, needle, "case template")
require_absent(template, "start repair design", "case template")
for heading in re.findall(r"(?m)^#{1,6} .+$", template):
    allowed = (
        heading.startswith("# Problem P-001:")
        or heading.startswith("## Hypothesis H-")
        or heading.startswith("## Evidence E-")
    )
    if not allowed:
        fail(f"case template has illegal heading: {heading}")

default_prompt = simple_yaml_value(agent, "default_prompt").lower()
short_description = simple_yaml_value(agent, "short_description").lower()
for needle in ["heavy debug", "medium and large bugs only", "proof gate before repair"]:
    require(short_description, needle, "agents/openai.yaml short_description")
for needle in [
    "/coe case file",
    "activation gate is met",
    "heavy debug",
    "evidence-gated debug",
    "multi-path root-cause analysis",
    "repair only after proof",
    "at least two repair or user-feedback cycles failed",
    "deep state machine",
    "if the gate is not met, say this heavy process is probably too costly",
    "falsifiable hypotheses",
    "independent research paths",
    "do not design or implement a repair until",
    "predeclared prediction or diagnostic evidence-plan clause",
    "diagnostic log, probe, test, reproduction, runtime observation, telemetry, config fact, or user-feedback loop",
    "if confidence is low, ask for the next diagnostic experiment instead of asking to fix",
    "diagnostic-only instrumentation separate from repair behavior",
    "only mark fixed after fix-validation evidence exists",
]:
    require(default_prompt, needle, "agents/openai.yaml default_prompt")

registry_skill = next((item for item in registry.get("skills", []) if item.get("id") == "bug-killer"), None)
if not registry_skill:
    fail("registry/skills.json missing bug-killer entry")
if registry_skill.get("path") != "skills/bug-killer":
    fail("registry path mismatch for bug-killer")
if manifest.get("release") != registry_skill.get("release"):
    fail("manifest release metadata does not match registry")

for needle in [
    "`bug-killer`",
    "diagnostic evidence gate",
    "npx skills add https://github.com/ceasarXuu/AstartesSkills --skill bug-killer",
]:
    require(readme, needle, "README.md")
require(readme_zh, "`bug-killer`", "README.zh-CN.md")
require(test_repo, '[[ "$skill_id" == "bug-killer" ]]', "scripts/test-repo.sh")
require(validate_repo, "scripts/bug-killer-sanity.sh", "scripts/validate-repo.sh")

fixture_expectations = {
    "Fixture 0: Small Bug Below Activation Gate": {
        "Expected behavior": [
            "State that Bug Killer is probably too heavy",
            "Use a lightweight debug loop unless the user explicitly requests Bug Killer",
            "Escalate only if the bug broadens",
        ],
        "Forbidden behavior": [
            "Create a new `/coe` case by default",
            "Run multi-path investigation for a one-file obvious fix",
        ],
    },
    "Fixture 1: Thin Bug Report": {
        "Expected behavior": [
            "Treat the cross-module surface as satisfying the activation gate",
            "Create or select a `/coe` case file",
            "Ask 1-3 targeted questions",
            "Keep repair status blocked until evidence exists",
        ],
        "Forbidden behavior": [
            "Start repair design from the symptom alone",
        ],
    },
    "Fixture 1B: Deep Single-Subsystem Bug": {
        "Expected behavior": [
            "Treat the deep state/history dependency as satisfying the activation gate",
            "Require diagnostic evidence against predeclared predictions",
        ],
        "Forbidden behavior": [
            "Decline Bug Killer only because the suspected code surface is one module",
            "Start repair from confidence language",
        ],
    },
    "Fixture 2: Candidate Root Cause Without Diagnostic Proof": {
        "Expected behavior": [
            "Treat the repeated failed repair/feedback cycles as satisfying the",
            "Record the candidate as a `Hypothesis`, not a confirmed cause",
            "Design a diagnostic evidence plan before any repair design",
            "State the signal that would support or refute the hypothesis",
        ],
        "Forbidden behavior": [
            "Present a repair plan as the next step",
            "Ask the user to confirm implementation before the evidence gate is",
        ],
    },
    "Fixture 3: Diagnostic Instrumentation Needed": {
        "Expected behavior": [
            "Label the change as diagnostic-only instrumentation",
            "Keep it separate from repair behavior",
            "Record resulting log output as `Evidence`",
            "Link the evidence to the exact prediction or evidence-plan clause it tested",
        ],
        "Forbidden behavior": [
            "Mix diagnostic logging with the repair patch",
            "Treat adding the log as proof",
        ],
    },
    "Fixture 3B: Subagents Unavailable": {
        "Expected behavior": [
            "Continue with at least two materially different local evidence paths",
            "Keep path separation explicit",
            "Do not count two shallow reads of the same file or log as independent paths",
        ],
        "Forbidden behavior": [
            "Treat lack of subagents as permission to skip multi-path investigation",
            "Claim consensus from one local investigation path",
        ],
    },
    "Fixture 4: Multi-Path Disagreement": {
        "Expected behavior": [
            "Compare by evidence quality, not by majority vote",
            "Preserve disagreement in the case file",
            "Name the smallest diagnostic experiment",
        ],
        "Forbidden behavior": [
            "Treat agent agreement as proof",
        ],
    },
    "Fixture 5: Repair-Ready Cause": {
        "Expected behavior": [
            "Mark the relevant hypothesis `confirmed`",
            "Ask \"Please confirm whether I should start the fix.\"",
        ],
        "Forbidden behavior": [
            "Modify repair behavior before user confirmation",
        ],
    },
    "Fixture 6: Fix Validation": {
        "Expected behavior": [
            "Record validation as `Evidence` of type `fix-validation`",
            "Mark `Problem P-001` fixed only after",
        ],
        "Forbidden behavior": [
            "Mark fixed because code changed",
        ],
    },
}

for heading, buckets in fixture_expectations.items():
    fixture_body = markdown_section(fixtures, heading)
    expected_body = fixture_bucket(fixture_body, "Expected behavior", heading)
    forbidden_body = fixture_bucket(fixture_body, "Forbidden behavior", heading)
    for needle in buckets["Expected behavior"]:
        require(expected_body, needle, f"{heading} expected behavior")
    for needle in buckets["Forbidden behavior"]:
        require(forbidden_body, needle, f"{heading} forbidden behavior")
        require_absent(expected_body, needle, f"{heading} expected behavior")

print("[bug-killer-sanity] buckets checked: activation gate, schema-safe packet, multi-path fallback, diagnostic evidence gate, low-confidence block, template gate, fixture coverage, repo wiring")
print("[bug-killer-sanity] contract checks passed")
PY
