#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
run_root="$repo_root/tmp/vs-review-timeout-validator/run-$$-$(date +%s)"

log() {
  echo "[vs-review-timeout-validator] $*"
}

fail() {
  echo "[vs-review-timeout-validator] ERROR: $*" >&2
  exit 1
}

write_minimal_repo() {
  local fixture_dir="$1"
  mkdir -p \
    "$fixture_dir/scripts" \
    "$fixture_dir/registry" \
    "$fixture_dir/skills/subagent-vs-review/agents" \
    "$fixture_dir/skills/subagent-vs-review/markets" \
    "$fixture_dir/vs_review"

  cp "$repo_root/scripts/validate-repo.sh" "$fixture_dir/scripts/validate-repo.sh"
  cp "$repo_root/scripts/validate-skill-registry-coverage.py" "$fixture_dir/scripts/validate-skill-registry-coverage.py"
  chmod +x "$fixture_dir/scripts/validate-repo.sh"
  chmod +x "$fixture_dir/scripts/validate-skill-registry-coverage.py"

  for sanity_script in bug-killer-sanity.sh clear-prd-sanity.sh plan-report-sanity.sh se-good-plan-sanity.sh; do
    printf '%s\n' '#!/usr/bin/env bash' 'set -euo pipefail' 'exit 0' > "$fixture_dir/scripts/$sanity_script"
    chmod +x "$fixture_dir/scripts/$sanity_script"
  done

  cat > "$fixture_dir/skills/subagent-vs-review/SKILL.md" <<'EOF'
# subagent-vs-review
EOF

  cat > "$fixture_dir/skills/subagent-vs-review/agents/openai.yaml" <<'EOF'
name: subagent-vs-review
EOF

  cat > "$fixture_dir/skills/subagent-vs-review/markets/openai-compatible.json" <<'EOF'
{
  "version": 1,
  "market": "openai-compatible",
  "display_name": "Subagent VS Review",
  "description": "Fixture manifest.",
  "release": {
    "version": "1.2.0",
    "published_at": "2026-05-30T00:54:37+08:00",
    "publisher": "ceasarXuu",
    "changes": ["Fixture release metadata."]
  }
}
EOF

  cat > "$fixture_dir/registry/skills.json" <<'EOF'
{
  "skills": [
    {
      "id": "subagent-vs-review",
      "name": "Subagent VS Review",
      "path": "skills/subagent-vs-review",
      "release": {
        "version": "1.2.0",
        "published_at": "2026-05-30T00:54:37+08:00",
        "publisher": "ceasarXuu",
        "changes": ["Fixture release metadata."]
      },
      "markets": {
        "openai-compatible": {
          "manifest": "skills/subagent-vs-review/markets/openai-compatible.json"
        }
      }
    }
  ]
}
EOF
}

write_report() {
  local fixture_dir="$1"
  local timeout_section="$2"
  local reviewer_output="$3"
  local response_rows="$4"
  local status="${5:-passed}"
  local closure_extra="${6:-- Blocking findings found: no
- Accepted blocking findings fixed: n/a
- Blocking re-review completed: n/a
- Blocking re-review passed: n/a
- Blocking re-review round links:
  - n/a
- Blocking re-review launch records:
  - n/a
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Blocked reason: n/a
- Allowed to proceed: yes}"
  local final="${7:-The timeout validator fixture is closed and allowed to proceed.}"
  local launch_extra="${8:-}"

  cat > "$fixture_dir/vs_review/2026-05-30-timeout-fixture-review.md" <<EOF
# Subagent VS Review: timeout fixture

