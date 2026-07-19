#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_id="${1:-bug-killer}"
skill_dir="$repo_root/skills/$skill_id"
registry_file="$repo_root/registry/skills.json"
manifest_file="$skill_dir/markets/openai-compatible.json"
exported_manifest="$repo_root/dist/markets/openai-compatible/$skill_id.json"

log() {
  echo "[test] $*"
}

fail() {
  echo "[test] ERROR: $*" >&2
  exit 1
}

log "checking skill directory"
[[ -d "$skill_dir" ]] || fail "missing skill directory: $skill_dir"

log "checking required skill files"
[[ -f "$skill_dir/SKILL.md" ]] || fail "missing SKILL.md"
[[ -f "$skill_dir/agents/openai.yaml" ]] || fail "missing agents/openai.yaml"
[[ -f "$manifest_file" ]] || fail "missing market manifest"

log "checking registry entry"
grep -q "\"id\": \"$skill_id\"" "$registry_file" || fail "missing registry id: $skill_id"
grep -q "\"path\": \"skills/$skill_id\"" "$registry_file" || fail "missing registry path for $skill_id"

log "exporting marketplace artifacts"
"$repo_root/scripts/export-marketplace.py" >/dev/null

log "checking exported artifact"
[[ -f "$exported_manifest" ]] || fail "missing exported manifest: $exported_manifest"

if [[ "$skill_id" == "subagent-vs-review" ]]; then
  log "checking subagent-vs-review effectiveness benchmark asset sanity"
  "$repo_root/scripts/vs-review-effectiveness-sanity.sh"
  log "checking subagent-vs-review timeout validator fixtures"
  "$repo_root/scripts/vs-review-timeout-validator-fixtures.sh"
fi

if [[ "$skill_id" == "clear-prd" ]]; then
  log "checking clear-prd clarification contract"
  "$repo_root/scripts/clear-prd-sanity.sh"
fi

if [[ "$skill_id" == "bug-killer" ]]; then
  log "checking bug-killer evidence-gated debug contract"
  "$repo_root/scripts/bug-killer-sanity.sh"
fi

if [[ "$skill_id" == "se-good-plan" ]]; then
  log "checking se-good-plan engineering plan contract"
  "$repo_root/scripts/se-good-plan-sanity.sh"
fi

log "repository smoke test passed for $skill_id"
