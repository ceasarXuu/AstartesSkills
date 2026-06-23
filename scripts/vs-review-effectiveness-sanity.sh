#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bench_dir="$repo_root/tests/vs-review-effectiveness"
expected_oracle_sha256="ec6aa64a78a2afaa9238367a195d72f5efe1e94dc21de4e72a5520313de48093"

log() {
  echo "[vs-review-effectiveness] $*"
}

fail() {
  echo "[vs-review-effectiveness] ERROR: $*" >&2
  exit 1
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  grep -Eq "$pattern" "$file" || fail "$message"
}

has_section_pattern() {
  local file="$1"
  local start_pattern="$2"
  local end_pattern="$3"
  local required_pattern="$4"
  awk \
    -v start_pattern="$start_pattern" \
    -v end_pattern="$end_pattern" \
    -v required_pattern="$required_pattern" '
      $0 ~ start_pattern {inside=1}
      inside && $0 ~ required_pattern {found=1}
      inside && $0 ~ end_pattern && $0 !~ start_pattern {inside=0}
      END {exit found ? 0 : 1}
    ' "$file"
}

require_section_pattern() {
  local file="$1"
  local start_pattern="$2"
  local end_pattern="$3"
  local required_pattern="$4"
  local message="$5"
  has_section_pattern "$file" "$start_pattern" "$end_pattern" "$required_pattern" || fail "$message"
}

has_multi_reviewer_guidance() {
  local file="$1"
  awk '
    {
      line=tolower($0)
      if (line ~ /do not launch a panel by default/ || line ~ /prior multi-reviewer rounds/) {
        next
      }
      if (line ~ /(1-3|one to three).*(reviewer|round)/) {
        print $0
        found=1
      }
      if (line ~ /(use|choose|select|launch|spawn|add).*(two|three|2|3|multiple).*(reviewers|reviewer roles)/) {
        print $0
        found=1
      }
      if (line ~ /(use|choose|select|launch|spawn|add|bring in).*(second|another|extra|pair of|both|co-reviewer).*(reviewer|reviewers|panel)/) {
        print $0
        found=1
      }
      if (line ~ /(multi-reviewer panel|reviewer panel|launch a panel|panel for high-risk)/) {
        print $0
        found=1
      }
    }
    END {exit found ? 0 : 1}
  ' "$file"
}

