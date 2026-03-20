#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_id="custodes-coding-governor"
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

log "repository smoke test passed for $skill_id"
