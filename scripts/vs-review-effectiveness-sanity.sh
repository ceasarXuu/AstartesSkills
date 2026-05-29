#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bench_dir="$repo_root/tests/vs-review-effectiveness"
expected_oracle_sha256="4ecb0b69abe8a1cdfe7279225ab00d48b863bfd2fe3307bd0ea77fb8cf7adb00"

log() {
  echo "[vs-review-effectiveness] $*"
}

fail() {
  echo "[vs-review-effectiveness] ERROR: $*" >&2
  exit 1
}

required_files=(
  "$bench_dir/README.md"
  "$bench_dir/fixtures/code/subscription.ts"
  "$bench_dir/fixtures/code/subscription.test.ts"
  "$bench_dir/fixtures/design/remote-terminal-reconnect.md"
  "$bench_dir/fixtures/skill/quick-review-skill.md"
  "$bench_dir/oracles/seeded-defects.md"
  "$bench_dir/templates/review-packet.md"
)

log "checking benchmark files"
for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || fail "missing $file"
done

log "checking ignored runtime workspace"
grep -qx 'tmp/' "$repo_root/.gitignore" || fail ".gitignore must ignore tmp/"

count_section() {
  local heading="$1"
  awk -v heading="$heading" '
    $0 == heading {inside=1; next}
    inside && /^## / {inside=0}
    inside && /^- (Blocking|Major):/ {count++}
    END {print count + 0}
  ' "$bench_dir/oracles/seeded-defects.md"
}

log "checking oracle seed inventory"
oracle_sha256="$(shasum -a 256 "$bench_dir/oracles/seeded-defects.md" | awk '{print $1}')"
[[ "$oracle_sha256" == "$expected_oracle_sha256" ]] || fail "oracle content hash changed: $oracle_sha256"
code_count="$(count_section "## code/subscription.ts")"
design_count="$(count_section "## design/remote-terminal-reconnect.md")"
skill_count="$(count_section "## skill/quick-review-skill.md")"
seed_count="$((code_count + design_count + skill_count))"
[[ "$code_count" -eq 4 ]] || fail "expected 4 code seeds, found $code_count"
[[ "$design_count" -eq 4 ]] || fail "expected 4 design seeds, found $design_count"
[[ "$skill_count" -eq 5 ]] || fail "expected 5 skill seeds, found $skill_count"
[[ "$seed_count" -eq 13 ]] || fail "expected 13 total seeded defects, found $seed_count"

log "checking fixtures do not expose oracle terms"
if grep -RInE 'Seeded Defect|idempotency key|duplicate request protection|fresh neutral navigation packet|accept/reject/defer|broken assumption' "$bench_dir/fixtures"; then
  fail "fixture appears to leak oracle wording"
fi

log "checking review packet isolation instructions"
grep -q 'Do not read oracle files' "$bench_dir/templates/review-packet.md" || fail "review packet must exclude oracle"
grep -q 'Do not use or mention any canary value' "$bench_dir/templates/review-packet.md" || fail "review packet must exclude canary"
grep -q 'outside the named target locations' "$bench_dir/templates/review-packet.md" || fail "review packet must restrict target scope"
grep -q 'Do not edit files' "$bench_dir/templates/review-packet.md" || fail "review packet must be read-only"
grep -q 'Temporary test project root' "$bench_dir/templates/review-packet.md" || fail "review packet must use temp root"
grep -q 'Target locations' "$bench_dir/templates/review-packet.md" || fail "review packet must use target locations"

log "checking runtime bootstrap guards"
if "$repo_root/scripts/vs-review-effectiveness-bootstrap.sh" '../escape' >/dev/null 2>&1; then
  fail "bootstrap accepted path traversal run id"
fi

run_id="sanity-$$-$(date +%s)"
bootstrap_output="$("$repo_root/scripts/vs-review-effectiveness-bootstrap.sh" "$run_id")"
run_dir="$repo_root/tmp/vs-review-effectiveness/runs/$run_id"
canary="$(printf '%s\n' "$bootstrap_output" | tail -n 1)"
[[ -d "$run_dir/fixtures" ]] || fail "bootstrap did not copy fixtures"
[[ -d "$run_dir/templates" ]] || fail "bootstrap did not copy templates"
[[ ! -e "$run_dir/oracles" ]] || fail "bootstrap copied oracle files into runtime"
grep -q 'fixtures/code/subscription.ts.*,.*fixtures/code/subscription.test.ts' "$run_dir/vs_review/runtime-report.md" || fail "runtime report must include both code target files"
if "$repo_root/scripts/vs-review-effectiveness-scan.sh" "$repo_root/tmp/vs-review-effectiveness/runs/../escape" "$canary" >/dev/null 2>&1; then
  fail "scan accepted path traversal run dir"
fi
"$repo_root/scripts/vs-review-effectiveness-scan.sh" "$run_dir" "$canary" >/dev/null

leak_run_id="sanity-leak-$$-$(date +%s)"
leak_output="$("$repo_root/scripts/vs-review-effectiveness-bootstrap.sh" "$leak_run_id")"
leak_run_dir="$repo_root/tmp/vs-review-effectiveness/runs/$leak_run_id"
leak_canary="$(printf '%s\n' "$leak_output" | tail -n 1)"
touch "$leak_run_dir/vs_review/$leak_canary.txt"
if "$repo_root/scripts/vs-review-effectiveness-scan.sh" "$leak_run_dir" "$leak_canary" >/dev/null 2>&1; then
  fail "scan missed canary in artifact path"
fi

log "benchmark sanity passed"
