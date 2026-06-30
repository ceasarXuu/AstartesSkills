#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_dir="$repo_root/skills/plan-report"
skill_md="$skill_dir/SKILL.md"
template="$skill_dir/references/report-template.md"
agent="$skill_dir/agents/openai.yaml"
manifest="$skill_dir/markets/openai-compatible.json"
registry="$repo_root/registry/skills.json"

log() {
  echo "[plan-report-sanity] $*"
}

fail() {
  echo "[plan-report-sanity] ERROR: $*" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing file: ${1#$repo_root/}"
}

require_text() {
  local file="$1"
  local needle="$2"
  rg -Fq "$needle" "$file" || fail "${file#$repo_root/} missing required text: $needle"
}

require_file "$skill_md"
require_file "$template"
require_file "$agent"
require_file "$manifest"

require_text "$skill_md" "overall, stage, and module completion percentages"
require_text "$skill_md" "Goal Alignment Matrix"
require_text "$skill_md" "Every unfinished item must include a specific reason"
require_text "$skill_md" "Do not use fuzzy completion language"
require_text "$skill_md" "references/report-template.md"

require_text "$template" "## 1. Completion Overview"
require_text "$template" "## 2. Stage And Module Completion"
require_text "$template" "## 3. Goal Alignment Matrix"
require_text "$template" "## 5. Unfinished Work"
require_text "$template" "## 6. Recommended Next Actions"
require_text "$template" '````markdown'
require_text "$template" '```mermaid'
require_text "$template" "基本完成"

python3 - <<'PY' "$manifest" "$registry"
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
registry_path = Path(sys.argv[2])
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
registry = json.loads(registry_path.read_text(encoding="utf-8"))
template = Path(manifest_path).parents[1] / "references" / "report-template.md"
template_text = template.read_text(encoding="utf-8")

release = manifest["release"]
assert release["version"] == "1.0.0"
assert release["published_at"] == "2026-06-30T19:48:34+08:00"
assert release["publisher"] == "ceasarXuu"
assert release["changes"]

matches = [skill for skill in registry["skills"] if skill["id"] == "plan-report"]
assert len(matches) == 1, "registry must contain exactly one plan-report entry"
entry = matches[0]
assert entry["path"] == "skills/plan-report"
assert entry["release"] == release
assert entry["markets"]["openai-compatible"]["manifest"] == "skills/plan-report/markets/openai-compatible.json"
assert template_text.count("````markdown") == 1, "outer markdown example fence must use four backticks"
assert "\n````\n\n## Optional Charts" in template_text, "outer markdown example fence must close before optional charts"
assert not template_text.rstrip().endswith("```"), "template must not end with an unmatched code fence"
PY

log "plan-report contract passed"
