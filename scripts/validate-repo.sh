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

log "checking release metadata"
python3 - <<'PY' "$registry_file" "$repo_root" || exit 1
import json
import sys
from pathlib import Path

registry_path = Path(sys.argv[1])
repo_root = Path(sys.argv[2])
required_fields = ("version", "published_at", "publisher", "changes")

with registry_path.open("r", encoding="utf-8") as handle:
    registry = json.load(handle)

for skill in registry.get("skills", []):
    skill_id = skill.get("id", "<missing-id>")
    release = skill.get("release")
    assert isinstance(release, dict), f"missing registry release metadata for {skill_id}"

    for field in required_fields:
      assert field in release, f"missing registry release field '{field}' for {skill_id}"

    assert isinstance(release["version"], str) and release["version"].strip(), f"invalid registry release version for {skill_id}"
    assert isinstance(release["published_at"], str) and release["published_at"].strip(), f"invalid registry published_at for {skill_id}"
    assert isinstance(release["publisher"], str) and release["publisher"].strip(), f"invalid registry publisher for {skill_id}"
    assert isinstance(release["changes"], list) and release["changes"], f"invalid registry changes list for {skill_id}"
    assert all(isinstance(item, str) and item.strip() for item in release["changes"]), f"invalid registry change entry for {skill_id}"

    manifest_relpath = (
        skill.get("markets", {})
        .get("openai-compatible", {})
        .get("manifest")
    )
    if not manifest_relpath:
        continue

    manifest_path = repo_root / manifest_relpath
    with manifest_path.open("r", encoding="utf-8") as handle:
        manifest = json.load(handle)

    manifest_release = manifest.get("release")
    assert isinstance(manifest_release, dict), f"missing manifest release metadata for {skill_id}"
    assert manifest_release == release, f"release metadata mismatch between registry and manifest for {skill_id}"
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