- Created: 2026-05-30T01:30:00+08:00
- Updated: 2026-05-30T01:30:00+08:00
- Report schema: adversarial-v1
- Task: Exercise timeout validator fixtures.
- Report path: \`vs_review/2026-05-30-timeout-fixture-review.md\`
- Review mode: fresh internal subagents
- Source session policy: no inherited main-agent context
- Status: $status

## Round 1: timeout fixture

### Review Input

#### Objective
Validate timeout report behavior.

#### Review Target
Report validator fixture.

#### Target Locations
- \`scripts/validate-repo.sh\`

#### Change Introduction
Fixture checks whether timeout policy records are enforced.

#### Risk Focus
- Reports may hide timeout failures or untriaged findings.

#### Assumptions To Attack
- Timeout and output records cannot contradict each other.

#### Adversarial Lenses
- testing
- observability

#### Verification Status
- Fixture-only validation.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Do not modify files.

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| timeout-adversary | Timeout audit validation. | timeout records |

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| normal | 8m | none or bounded extension | 2 | cannot pass if review is unavailable |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| timeout-adversary | subagent tool/runtime | agent-1 | spawn_agent notification | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions | yes |
$launch_extra
$timeout_section

### Reviewer Outputs
$reviewer_output

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
$response_rows

### Closure Status

$closure_extra

## Final Conclusion

$final
EOF
}

positive_output='
#### timeout-adversary

##### Summary
The report contains one concrete non-blocking timeout audit risk.

##### Blocking Findings
- none

##### Non-blocking Risks
- Timeout audit could be bypassed if records are not mapped to launches.
  - Broken assumption: Timeout rows prove actual launched sessions.
  - Failure scenario: A report invents timeout session ids that were never launched.
  - Trigger condition: Timeout rows are accepted without launch id matching.
  - Impact: Review provenance becomes untrustworthy.
  - Proof needed: Validator rejects timeout session ids absent from launch records.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/validate-repo.sh` - Fixture evidence.
'

positive_response='| timeout-adversary | Timeout audit could be bypassed if records are not mapped to launches. | Timeout rows prove actual launched sessions. | minor | accept | Fixture validates matching. | Session id matching is enforced. | Completed in this fixture. |'

actionable_output='
#### timeout-adversary

##### Summary
The report contains one concrete non-blocking risk and one required fix.

##### Blocking Findings
- none

##### Non-blocking Risks
- Timeout audit could be bypassed if records are not mapped to launches.
  - Broken assumption: Timeout rows prove actual launched sessions.
  - Failure scenario: A report invents timeout session ids that were never launched.
  - Trigger condition: Timeout rows are accepted without launch id matching.
  - Impact: Review provenance becomes untrustworthy.
  - Proof needed: Validator rejects timeout session ids absent from launch records.

