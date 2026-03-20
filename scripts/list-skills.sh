#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"

echo "[list] scanning $skills_dir"

find "$skills_dir" -mindepth 1 -maxdepth 1 -type d \
  ! -name "_templates" \
  -exec basename {} \; \
  | sort
