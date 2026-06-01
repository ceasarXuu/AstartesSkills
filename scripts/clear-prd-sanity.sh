#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[clear-prd-sanity] checking clear-prd package contract"

python3 - <<'PY' "$repo_root"
import json
import re
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
skill_dir = repo_root / "skills" / "clear-prd"
skill_file = skill_dir / "SKILL.md"
agent_file = skill_dir / "agents" / "openai.yaml"
manifest_file = skill_dir / "markets" / "openai-compatible.json"
fixture_file = skill_dir / "references" / "interaction-fixtures.md"
registry_file = repo_root / "registry" / "skills.json"
readme_file = repo_root / "README.md"


def fail(message: str) -> None:
    raise AssertionError(f"[clear-prd-sanity] ERROR: {message}")


def require_file(path: Path) -> str:
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


skill = require_file(skill_file)
agent = require_file(agent_file)
manifest_text = require_file(manifest_file)
fixture = require_file(fixture_file)
registry_text = require_file(registry_file)
readme = require_file(readme_file)

if len(skill.splitlines()) > 500:
    fail("SKILL.md exceeds 500 lines")

manifest = json.loads(manifest_text)
registry = json.loads(registry_text)
registry_skill = next(
    (item for item in registry.get("skills", []) if item.get("id") == "clear-prd"),
    None,
)
if not registry_skill:
    fail("registry/skills.json missing clear-prd entry")

require(skill, "name: clear-prd", "SKILL.md frontmatter")
require(skill, "Draft or Ready PRD", "SKILL.md frontmatter")
require(skill, "Avoid drifting into", "product-first guardrails")
require(skill, "Do not force premature technical design", "product-first guardrails")
require(skill, "Do not pretend the PRD is", "Draft fallback guardrails")
require(skill, "implementation-ready.", "Draft fallback guardrails")
require(skill, "Create `prd/` when missing", "PRD output path contract")
require(skill, "`prd/YYYY-MM-DD-<short-topic>-v2.md`", "PRD output path contract")
require(skill, "increment `v3`, `v4`, and so on", "PRD output path contract")

require_ordered(
    skill,
    [
        "### 1. Frame The Request",
        "### 2. Use A Top-Down Module Tree",
        "### 3. Ask In Structured Rounds",
        "### 4. Track Dependencies Between Rounds",
        "### 5. Decide When Clarification Is Complete",
    ],
    "clarification workflow",
)

require_ordered(
    skill,
    [
        "Product goal and success definition",
        "Users, roles, and real usage context",
        "Scope, non-goals, and launch slice",
        "Core scenarios and user journey",
        "Interaction model and information structure",
        "Rules, permissions, state lifecycle, and constraints",
        "Edge cases, empty states, errors, and recovery",
        "Content, data meaning, and user-facing terminology",
        "Acceptance criteria, review checklist, and open risks",
    ],
    "top-down module tree",
)

round_section = re.search(
    r"### 3\. Ask In Structured Rounds(?P<body>.*?)### 4\. Track Dependencies Between Rounds",
    skill,
    re.S,
)
if not round_section:
    fail("missing structured rounds section body")
round_body = round_section.group("body")
for needle in [
    "Prefer 3-6 questions per round only after the goal and",
    "ask only 1-2 highest-leverage questions",
    "Partial answers are acceptable",
    "Treat skipped or uncertain answers as open",
    "1B, 2 custom:",
    "Recommended: <A/B/C> - <product reason>",
    "Other: You can answer with a custom direction.",
]:
    require(round_body, needle, "structured rounds section")

dependency_section = re.search(
    r"### 4\. Track Dependencies Between Rounds(?P<body>.*?)### 5\. Decide When Clarification Is Complete",
    skill,
    re.S,
)
if not dependency_section:
    fail("missing dependency tracking section body")
dependency_body = dependency_section.group("body")
require_ordered(
    dependency_body,
    [
        "Extract confirmed decisions",
        "Extract exceptions or custom constraints",
        "List unanswered, uncertain, or contradictory items",
        "Identify which module is now unlocked",
        "Ask the next dependent round",
    ],
    "dependency tracking section",
)
for needle in ["Decision I heard:", "Exception:", "Still open:"]:
    require(dependency_body, needle, "custom answer normalization")

prd_contract = re.search(
    r"## PRD Document Contract(?P<body>.*?)## Acceptance Criteria Style",
    skill,
    re.S,
)
if not prd_contract:
    fail("missing PRD document contract body")
prd_body = prd_contract.group("body")
require_ordered(
    prd_body,
    [
        "- Status: Draft | Ready for implementation",
        "## Requester Review Summary",
        "## 10. Acceptance Criteria",
        "## 11. Review Checklist And Sign-off Questions",
        "## 12. Clarification Decision Log",
        "## 13. Open Questions And Risks",
        "## 14. Implementation Notes",
    ],
    "PRD document contract",
)
for needle in ["Key decisions:", "Important exceptions:", "Must-confirm before implementation:", "Status reason:"]:
    require(prd_body, needle, "requester review summary")

for needle in [
    "Partial Reply Downshift",
    "Custom Answer Normalization",
    "Confirmed decisions:",
    "Exceptions:",
    "Open questions:",
    "Downshift to one follow-up question",
    "Restate the decision and exception before unlocking downstream modules",
]:
    require(fixture, needle, "interaction fixture")

require(agent, "display_name: Clear PRD", "agents/openai.yaml")
require(agent, "Use $clear-prd", "agents/openai.yaml")
require(agent, "Draft or Ready PRD", "agents/openai.yaml")
if "implementation-ready PRD" in agent:
    fail("agents/openai.yaml over-promises implementation-ready output")

if manifest.get("source", {}).get("path") != "skills/clear-prd":
    fail("manifest source path mismatch")
if "Draft or Ready PRD" not in manifest.get("description", ""):
    fail("manifest description must mention Draft or Ready PRD")
if manifest.get("release") != registry_skill.get("release"):
    fail("manifest and registry release metadata differ")
if "Draft or Ready PRD" not in registry_skill.get("summary", ""):
    fail("registry summary must mention Draft or Ready PRD")

require(readme, "./scripts/test-repo.sh <skill-id>", "README testing docs")
require(readme, "./scripts/test-repo.sh clear-prd", "README testing docs")
require(readme, "Draft or Ready PRD", "README skill table")

print("[clear-prd-sanity] clear-prd sanity passed")
PY
