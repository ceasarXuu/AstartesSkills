#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  install-skill.sh [--repo <git-url>] [--target <dir>] <skill> [<skill> ...]

Examples:
  ./scripts/install-skill.sh summary-my-repo
  ./scripts/install-skill.sh --target ~/.codex/skills summary-my-repo
  curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/install-skill.sh \
    | bash -s -- --repo https://github.com/<owner>/<repo>.git summary-my-repo
EOF
}

log() {
  echo "[install] $*" >&2
}

repo_url=""
target_dir="${CODEX_HOME:-$HOME/.codex}/skills"
skills=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo_url="${2:-}"
      shift 2
      ;;
    --target)
      target_dir="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      skills+=("$1")
      shift
      ;;
  esac
done

if [[ ${#skills[@]} -eq 0 ]]; then
  usage
  exit 1
fi

temp_dir=""
cleanup() {
  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir"
  fi
}
trap cleanup EXIT

if [[ -n "$repo_url" ]]; then
  temp_dir="$(mktemp -d)"
  log "cloning $repo_url into temporary directory"
  git clone --depth 1 "$repo_url" "$temp_dir" >&2
  repo_root="$temp_dir"
else
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

mkdir -p "$target_dir"
log "install target: $target_dir"

for skill in "${skills[@]}"; do
  source_dir="$repo_root/skills/$skill"
  dest_dir="$target_dir/$skill"

  if [[ ! -d "$source_dir" ]]; then
    log "skill not found: $skill"
    exit 1
  fi

  if [[ ! -f "$source_dir/SKILL.md" ]]; then
    log "invalid skill, missing SKILL.md: $skill"
    exit 1
  fi

  rm -rf "$dest_dir"
  mkdir -p "$dest_dir"
  log "installing $skill"
  cp -R "$source_dir"/. "$dest_dir"/
done

log "installed: ${skills[*]}"
