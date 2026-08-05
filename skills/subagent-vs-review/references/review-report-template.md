# Review Report Template

Use this structure for every subagent-vs-review report. A report may contain at
most two automatic completed rounds. A third or later round requires explicit
user approval recorded before that round begins.

```markdown
# Subagent VS Review: <topic>

- Created: <ISO 8601 local time>
- Updated: <ISO 8601 local time>
- Report schema: adversarial-v2
- Task: <user or product goal>
- Report path: `vs_review/YYYY-MM-DD-<topic>-review.md`
- Review mode: fresh internal subagents | approved_external_cli_substitute | blocked_due_to_review_unavailable
- Source session policy: no inherited main-agent context; approved CLI substitutes receive only the review packet
- Status: open | passed | blocked | accepted-risk
- Control outcome: none | non-convergent | scope-drift-detected | evidence-insufficient | goal-redefinition-required | user-decision-required
- Automatic round budget: 2
- Completed rounds: <0 | 1 | 2 | user-approved number>
- Last known-good checkpoint: <revision, commit, tag, snapshot, or n/a>

## Review Control Contract

### Frozen Objective
<Original user or product objective.>

### Acceptance Criteria
- <observable success condition>

### Explicit Non-goals
- <work that must not be silently added>

### Frozen Target Locations
- `<path, module, document, command, or bounded surface>`

### Allowed Change Categories
- <implementation, tests, docs, configuration, or other authorized category>

### Approval-required Changes
- new top-level module
- new external dependency
- public API change
- persistent data or schema change
- new cross-module abstraction
- change outside frozen target locations

### Authoritative Sources

| Authority | Source | What It Controls |
|---|---|---|
| E0 | <user instruction or confirmation> | <goal, scope, tradeoff, risk acceptance> |
| E1 | <PRD, issue, plan, ADR, policy, project document> | <project intent or constraint> |
| E2 | <runtime, test, log, production path, observed failure> | <actual behavior> |
| E3 | <official docs, standard, protocol, authoritative source> | <external fact or platform constraint> |
| E4 | <reviewer or main-agent reasoning> | hypothesis only |

### Baseline And Rollback
- Baseline revision: <revision or artifact state>
- Rollback checkpoint: <revision, commit, tag, snapshot, or command>
- Expected benefit: <measurable benefit>
- Acceptable side effects: <bounded side effects>
- Automatic round budget: 2

## Round 1: <short round purpose>

### Round Control

- Round type: initial | closure | user-approved-extra
- Round number: <N>
- Completed automatic rounds before launch: <number>
- User approval for this round: <n/a for Round 1-2 | exact approval evidence>
- Closure finding IDs: <ids or n/a>
- Permitted closure relation: original-blocker-open | fix-regression | direct-adjacent-objective-failure | n/a
- Target scope delta allowed: <none or explicitly authorized delta>

### Review Input

#### Objective
<The frozen user or product goal.>

#### Acceptance Criteria
- <observable success condition>

#### Explicit Non-goals
- <frozen non-goal>

#### Review Target
<Design, implementation, test plan, release process, document, skill, or workflow.>

#### Target Locations
- `<path or command>`
- `<path or command>`

#### Baseline And Rollback Checkpoint
- Baseline: <revision or artifact state>
- Rollback checkpoint: <revision, commit, tag, snapshot, or command>

#### Change Introduction
<Neutral description of the proposed or implemented direction.>

#### Risk Focus
- <assumption, boundary, or failure mode to challenge>

#### User-Perspective Review Focus
- <usability, ease-of-use, ease-of-understanding, onboarding, wording, feedback, recovery path, or realistic user behavior to challenge>

#### Implementation Completeness Focus
- <planned item, expected behavior, production code path, integration entry, test evidence, runtime or log evidence, mock/stub exposure, or known unlanded work to challenge>

#### Target Benefit Focus
- <claimed speed, accuracy, cost, reliability, throughput, quality, conversion, usability, or operational benefit to challenge, including baseline, target, measurement method, comparison evidence, or regression risk>

#### Evidence Sources And Gaps
- E0-E3 source: <source and relevance>
- E4 hypothesis: <claim requiring validation>
- Known evidence gap: <gap or none>

#### Assumptions To Attack
- <input, state, dependency, permission, timing, user behavior, or invariant>

#### Adversarial Lenses
- <requirements | state | input | concurrency | failure | data | security | usability | ease-of-use | comprehension | implementation-completeness | target-benefit | maintenance | testing | observability>

#### Verification Status
- <tests, smoke checks, logs, runtime validation, or known gaps>

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Classify blocking and scope-expanding claims as E0, E1, E2, E3, or E4.
- For closure rounds, classify each finding relation as
  `original-blocker-open`, `fix-regression`,
  `direct-adjacent-objective-failure`, or `unrelated-existing-risk`.
- If internal subagents are unavailable, use an approved local CLI substitute
  only after explicit user approval for the exact command.

### Internal Subagent Unavailable Fallback

- Required only when fresh internal subagents are unavailable.
- Internal subagent unavailable reason: <reason or n/a>
- Local CLI discovery commands:
  - `command -v claude`
  - `command -v claude-code`
  - `command -v codex`
  - `command -v codex-cli`
  - `command -v opencode`
  - `command -v pi`
- Discovered CLI candidates:
  - <command path or none>
- User-recommended alternative agent requested: yes / no / n/a
- User-recommended agent command: <exact command or n/a>
- User-recommended agent verification: verified / unavailable / n/a
- User approval requested: yes / no / n/a
- User-approved CLI command: <exact command or n/a>
- User decision: approved / rejected / no candidate / no alternative agent / n/a
- Fallback outcome: approved_external_cli_substitute / blocked_due_to_review_unavailable / n/a

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| simple / normal / complex / high-risk | <duration> | <none or bounded extension> | 2 | cannot pass if review is unavailable |

This section is required for current reports. Attempts are not rounds; a
completed reviewer result consumes one review round.

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| <reviewer> | <why selected> | <risk area> |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| <reviewer-role> | <subagent tool/runtime or approved local CLI command> | <id or equivalent trace handle> | <tool call, notification, transcript, CLI transcript, or unavailable> | fork_context=false or external_cli_no_context_packet_only | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

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
  - Proof needed: <test, log, runtime check, official source, or product decision>
  - Evidence authority: <E0 | E1 | E2 | E3 | E4>
  - Evidence source: <path:line, test/log, user confirmation, or official source>
  - Closure relation: <original-blocker-open | fix-regression | direct-adjacent-objective-failure | unrelated-existing-risk | n/a>
  - Scope effect: <none or proposed expansion>

##### Non-blocking Risks
- <risk, or "none">
  - Broken assumption: <assumption being challenged>
  - Failure scenario: <how the artifact may fail>
  - Trigger condition: <condition that exposes the risk>
  - Impact: <likely effect>
  - Proof needed: <evidence that would close or downgrade the risk>
  - Evidence authority: <E0 | E1 | E2 | E3 | E4>
  - Closure relation: <unrelated-existing-risk | n/a>

##### User-Perspective Checks
- Usability: <pass, risk, or finding already listed above> - Evidence or link: <path:line or finding id>
- Ease of use: <pass, risk, or finding already listed above> - Evidence or link: <path:line or finding id>
- Ease of understanding: <pass, risk, or finding already listed above> - Evidence or link: <path:line or finding id>

Actionable user-perspective issues must also appear under `Blocking Findings`
or `Non-blocking Risks` so they receive main-agent triage.

##### Implementation Completeness Checks

| Plan Item | Expected Behavior | Production Code Path | Integration Entry | Test Evidence | Runtime / Log Evidence | Mock / Stub Exposure | Status | Finding Link |
|---|---|---|---|---|---|---|---|---|
| <item> | <behavior> | <path:line or missing> | <entry or missing> | <test or missing> | <log/check/artifact or missing> | <none/test-only/blocks completion> | landed / partial / stub-only / mock-only / not-started / deferred | <finding id or none> |

Only `landed` counts as complete. Actionable implementation-completeness gaps
must also appear under `Blocking Findings` or `Non-blocking Risks` so they
receive main-agent triage. Treat protocol-only, interface-only, schema-only,
entry-only, scaffold-only, mock-only, fake-data-only, demo-script-only, and
test-only wiring as incomplete unless production-path evidence proves otherwise.

##### Target Benefit Checks

| Claimed Benefit | Baseline | Target | Measurement Method | Comparison Evidence | Result | Regression / Side Effect | Status | Finding Link |
|---|---|---|---|---|---|---|---|---|
| <benefit> | <baseline or missing> | <target or missing> | <method or missing> | <test/log/metric/artifact or missing> | achieved / neutral / regressed / unmeasured | <risk or none> | proven / weak-evidence / unmeasured / regressed / deferred | <finding id or none> |

Only `proven` means the claimed benefit is verified. Target-benefit gaps must
appear under `Non-blocking Risks` as warnings so they receive main-agent triage
without blocking closure. Treat implemented-but-unmeasured, neutral-result, and
regressed outcomes as incomplete benefit realization, but do not convert that
benefit gap into a blocking finding unless the same evidence also proves a
separate correctness, security, data, reliability, or operational failure.

##### Required Fixes
- <fix tied to a triaged finding, or "none">

##### Missing Tests
- <test gap tied to a triaged finding, or "none">

##### Missing Logs / Observability
- <observability gap tied to a triaged finding, or "none">

Use `none` or flush-left single-line `- ` items in these three buckets.
Concrete bullet items must also appear in the main-agent response table.

##### Evidence
- `<path>:<line>` - <evidence and E0-E4 authority>

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Authority | Closure Relation | Evidence / Reason | Scope Effect | Side Effects | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|---|---|---|---|
| <reviewer> | <finding> | <counterexample being handled or rejected> | blocking | accept / reject / defer | E0-E4 | <relation or n/a> | <evidence> | <files/modules/APIs/dependencies/data> | <cost, regression, maintenance, operations> | <action or stopped> | <follow-up> |

### Review Governor

- Completed rounds before decision: <number>
- Automatic round budget: 2
- Unresolved blockers before round: <number>
- Unresolved blockers after round: <number>
- Blockers closed: <ids or none>
- New blocker classes: <classes or none>
- Repeated failure class: yes / no - <class or n/a>
- Closure findings admissible: yes / no / n/a
- Scope expansion proposed: yes / no
- Scope expansion authority: <E0-E3 source or E4-only>
- New top-level modules: <none or list>
- New dependencies: <none or list>
- Public API or persistent data changes: <none or list>
- New cross-module abstractions: <none or list>
- Cumulative scope and complexity growth: <summary>
- Benefit versus side effects: <net positive, unclear, or negative with evidence>
- Rollback evaluation required: yes / no
- Governor decision: continue-current-round | start-closure-round | pass | stop-scope-drift | stop-evidence-insufficient | stop-non-convergent | rollback-evaluation-required | user-decision-required
- Decision reason: <bounded evidence-based explanation>

### Convergence Reflection

Required when blockers remain after Round 2, a failure class repeats, blockers
do not decrease, scope drifts, evidence is insufficient, or rollback may be
safer.

- Original objective:
- Acceptance criteria:
- Explicit non-goals:
- Completed rounds versus budget:
- Findings closed:
- Findings repeated:
- Findings newly introduced:
- Evidence inventory by E0-E4:
- Newly touched files and modules:
- New APIs, dependencies, data, operations, or abstractions:
- Cumulative code and complexity growth:
- Benefits actually achieved:
- Side effects and regressions:
- Risk direction: decreasing | moving | expanding | unclear
- Last known-good checkpoint:
- Rollback options:
- Recommended bounded choices:

### User Decision

Required before any third or later round or after a governor stop.

- Decision requested: accept risk | narrow scope | redefine goal | approve one additional round | change solution path | roll back
- Options and consequences:
  - <option and consequence>
- User decision: <exact decision or pending>
- Approval evidence: <quote, message reference, or n/a>
- Authorized next scope: <bounded scope or none>

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
- Implementation completeness gaps resolved or accepted by user: yes / no / n/a
- Target benefit warnings recorded: yes / no / n/a
- Automatic round budget respected: yes / no
- Third-or-later round explicitly user-approved before launch: yes / no / n/a
- Scope drift detected: yes / no
- Evidence sufficient for scope-expanding actions: yes / no / n/a
- Convergence reflection required and recorded: yes / no / n/a
- Control outcome: none | non-convergent | scope-drift-detected | evidence-insufficient | goal-redefinition-required | user-decision-required
- Blocked reason: <reason or n/a>
- Allowed to proceed: yes / no

## Final Conclusion

<Whether the task may proceed, requires more work, is blocked, is accepted by
explicit user risk acceptance, or requires a bounded user decision.>
```

## Report Rules

- Record the review control contract before Round 1.
- Record the review input before or at the time reviewers are spawned.
- Record reviewer launch records before adding reviewer outputs.
- Append reviewer outputs without rewriting them into a softer summary.
- Preserve the adversarial framing: findings should target assumptions,
  counterexamples, failure paths, and evidence gaps, not the author.
- Add main-agent response only after reading the reviewer outputs.
- Record one review-governor decision after each completed round and before any
  modification or next round.
- The default automatic budget is two completed rounds.
- Round 2 must be a focused closure review, not another full-system review.
- A third or later round requires explicit user approval recorded before launch.
- If blockers remain after Round 2, stop automatic work and write the convergence
  reflection and user decision section.
- E4 reasoning alone must not authorize scope expansion.
- Unrelated closure findings must not trigger automatic repair.
- Each accepted blocking finding must link to an authorized follow-up round and
  launch record before the report can be marked `passed`.
- Keep the report in `/vs_review/` and commit it with the related work.
