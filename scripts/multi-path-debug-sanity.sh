#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_file="$repo_root/skills/multi-path-debug/SKILL.md"
agent_file="$repo_root/skills/multi-path-debug/agents/openai.yaml"
manifest_file="$repo_root/skills/multi-path-debug/markets/openai-compatible.json"
fixtures_file="$repo_root/skills/multi-path-debug/references/interaction-fixtures.md"

log() {
  echo "[multi-path-debug-sanity] $*"
}

fail() {
  echo "[multi-path-debug-sanity] ERROR: $*" >&2
  exit 1
}

[[ -f "$skill_file" ]] || fail "missing SKILL.md"
[[ -f "$agent_file" ]] || fail "missing agents/openai.yaml"
[[ -f "$manifest_file" ]] || fail "missing openai-compatible market manifest"
[[ -f "$fixtures_file" ]] || fail "missing interaction fixtures"

log "checking root-cause-first workflow contract"
python3 - <<'PY' "$skill_file" "$agent_file" "$manifest_file" "$fixtures_file"
import json
import re
import sys
from pathlib import Path

skill_path = Path(sys.argv[1])
agent_path = Path(sys.argv[2])
manifest_path = Path(sys.argv[3])
fixtures_path = Path(sys.argv[4])

skill = skill_path.read_text(encoding="utf-8")
agent = agent_path.read_text(encoding="utf-8")
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
fixtures = fixtures_path.read_text(encoding="utf-8")

def require_contains(source: str, phrases: list[str], context: str) -> None:
    missing = [phrase for phrase in phrases if phrase not in source]
    assert not missing, f"{context} missing phrases: {missing}"

def require_not_contains(source: str, phrases: list[str], context: str) -> None:
    present = [phrase for phrase in phrases if phrase in source]
    assert not present, f"{context} must not contain phrases: {present}"

def markdown_section(source: str, level: int, heading: str) -> str:
    match = re.search(
        rf"(?ms)^#{{{level}}} {re.escape(heading)}\n(?P<body>.*?)(?=^#{{1,{level}}} |\Z)",
        source,
    )
    assert match, f"missing section: {heading}"
    return match.group("body")

def fenced_block_after(source: str, anchor: str, context: str) -> str:
    start = source.find(anchor)
    assert start != -1, f"missing anchor for {context}: {anchor}"
    match = re.search(r"```[a-zA-Z0-9_-]*\n(?P<body>.*?)(?=```)", source[start:], re.S)
    assert match, f"missing fenced block for {context}"
    return match.group("body")

def fixture_bucket(fixture_body: str, bucket: str, context: str) -> str:
    match = re.search(
        rf"(?ms)^- {re.escape(bucket)}:\n(?P<body>.*?)(?=^- [A-Z][^:]+:|\Z)",
        fixture_body,
    )
    assert match, f"{context} missing bucket: {bucket}"
    return match.group("body")

def simple_yaml_value(source: str, key: str) -> str:
    match = re.search(rf"(?m)^{re.escape(key)}:\s*(?P<value>.+)$", source)
    assert match, f"missing YAML key: {key}"
    return match.group("value").strip().strip('"').strip("'")

def require_order(source: str, earlier: str, later: str, context: str) -> None:
    earlier_index = source.find(earlier)
    later_index = source.find(later)
    assert earlier_index != -1, f"{context} missing earlier phrase: {earlier}"
    assert later_index != -1, f"{context} missing later phrase: {later}"
    assert earlier_index < later_index, f"{context} order violation: {earlier!r} must precede {later!r}"

required_sections = [
    "## Non-Negotiable Rules",
    "## Investigation Artifact",
    "### 1. Intake And Light Orientation",
    "### 2. Build The Root-Cause Research Packet",
    "### 3. Discover And Authorize External Agents",
    "### 4. Run Independent Research Paths",
    "### 5. Synthesize By Evidence Weight",
    "### 6. Ask For Repair Confirmation",
    "## Confidence Scale",
    "## Anti-Patterns",
]
missing = [section for section in required_sections if section not in skill]
assert not missing, f"missing sections: {missing}"

positions = [skill.index(section) for section in required_sections[:8]]
assert positions == sorted(positions), "workflow sections are out of order"

required_phrases = [
    "Do not combine those phases",
    "Never edit code",
    "1-3 high-value questions",
    "Discover available local or configured external agent paths",
    "Ask for one authorization decision before invoking external agents",
    "Keep research paths independent",
    "Compare findings by evidence quality, not by majority vote",
    "Please confirm whether I should start the fix",
    "For `low` confidence, do not ask to start the fix",
    "Should I continue investigation with this next experiment?",
    "debug/multi-path/YYYY-MM-DD-HH-mm-<short-bug-title>.md",
    "references/interaction-fixtures.md",
]
require_contains(skill, required_phrases, "SKILL.md")

