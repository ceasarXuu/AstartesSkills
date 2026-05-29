#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bench_dir="$repo_root/tests/vs-review-effectiveness"
run_id="${1:-$(date +%Y%m%d-%H%M%S)}"
run_dir="$repo_root/tmp/vs-review-effectiveness/runs/$run_id"
runs_root="$repo_root/tmp/vs-review-effectiveness/runs"

log() {
  echo "[vs-review-effectiveness] $*"
}

fail() {
  echo "[vs-review-effectiveness] ERROR: $*" >&2
  exit 1
}

[[ "$run_id" =~ ^[A-Za-z0-9._-]+$ ]] || fail "run id contains unsafe characters: $run_id"
[[ "$run_id" != *..* ]] || fail "run id must not contain path traversal: $run_id"

[[ -d "$bench_dir" ]] || fail "missing benchmark directory: $bench_dir"
[[ ! -e "$run_dir" ]] || fail "runtime directory already exists: $run_dir"
grep -qx 'tmp/' "$repo_root/.gitignore" || fail ".gitignore must ignore tmp/"

mkdir -p "$runs_root"
canonical_runs_root="$(cd "$runs_root" && pwd -P)"
mkdir -p "$run_dir"
canonical_run_dir="$(cd "$run_dir" && pwd -P)"
case "$canonical_run_dir/" in
  "$canonical_runs_root/"*) ;;
  *) fail "runtime directory escaped runs root: $canonical_run_dir" ;;
esac

mkdir -p "$run_dir/fixtures" "$run_dir/templates"
cp "$bench_dir/README.md" "$run_dir/README.md"
cp -R "$bench_dir/fixtures/." "$run_dir/fixtures/"
cp -R "$bench_dir/templates/." "$run_dir/templates/"
mkdir -p "$run_dir/vs_review"

canary="VS_REVIEW_CANARY_${run_id}_$(date +%s)"
canary_hash="$(printf '%s' "$canary" | shasum -a 256 | awk '{print $1}')"

cat > "$run_dir/vs_review/runtime-report.md" <<EOF
# subagent-vs-review Effectiveness Runtime Report

- Created: $(date -Iseconds)
- Runtime root: \`$run_dir\`
- Canary SHA-256: \`$canary_hash\`
- Status: open

## Launch Records

| Case | Reviewer | Session / Job ID | Trace Source | Context Forked | Target Locations | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| code | <reviewer> | <id> | <tool call / notification> | no (\`fork_context=false\`) | \`fixtures/code/subscription.ts\`, \`fixtures/code/subscription.test.ts\` | oracle files, main-agent history, canary, unrelated repo files | yes |
| design | <reviewer> | <id> | <tool call / notification> | no (\`fork_context=false\`) | \`fixtures/design/remote-terminal-reconnect.md\` | oracle files, main-agent history, canary, unrelated repo files | yes |
| skill | <reviewer> | <id> | <tool call / notification> | no (\`fork_context=false\`) | \`fixtures/skill/quick-review-skill.md\` | oracle files, main-agent history, canary, unrelated repo files | yes |

## Reviewer Outputs

Append reviewer outputs here.

## Canary Scan

- Command: \`./scripts/vs-review-effectiveness-scan.sh "$run_dir" <canary>\`
- Result: pending

## Score

| Case | Seeded defects | Hits | Notes |
|---|---:|---:|---|
| code | 4 | pending | pending |
| design | 4 | pending | pending |
| skill | 5 | pending | pending |
EOF

log "runtime root: $run_dir"
log "runtime report: $run_dir/vs_review/runtime-report.md"
log "main-context canary below; keep it out of reviewer packets"
printf '%s\n' "$canary"
