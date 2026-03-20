#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
registry_file="$repo_root/registry/skills.json"

log() {
  echo "[validate] $*"
}

fail() {
  echo "[validate] ERROR: $*" >&2
  exit 1
}

[[ -d "$skills_dir" ]] || fail "missing skills directory"
[[ -f "$registry_file" ]] || fail "missing registry/skills.json"

log "checking registry json"
python3 - <<'PY' "$registry_file" || exit 1
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    data = json.load(handle)

assert isinstance(data.get("skills"), list)
PY

log "checking skill folders"

while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"

  if [[ "$skill_name" == "_templates" ]]; then
    continue
  fi

  [[ -f "$skill_dir/SKILL.md" ]] || fail "$skill_name is missing SKILL.md"
  [[ -f "$skill_dir/agents/openai.yaml" ]] || fail "$skill_name is missing agents/openai.yaml"
done < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d | sort)

log "checking registry paths"

while IFS= read -r path; do
  [[ -d "$repo_root/$path" ]] || fail "registry path does not exist: $path"
done < <(
  sed -n 's/.*"path": "\(skills\/[^"]*\)".*/\1/p' "$registry_file"
)

log "checking market manifests"

while IFS= read -r manifest; do
  python3 - <<'PY' "$repo_root/$manifest" || exit 1
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    json.load(handle)
PY
done < <(
  sed -n 's/.*"manifest": "\(skills\/[^"]*markets\/[^"]*\.json\)".*/\1/p' "$registry_file"
)

log "repository validation passed"