confirmation_text = "Please confirm whether I should start the fix."
continue_text = "Should I continue investigation with this next experiment?"
repair_ready_block = fenced_block_after(
    skill,
    "For `high` confidence or strong `medium` confidence",
    "repair-ready summary",
)
low_confidence_block = fenced_block_after(
    skill,
    "For `low` confidence, do not ask to start the fix",
    "low-confidence summary",
)
require_contains(repair_ready_block, [confirmation_text], "repair-ready summary")
require_not_contains(repair_ready_block, [continue_text], "repair-ready summary")
require_contains(low_confidence_block, [continue_text, "Repair status: not ready"], "low-confidence summary")
require_not_contains(low_confidence_block, [confirmation_text], "low-confidence summary")

for candidate in ("ask-claude", "ask-gemini", "opencode-controller"):
    assert candidate in skill, f"missing external agent candidate: {candidate}"

default_prompt = simple_yaml_value(agent, "default_prompt").lower()
require_contains(
    default_prompt,
    [
        "root-cause",
        "discover optional external agent paths",
        "ask my approval before invoking any external agent",
        "evidence quality rather than agent agreement",
        "stop before repair",
        "if confidence is low, ask to continue investigation instead of asking to fix",
        "only ask me to confirm repair after the root cause is evidence-backed",
    ],
    "agents/openai.yaml default_prompt",
)
require_order(
    default_prompt,
    "ask my approval before invoking any external agent",
    "run independent root-cause research paths",
    "external-agent approval gate",
)
require_order(
    default_prompt,
    "if confidence is low, ask to continue investigation instead of asking to fix",
    "only ask me to confirm repair after the root cause is evidence-backed",
    "low-confidence before repair confirmation",
)
require_not_contains(
    default_prompt,
    [
        "invoke external agent before approval",
        "use external agents before approval",
        "ask to fix even if confidence is low",
        "confirm repair before the root cause is evidence-backed",
    ],
    "agents/openai.yaml default_prompt",
)

fixture_expectations = {
    "Fixture 1: Thin Bug Report": {
        "Expected behavior": [
            "Ask 1-3 targeted questions",
            "Do not ask a full generic bug questionnaire",
        ],
        "Forbidden behavior": [
            "Start repair before context is sufficient",
            "Ask for framework, library, or implementation preferences",
        ],
    },
    "Fixture 2: External Agents Declined": {
        "Expected behavior": [
            "Record the external-agent authorization decision",
            "Continue with internal paths",
            "Do not invoke any external agent",
        ],
        "Forbidden behavior": [
            "Block root-cause research solely because external agents were declined",
            "Send code, logs, prompts, or artifacts to an external agent after denial",
        ],
    },
    "Fixture 3: Low Confidence Root Cause": {
        "Expected behavior": [
            "Mark confidence as `low`",
            "Ask whether to continue investigation",
            "State that repair is not ready",
        ],
        "Forbidden behavior": [
            "Ask \"Please confirm whether I should start the fix.\"",
            "Present a fix direction as confirmed root cause",
        ],
    },
    "Fixture 4: Repair-Ready Root Cause": {
        "Expected behavior": [
            "Summarize cause, evidence, ruled-out alternatives, confidence, fix",
            "Ask \"Please confirm whether I should start the fix.\"",
            "Preserve the investigation artifact before repair starts",
        ],
        "Forbidden behavior": [
            "Modify code before the user confirms repair",
            "Hide unresolved evidence gaps",
        ],
    },
    "Fixture 5: Independent Research Synthesis": {
        "Expected behavior": [
            "Compare findings by evidence quality, not by majority vote",
            "Keep initial research paths independent before synthesis",
            "If two causes remain plausible, name the smallest next experiment",
        ],
        "Forbidden behavior": [
            "Treat agent agreement as proof",
            "Rewrite disagreement into a single confident conclusion without evidence",
        ],
    },
}
for heading, buckets in fixture_expectations.items():
    fixture_body = markdown_section(fixtures, 2, heading)
    expected_body = fixture_bucket(fixture_body, "Expected behavior", heading)
    forbidden_body = fixture_bucket(fixture_body, "Forbidden behavior", heading)
    require_contains(expected_body, buckets["Expected behavior"], f"{heading} expected behavior")
    require_contains(forbidden_body, buckets["Forbidden behavior"], f"{heading} forbidden behavior")
    require_not_contains(expected_body, buckets["Forbidden behavior"], f"{heading} expected behavior")
    require_not_contains(forbidden_body, buckets["Expected behavior"], f"{heading} forbidden behavior")

release = manifest.get("release")
assert isinstance(release, dict), "manifest missing release metadata"
for field in ("version", "published_at", "publisher", "changes"):
    assert release.get(field), f"manifest release missing {field}"
assert re.match(r"^\d+\.\d+\.\d+$", release["version"]), "release version must be semver"
assert isinstance(release["changes"], list) and release["changes"], "release changes must be non-empty"
PY

log "multi-path-debug sanity passed"
