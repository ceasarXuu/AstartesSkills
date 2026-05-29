#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
run_dir="${1:-}"
canary="${2:-}"
runs_root="$repo_root/tmp/vs-review-effectiveness/runs"

log() {
  echo "[vs-review-effectiveness] $*"
}

fail() {
  echo "[vs-review-effectiveness] ERROR: $*" >&2
  exit 1
}

[[ -n "$run_dir" ]] || fail "usage: $0 <run-dir> <canary>"
[[ -n "$canary" ]] || fail "usage: $0 <run-dir> <canary>"

[[ "$run_dir" != *..* ]] || fail "runtime directory must not contain path traversal: $run_dir"

[[ -d "$run_dir" ]] || fail "missing runtime directory: $run_dir"
[[ -d "$run_dir/vs_review" ]] || fail "missing runtime report directory: $run_dir/vs_review"
mkdir -p "$runs_root"
canonical_runs_root="$(cd "$runs_root" && pwd -P)"
canonical_run_dir="$(cd "$run_dir" && pwd -P)"
case "$canonical_run_dir/" in
  "$canonical_runs_root/"*) ;;
  *) fail "runtime directory escaped runs root: $canonical_run_dir" ;;
esac

log "checking oracle is not present in runtime copy"
[[ ! -e "$run_dir/oracles" ]] || fail "runtime copy must not include oracle files"

log "scanning runtime artifacts for canary leakage"
if grep -RIn -- "$canary" "$run_dir"; then
  fail "canary leaked into runtime artifacts"
fi
if find "$run_dir" -print | grep -F -- "$canary"; then
  fail "canary leaked into runtime artifact path"
fi

log "checking git visibility of runtime root"
if git -C "$repo_root" status --short -- "$canonical_run_dir" | grep -q '^[ MARC?]'; then
  fail "runtime root is visible to git; expected ignored tmp workspace"
fi

log "canary and spill scan passed"