##### Required Fixes
- Add session id matching for timeout rows.

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/validate-repo.sh` - Fixture evidence.
'

actionable_response="$positive_response
| timeout-adversary | Add session id matching for timeout rows. | Timeout rows need launch provenance. | minor | accept | Fixture validates required-fix triage. | Session id matching is enforced. | Completed in this fixture. |"

run_should_pass() {
  local name="$1"
  local timeout_section="$2"
  local reviewer_output="$3"
  local response_rows="$4"
  local status="${5:-passed}"
  local closure_extra="${6:-}"
  local final="${7:-}"
  local launch_extra="${8:-}"
  local fixture_dir="$run_root/$name"
  write_minimal_repo "$fixture_dir"
  if [[ -n "$closure_extra" || -n "$final" ]]; then
    write_report "$fixture_dir" "$timeout_section" "$reviewer_output" "$response_rows" "$status" "$closure_extra" "$final" "$launch_extra"
  else
    write_report "$fixture_dir" "$timeout_section" "$reviewer_output" "$response_rows" "$status"
  fi
  "$fixture_dir/scripts/validate-repo.sh" >/dev/null
}

run_should_fail() {
  local name="$1"
  local timeout_section="$2"
  local reviewer_output="$3"
  local response_rows="$4"
  local launch_extra="${5:-}"
  local fixture_dir="$run_root/$name"
  write_minimal_repo "$fixture_dir"
  write_report "$fixture_dir" "$timeout_section" "$reviewer_output" "$response_rows" "passed" "" "" "$launch_extra"
  if "$fixture_dir/scripts/validate-repo.sh" >/dev/null 2>&1; then
    fail "fixture unexpectedly passed: $name"
  fi
}

log "running positive completed-review fixture"
run_should_pass "positive-completed" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | completed | Reviewer completed normally. | completed |' "$positive_output" "$positive_response"

log "running positive completed-after-extension fixture"
run_should_pass "positive-extension" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 16m | completed_after_extension | Primary timed out once, received one bounded extension, then completed. | extended |' "$positive_output" "$positive_response"

log "running positive actionable-bucket-triage fixture"
run_should_pass "positive-actionable-bucket" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | completed | Reviewer completed normally. | completed |' "$actionable_output" "$actionable_response"

blocked_closure='- Blocking findings found: no
- Accepted blocking findings fixed: n/a
- Blocking re-review completed: no
- Blocking re-review passed: no
- Blocking re-review round links:
  - n/a
- Blocking re-review launch records:
  - n/a
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Blocked reason: primary and replacement review attempts both failed
- Allowed to proceed: no'

log "running positive blocked failed-review fixture"
run_should_pass "positive-blocked" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary-a1 | timeout-adversary | 1 | agent-1 | 8m | timed_out | Primary attempt exceeded the configured wait. | replacement spawned |
| timeout-adversary-a2 | timeout-adversary | 2 | agent-2 | 8m | blocked_due_to_review_unavailable | Replacement was unavailable in the isolated fixture. | user decision required |

### User Decision After Failed Review

- Decision: blocked
- User-visible reason: primary and replacement review attempts both failed.' '' '' "blocked" "$blocked_closure" "The review did not complete and remains blocked." '| timeout-adversary | subagent tool/runtime | agent-2 | spawn_agent notification | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions | yes |'

log "running negative missing-timeout fixture"
run_should_fail "negative-missing-timeout" '' "$positive_output" "$positive_response"

log "running negative attempt-two-only fixture"
run_should_fail "negative-attempt-two-only" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 2 | agent-1 | 8m | timed_out | Replacement was recorded without a primary attempt. | replacement spawned |' '' ''

log "running negative replacement-reuses-primary-session fixture"
run_should_fail "negative-replacement-reuses-session" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary-a1 | timeout-adversary | 1 | agent-1 | 8m | timed_out | Primary attempt exceeded the configured wait. | replacement spawned |
| timeout-adversary-a2 | timeout-adversary | 2 | agent-1 | 8m | blocked_due_to_review_unavailable | Replacement reused the primary session. | user decision required |' '' ''

log "running negative timeout-session-absent-from-launch fixture"
run_should_fail "negative-session-absent" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-missing | 8m | completed | Reviewer completed with an unlaunched id. | completed |' "$positive_output" "$positive_response"

log "running negative fake-output-after-timeout fixture"
run_should_fail "negative-fake-timeout-output" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | timed_out | Primary timed out. | replacement spawned |' "$positive_output" "$positive_response"

log "running negative contradictory-action fixture"
run_should_fail "negative-contradictory-action" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | completed | Reviewer completed but action says replacement. | replacement spawned |' "$positive_output" "$positive_response"

log "running negative untriaged-finding fixture"
run_should_fail "negative-untriaged" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | completed | Reviewer completed normally. | completed |' "$positive_output" ''

hidden_required_output='
#### timeout-adversary

##### Summary
The summary describes the review outcome.

##### Blocking Findings
- none

##### Non-blocking Risks
- none

##### Required Fixes
- Add session id matching for timeout rows.

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/validate-repo.sh` - Fixture evidence.
'

log "running negative hidden-required-fix fixture"
run_should_fail "negative-hidden-required-fix" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | completed | Reviewer completed normally. | completed |' "$hidden_required_output" "$positive_response"

hidden_required_prose_output='
#### timeout-adversary

##### Summary
The summary describes the review outcome.

##### Blocking Findings
- none

##### Non-blocking Risks
- none

##### Required Fixes
Add session id matching for timeout rows.

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/validate-repo.sh` - Fixture evidence.
'

log "running negative hidden-required-fix-prose fixture"
run_should_fail "negative-hidden-required-fix-prose" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | completed | Reviewer completed normally. | completed |' "$hidden_required_prose_output" "$positive_response"

hidden_required_indented_output='
#### timeout-adversary

##### Summary
The summary describes the review outcome.

##### Blocking Findings
- none

##### Non-blocking Risks
- none

##### Required Fixes
  - Add session id matching for timeout rows.

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/validate-repo.sh` - Fixture evidence.
'

log "running negative hidden-required-fix-indented fixture"
run_should_fail "negative-hidden-required-fix-indented" '
### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| timeout-adversary | timeout-adversary | 1 | agent-1 | 8m | completed | Reviewer completed normally. | completed |' "$hidden_required_indented_output" "$positive_response"

log "running negative backdated-filename fixture"
backdated_dir="$run_root/negative-backdated"
write_minimal_repo "$backdated_dir"
write_report "$backdated_dir" '' "$positive_output" "$positive_response"
mv "$backdated_dir/vs_review/2026-05-30-timeout-fixture-review.md" "$backdated_dir/vs_review/2026-05-29-timeout-fixture-review.md"
if "$backdated_dir/scripts/validate-repo.sh" >/dev/null 2>&1; then
  fail "fixture unexpectedly passed: negative-backdated"
fi

log "timeout validator fixtures passed"