reject_multi_reviewer_guidance() {
  local file="$1"
  local message="$2"
  if has_multi_reviewer_guidance "$file"; then
    fail "$message"
  fi
  return 0
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
[[ "$code_count" -eq 5 ]] || fail "expected 5 code seeds, found $code_count"
[[ "$design_count" -eq 5 ]] || fail "expected 5 design seeds, found $design_count"
[[ "$skill_count" -eq 5 ]] || fail "expected 5 skill seeds, found $skill_count"
[[ "$seed_count" -eq 15 ]] || fail "expected 15 total seeded defects, found $seed_count"

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
grep -q 'Implementation completeness focus' "$bench_dir/templates/review-packet.md" || fail "review packet must include implementation completeness focus"
grep -q 'Target benefit focus' "$bench_dir/templates/review-packet.md" || fail "review packet must include target benefit focus"

log "checking explicit user-perspective review contract"
skill_file="$repo_root/skills/subagent-vs-review/SKILL.md"
selection_file="$repo_root/skills/subagent-vs-review/references/reviewer-selection.md"
template_file="$repo_root/skills/subagent-vs-review/references/review-report-template.md"
manifest_file="$repo_root/skills/subagent-vs-review/agents/openai.yaml"

require_pattern "$skill_file" 'usability, ease of use, and ease of understanding' "skill must explicitly require user-perspective usability review"
require_pattern "$skill_file" 'implementation completeness' "skill must explicitly require implementation completeness review"
require_pattern "$skill_file" 'target benefit realization' "skill must explicitly require target benefit realization review"
require_pattern "$skill_file" 'command -v claude' "skill must discover Claude Code CLI candidates"
require_pattern "$skill_file" 'command -v codex' "skill must discover Codex CLI candidates"
require_pattern "$skill_file" 'command -v opencode' "skill must discover OpenCode CLI candidates"
require_pattern "$skill_file" 'command -v pi' "skill must discover Pi CLI candidates"
require_pattern "$skill_file" 'explicit approval before invoking any local CLI reviewer' "skill must require user approval before local CLI fallback"
require_pattern "$skill_file" 'ask the user whether another local agent is[[:space:]]*$' "skill must ask for user-recommended agents when discovery finds no candidates"
require_pattern "$skill_file" 'user-recommended command cannot be verified' "skill must block unverified user-recommended agents"
require_pattern "$skill_file" 'blocked_due_to_review_unavailable' "skill must block workflow when no approved reviewer is available"
require_pattern "$skill_file" 'protocols, interfaces,[[:space:]]*$' "skill must name protocol/interface completeness gaps"
require_pattern "$skill_file" 'demo scripts, or[[:space:]]*$' "skill must name demo-script completeness gaps"
require_pattern "$skill_file" 'speed, accuracy, cost,[[:space:]]*$' "skill must name benefit classes such as speed and accuracy"
require_pattern "$skill_file" 'user-perspective focus: usability, ease of use, ease of understanding' "review packet must include explicit user-perspective focus"
require_pattern "$skill_file" 'implementation-completeness focus: planned items, expected behaviors' "review packet must include explicit implementation-completeness focus"
require_pattern "$skill_file" 'target-benefit focus: claimed speed, accuracy, cost' "review packet must include explicit target-benefit focus"
require_pattern "$manifest_file" 'ease of use, ease of understanding' "agent manifest must expose ease-of-use and comprehension in discovery metadata"
require_pattern "$manifest_file" 'implementation completeness' "agent manifest must expose implementation completeness in discovery metadata"
require_pattern "$manifest_file" 'target benefit' "agent manifest must expose target benefit realization in discovery metadata"
require_pattern "$manifest_file" 'Claude, Codex, OpenCode, and Pi CLI' "agent manifest must expose local CLI fallback candidates"
require_pattern "$manifest_file" 'another local agent command' "agent manifest must ask for a user-recommended agent when built-in discovery finds none"
require_pattern "$manifest_file" 'explicit approval' "agent manifest must require approval before external CLI substitute"
require_pattern "$skill_file" 'Choose exactly 1 reviewer role per review round' "skill must require exactly one reviewer role per round"
require_pattern "$selection_file" 'Use exactly 1 reviewer per round' "reviewer selection must require exactly one reviewer per round"
reject_multi_reviewer_guidance "$skill_file" "skill must not restore contradictory multi-reviewer-per-round guidance"
reject_multi_reviewer_guidance "$selection_file" "reviewer selection must not restore contradictory multi-reviewer-per-round guidance"
require_section_pattern "$selection_file" '^`user-experience-adversary`$' '^`[^`]+`$' 'usability, ease of use, ease of understanding' "reviewer pool must define user-experience-adversary around explicit usability/comprehension concerns"
require_section_pattern "$selection_file" '^`implementation-completeness-adversary`$' '^`[^`]+`$' 'protocol-only, interface-only, schema-only' "reviewer pool must define implementation-completeness-adversary around incomplete landing"
require_section_pattern "$selection_file" '^`benefit-realization-adversary`$' '^`[^`]+`$' 'faster processing, higher accuracy, lower cost' "reviewer pool must define benefit-realization-adversary around claimed outcomes"
require_section_pattern "$selection_file" '^## Selection Rules$' '^## ' 'Select `implementation-completeness-adversary` whenever the target claims' "selection rules must bind implementation-completeness-adversary to completion claims"
require_section_pattern "$selection_file" '^## Selection Rules$' '^## ' 'Select `benefit-realization-adversary` whenever the target explicitly claims' "selection rules must bind benefit-realization-adversary to benefit claims"
require_section_pattern "$selection_file" '^## Selection Rules$' '^## ' 'Select `user-experience-adversary` whenever.*user-facing' "selection rules must bind user-experience-adversary to user-facing targets"
require_section_pattern "$selection_file" '^## Selection Rules$' '^## ' 'documentation path, skill usage path, prompt behavior, or[[:space:]]*$' "selection rules must name docs, skill usage, prompts, and operator procedures"
require_section_pattern "$selection_file" '^## Selection Rules$' '^## ' 'operator procedure where usability or comprehension can make the work fail\.' "selection rules must protect the operator procedure usability/comprehension clause"
require_section_pattern "$selection_file" '^Skill, prompt, or agent workflow review:$' '^Code implementation review:$' '`user-experience-adversary`' "skill/prompt/workflow reviews must include user-experience-adversary"
require_pattern "$template_file" '^#### User-Perspective Review Focus$' "report template must include user-perspective focus"
require_pattern "$template_file" '^#### Implementation Completeness Focus$' "report template must include implementation-completeness focus"
require_pattern "$template_file" '^#### Target Benefit Focus$' "report template must include target benefit focus"
require_pattern "$template_file" '^### Internal Subagent Unavailable Fallback$' "report template must include internal-subagent unavailable fallback section"
require_pattern "$template_file" 'usability \| ease-of-use \| comprehension' "report template must expose usability/comprehension lenses"
require_pattern "$template_file" 'implementation-completeness' "report template must expose implementation-completeness lens"
require_pattern "$template_file" 'target-benefit' "report template must expose target-benefit lens"
require_section_pattern "$template_file" '^##### User-Perspective Checks$' '^##### ' 'Evidence or link:' "user-perspective checks must require evidence or finding links"
require_section_pattern "$template_file" '^##### User-Perspective Checks$' '^##### ' 'Evidence or link: <path:line or finding id>' "user-perspective pass entries must require line-level evidence or finding links"
require_section_pattern "$template_file" '^##### User-Perspective Checks$' '^##### ' 'Actionable user-perspective issues must also appear under `Blocking Findings`[[:space:]]*$' "template must route actionable user-perspective issues into blocking/non-blocking triage"
require_section_pattern "$template_file" '^##### Implementation Completeness Checks$' '^##### ' 'Production Code Path' "implementation-completeness checks must require production code path evidence"
require_section_pattern "$template_file" '^##### Implementation Completeness Checks$' '^##### ' 'Only `landed` counts as complete' "implementation-completeness checks must define landed as the only complete status"
require_section_pattern "$template_file" '^##### Target Benefit Checks$' '^##### ' 'Measurement Method' "target benefit checks must require measurement method evidence"
require_section_pattern "$template_file" '^##### Target Benefit Checks$' '^##### ' 'Only `proven` means the claimed benefit is verified' "target benefit checks must define proven as the only verified benefit status"
require_section_pattern "$template_file" '^##### Target Benefit Checks$' '^##### ' 'appear under `Non-blocking Risks` as warnings' "target benefit gaps must be non-blocking warnings"
require_section_pattern "$template_file" '^##### Target Benefit Checks$' '^##### ' 'without blocking closure' "target benefit warnings must not block closure"
require_section_pattern "$template_file" '^### Internal Subagent Unavailable Fallback$' '^### ' 'User-approved CLI command' "fallback section must record exact approved CLI command"
require_section_pattern "$template_file" '^### Internal Subagent Unavailable Fallback$' '^### ' 'User-recommended agent command' "fallback section must record user-recommended agent commands"
require_section_pattern "$template_file" '^### Internal Subagent Unavailable Fallback$' '^### ' 'User-recommended agent verification' "fallback section must record verification of user-recommended agent commands"
require_section_pattern "$template_file" '^### Internal Subagent Unavailable Fallback$' '^### ' 'blocked_due_to_review_unavailable' "fallback section must record blocked workflow when approval is missing"

contract_negative_dir="$repo_root/tmp/vs-review-effectiveness/contract-negative-$$"
mkdir -p "$contract_negative_dir"
sed '/operator procedure where usability or comprehension can make the work fail[.]/d' "$selection_file" > "$contract_negative_dir/reviewer-selection-missing-operator.md"
if has_section_pattern "$contract_negative_dir/reviewer-selection-missing-operator.md" '^## Selection Rules$' '^## ' 'operator procedure where usability or comprehension can make the work fail\.'; then
  fail "negative contract fixture still passed after removing operator procedure clause"
fi
sed 's/path:line or finding id/target location or finding id/g' "$template_file" > "$contract_negative_dir/review-report-template-weak-evidence.md"
if has_section_pattern "$contract_negative_dir/review-report-template-weak-evidence.md" '^##### User-Perspective Checks$' '^##### ' 'Evidence or link: <path:line or finding id>'; then
  fail "negative contract fixture still passed after weakening user-perspective evidence"
fi
sed '/Select `implementation-completeness-adversary` whenever the target claims/d' "$selection_file" > "$contract_negative_dir/reviewer-selection-missing-completeness-rule.md"
if has_section_pattern "$contract_negative_dir/reviewer-selection-missing-completeness-rule.md" '^## Selection Rules$' '^## ' 'Select `implementation-completeness-adversary` whenever the target claims'; then
  fail "negative contract fixture still passed after removing implementation-completeness selection rule"
fi
sed 's/Only `landed` counts as complete/`landed` usually means complete/g' "$template_file" > "$contract_negative_dir/review-report-template-weak-completeness.md"
if has_section_pattern "$contract_negative_dir/review-report-template-weak-completeness.md" '^##### Implementation Completeness Checks$' '^##### ' 'Only `landed` counts as complete'; then
  fail "negative contract fixture still passed after weakening implementation-completeness status rule"
fi
sed '/Select `benefit-realization-adversary` whenever the target explicitly claims/d' "$selection_file" > "$contract_negative_dir/reviewer-selection-missing-benefit-rule.md"
if has_section_pattern "$contract_negative_dir/reviewer-selection-missing-benefit-rule.md" '^## Selection Rules$' '^## ' 'Select `benefit-realization-adversary` whenever the target explicitly claims'; then
  fail "negative contract fixture still passed after removing benefit-realization selection rule"
fi
sed 's/appear under `Non-blocking Risks` as warnings/appear under `Blocking Findings` when important/g' "$template_file" > "$contract_negative_dir/review-report-template-blocking-benefit.md"
if has_section_pattern "$contract_negative_dir/review-report-template-blocking-benefit.md" '^##### Target Benefit Checks$' '^##### ' 'appear under `Non-blocking Risks` as warnings'; then
  fail "negative contract fixture still passed after weakening target-benefit status rule"
fi
sed '/explicit approval before invoking any local CLI reviewer/d' "$skill_file" > "$contract_negative_dir/skill-missing-cli-approval.md"
if grep -q 'explicit approval before invoking any local CLI reviewer' "$contract_negative_dir/skill-missing-cli-approval.md"; then
  fail "negative contract fixture still passed after removing local CLI approval rule"
fi
sed '/User-approved CLI command/d' "$template_file" > "$contract_negative_dir/review-report-template-missing-cli-approval.md"
if has_section_pattern "$contract_negative_dir/review-report-template-missing-cli-approval.md" '^### Internal Subagent Unavailable Fallback$' '^### ' 'User-approved CLI command'; then
  fail "negative contract fixture still passed after removing approved CLI command audit field"
fi
sed '/User-recommended agent command/d' "$template_file" > "$contract_negative_dir/review-report-template-missing-user-agent.md"
if has_section_pattern "$contract_negative_dir/review-report-template-missing-user-agent.md" '^### Internal Subagent Unavailable Fallback$' '^### ' 'User-recommended agent command'; then
  fail "negative contract fixture still passed after removing user-recommended agent audit field"
fi
cp "$selection_file" "$contract_negative_dir/reviewer-selection-two-reviewers.md"
printf '\n- Use two reviewers for high-risk closure.\n' >> "$contract_negative_dir/reviewer-selection-two-reviewers.md"
if ! has_multi_reviewer_guidance "$contract_negative_dir/reviewer-selection-two-reviewers.md"; then
  fail "negative contract fixture still passed after adding spelled-out two-reviewer guidance"
fi
cp "$skill_file" "$contract_negative_dir/skill-multi-reviewer-panel.md"
printf '\nLaunch a multi-reviewer panel for high-risk reviews.\n' >> "$contract_negative_dir/skill-multi-reviewer-panel.md"
if ! has_multi_reviewer_guidance "$contract_negative_dir/skill-multi-reviewer-panel.md"; then
  fail "negative contract fixture still passed after adding multi-reviewer panel guidance"
fi
cp "$selection_file" "$contract_negative_dir/reviewer-selection-do-not-two-reviewers.md"
printf '\n- Do not stop at one reviewer for closure; use two reviewers for high-risk findings.\n' >> "$contract_negative_dir/reviewer-selection-do-not-two-reviewers.md"
if ! has_multi_reviewer_guidance "$contract_negative_dir/reviewer-selection-do-not-two-reviewers.md"; then
  fail "negative contract fixture still passed after adding do-not two-reviewer guidance"
fi
cp "$selection_file" "$contract_negative_dir/reviewer-selection-second-reviewer.md"
printf '\n- Add a second reviewer for closure work.\n' >> "$contract_negative_dir/reviewer-selection-second-reviewer.md"
if ! has_multi_reviewer_guidance "$contract_negative_dir/reviewer-selection-second-reviewer.md"; then
  fail "negative contract fixture still passed after adding second-reviewer guidance"
fi
cp "$selection_file" "$contract_negative_dir/reviewer-selection-synonyms.md"
printf '\n- Use a pair of reviewers when both reviewers can cover different angles.\n- Add a co-reviewer panel for high-risk work.\n- Add another reviewer for high-risk work.\n- Bring in an extra reviewer for closure work.\n' >> "$contract_negative_dir/reviewer-selection-synonyms.md"
if ! has_multi_reviewer_guidance "$contract_negative_dir/reviewer-selection-synonyms.md"; then
  fail "negative contract fixture still passed after adding reviewer-count synonym guidance"
fi

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
