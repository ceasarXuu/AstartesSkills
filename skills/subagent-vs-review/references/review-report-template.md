# Review Report Template

Use this structure for every subagent-vs-review report. A report may contain
multiple rounds for the same task.

```markdown
# Subagent VS Review: <topic>

- Created: <ISO 8601 local time>
- Updated: <ISO 8601 local time>
- Report schema: adversarial-v1
- Task: <user or product goal>
- Report path: `vs_review/YYYY-MM-DD-<topic>-review.md`
- Review mode: fresh internal subagents
- Source session policy: no inherited main-agent context
- Status: open | passed | blocked | accepted-risk

## Round 1: <short round purpose>

### Review Input

#### Objective
<The user or product goal.>

#### Review Target
<Design, implementation, test plan, release process, document, skill, or workflow.>

#### Target Locations
- `<path or command>`
- `<path or command>`

#### Change Introduction
<Neutral description of the proposed or implemented direction.>

#### Risk Focus
- <assumption, boundary, or failure mode to challenge>

#### User-Perspective Review Focus
- <usability, ease-of-use, ease-of-understanding, onboarding, wording, feedback, recovery path, or realistic user behavior to challenge>

#### Assumptions To Attack
- <input, state, dependency, permission, timing, user behavior, or invariant>

#### Adversarial Lenses
- <requirements | state | input | concurrency | failure | data | security | usability | ease-of-use | comprehension | maintenance | testing | observability>

#### Verification Status
- <tests, smoke checks, logs, runtime validation, or known gaps>

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| simple / normal / complex / high-risk | <duration> | <none or bounded extension> | 2 | cannot pass if review is unavailable |

This section is required for current reports.

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| <reviewer> | <why selected> | <risk area> |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| <reviewer-role> | <subagent tool/runtime> | <id or equivalent trace handle> | <tool call, notification, transcript, or unavailable> | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| <reviewer-output-key> | <reviewer-role from launch row> | 1 | <id from launch row> | <duration> | completed / completed_after_extension / timed_out / lost / superseded / degraded / blocked_due_to_review_unavailable / late_result | <reason> | completed / extended / replacement spawned / user decision required |

### User Decision After Failed Review

- Required if primary and replacement attempts both fail.
- Decision: retry / narrow scope / change reviewer type / accept risk / blocked
- User-visible reason: <why the review did not complete>

### Reviewer Outputs

#### <reviewer-output-key>

##### Summary
<Short summary.>

##### Blocking Findings
- <finding, or "none">
  - Broken assumption: <assumption being falsified>
  - Failure scenario: <how the artifact fails>
  - Trigger condition: <input, state, timing, permission, or misuse case>
  - Impact: <user, data, security, maintenance, or operational blast radius>
  - Proof needed: <test, log, runtime check, or product decision>

##### Non-blocking Risks
- <risk, or "none">
  - Broken assumption: <assumption being challenged>
  - Failure scenario: <how the artifact may fail>
  - Trigger condition: <condition that exposes the risk>
  - Impact: <likely effect>
  - Proof needed: <evidence that would close or downgrade the risk>

##### User-Perspective Checks
- Usability: <pass, risk, or finding already listed above> - Evidence or link: <path:line or finding id>
- Ease of use: <pass, risk, or finding already listed above> - Evidence or link: <path:line or finding id>
- Ease of understanding: <pass, risk, or finding already listed above> - Evidence or link: <path:line or finding id>

Actionable user-perspective issues must also appear under `Blocking Findings`
or `Non-blocking Risks` so they receive main-agent triage.

##### Required Fixes
- <fix tied to a triaged finding, or "none">

##### Missing Tests
- <test gap tied to a triaged finding, or "none">

##### Missing Logs / Observability
- <observability gap tied to a triaged finding, or "none">

Use `none` or flush-left single-line `- ` items in these three buckets.
Concrete bullet items must also appear in the main-agent response table.

##### Evidence
- `<path>:<line>` - <evidence>

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| <reviewer> | <finding> | <counterexample being handled or rejected> | blocking | accept / reject / defer | <evidence> | <action> | <follow-up> |

### Closure Status

- Blocking findings found: yes / no
- Accepted blocking findings fixed: yes / no / n/a
- Blocking re-review completed: yes / no / n/a
- Blocking re-review passed: yes / no / n/a
- Blocking re-review round links:
  - <Round N or n/a>
- Blocking re-review launch records:
  - <Reviewer Launch Records row or n/a>
- Rejected findings backed by evidence: yes / no / n/a
- Deferred findings documented: yes / no / n/a
- Blocked reason: <reason or n/a>
- Allowed to proceed: yes / no

## Final Conclusion

<Whether the task may proceed, requires more work, is blocked, or is accepted
by explicit user risk acceptance.>
```

## Report Rules

- Record the review input before or at the time reviewers are spawned.
- Record reviewer launch records before adding reviewer outputs.
- Append reviewer outputs without rewriting them into a softer summary.
- Preserve the adversarial framing: findings should target assumptions,
  counterexamples, failure paths, and evidence gaps, not the author.
- Add main-agent response only after reading the reviewer outputs.
- If a new round is needed, append `## Round 2`, `## Round 3`, and so on.
- Each accepted blocking finding must link to a follow-up round and launch
  record before the report can be marked `passed`.
- Keep the report in `/vs_review/` and commit it with the related work.
