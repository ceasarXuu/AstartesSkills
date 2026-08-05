---
name: subagent-vs-review
description: Use when a task needs independent adversarial review during vibe coding, design work, implementation, testing, release planning, documentation, skill creation, or agent workflow design. It runs bounded fresh reviews, grounds blocking claims in external evidence, freezes the original objective and scope, detects non-convergence and scope drift, and restores user control before additional review or repair work can continue.
---

# subagent-vs-review

## Purpose

Run bounded adversarial review rounds with fresh internal subagents while keeping
the main task moving under an auditable review trail and a deterministic review
governor.

Use this skill when:

- vibe coding needs an independent challenge before or after implementation
- a design, plan, prompt, workflow, release process, or skill needs review
- code changes affect architecture, state, data, permissions, tests, logging, or
  long-term maintainability
- the user asks for adversarial review, subagent review, anti-self-deception
  testing, or independent review inside the current agent system

The goal is not to ask another agent to confirm the main agent's view. The goal
is to create a fresh, isolated reviewer session that receives only a neutral
review navigation packet, inspects the target directly, and records findings in
a formal project report.

Freshness reduces confirmation bias, but fresh reviewer reasoning is not
independent external evidence. The main agent, reviewer, generated code, and
generated tests can still form a closed self-reinforcing loop. This skill
therefore bounds automatic rounds, freezes the original control contract,
classifies evidence authority, detects scope drift, and requires user decisions
when the workflow no longer converges safely.

Adversarial review means the reviewer cooperates with the authoring agent while
opposing the artifact's assumptions, happy paths, hidden risks, and failure
claims. The reviewer should temporarily act like a bug, attacker, incident
responder, confused user, and future maintainer to test whether the target
still holds under misuse, failure, ambiguity, and change.

For user-facing artifacts, the review must explicitly challenge usability, ease
of use, and ease of understanding. A technically correct solution is not closed
when a realistic user cannot understand what to do, complete the intended flow,
recover from mistakes, or map the artifact's wording and controls to the real
goal.

## Hard Rules

1. Prefer the current agent runtime's internal subagent mechanism.
2. Do not call external agents, external CLI reviewers, or third-party review
   tools while internal subagents are available, or without explicit user
   approval for the exact local CLI command.
3. Each reviewer must be a fresh session. Do not inherit the main agent's full
   context, chat history, reasoning, failed attempts, drafts, or conclusions.
4. The main agent must send a review navigation packet, not a diff dump or a
   persuasion brief.
5. Every review round must maintain a Markdown report under `/vs_review/` in the
   target project repository.
6. The report must include review input, reviewer selection, reviewer outputs,
   main-agent responses, review-governor decisions, convergence status, and
   closure status.
7. The report must include reviewer launch records that make freshness and
   context isolation auditable.
8. The main agent must respond to every finding with `accept`, `reject`, or
   `defer`.
9. Default automatic review budget is exactly 2 total rounds: one initial review
   and, only when needed, one focused blocking-closure review.
10. A third or later round must never start automatically. It requires explicit
    user approval for that additional round after the user sees the convergence
    reflection, remaining blockers, scope growth, side effects, and rollback
    options.
11. A blocking finding that is accepted may trigger the single automatic
    closure round only when the review governor confirms budget, evidence,
    closure relevance, and scope safety.
12. Blocking findings should not be deferred unless the user explicitly accepts
    the risk.
13. Closure review is not a second full-system review. A closure blocker is
    admissible only when it proves the original blocker remains open, the fix
    directly introduced a regression, or the fix exposes an immediately
    adjacent failure that directly breaks the frozen objective.
14. A reviewer-only claim is an E4 hypothesis. E4 reasoning alone must not
    authorize scope expansion, new dependencies, public API changes, persistent
    data changes, new cross-module abstractions, or work outside frozen target
    locations.
15. The review governor must stop automatic modification when scope drift,
    repeated failure classes, net blocker growth, insufficient external
    evidence, or round-budget exhaustion is detected.
16. When automatic work stops, use `Status: blocked` and record a control outcome
    such as `non-convergent`, `scope-drift-detected`, `evidence-insufficient`,
    `goal-redefinition-required`, or `user-decision-required`. Do not disguise
    the stop as a successful review.
17. If fresh internal subagents are unavailable, search for local CLI reviewer
    candidates, ask the user before calling one, and interrupt the review
    workflow if no approved candidate or user-recommended reviewer is
    available. Do not pretend independent review happened.
18. The adversarial stance targets the artifact, assumptions, and failure paths,
    not the authoring agent or user.
19. Reviewers must focus on high-impact failure modes. Do not inflate style
    preferences or subjective disagreement into blocking findings.
20. Reviewer timeout, loss, or unavailability is not a pass and not "no
    findings". If the primary and replacement attempts both fail, tell the user
    the review did not complete, explain why, and ask whether to try again.

## Evidence Authority

Classify every blocking or scope-expanding claim:

| Level | Source | Authority |
|---|---|---|
| E0 | explicit user instruction or user confirmation | authoritative for goal, scope, tradeoffs, and risk acceptance |
| E1 | PRD, issue, plan, ADR, repository policy, or project documentation | authoritative for documented project intent and constraints |
| E2 | direct runtime behavior, reproducible test, logs, production path, or observed failure | authoritative for actual system behavior |
| E3 | official documentation, standard, protocol, or other authoritative external source | authoritative for external facts and platform constraints |
| E4 | reviewer or main-agent reasoning, generated code, generated tests, or inferred best practice | hypothesis that requires validation |

Use the strongest relevant evidence. Network research is appropriate for
external facts, API semantics, standards, and platform constraints, but it must
not override explicit user or project scope with generic best practices.

## Review Control Contract

Before Round 1, freeze and record:

- original objective
- acceptance criteria
- explicit non-goals
- target locations and baseline revision
- allowed change categories
- prohibited or approval-required changes
- authoritative project sources
- automatic round budget, normally `2`
- rollback checkpoint
- expected benefit and acceptable side effects

A reviewer may challenge this contract, but the agent may not silently rewrite
it. Any material goal, acceptance, scope, or tradeoff change requires E0 user
confirmation or clear E1 project authority.

## Workflow

### 1. Identify And Freeze The Review Target

Classify what is being reviewed:

- product design or requirement logic
- user experience, usability, onboarding, or comprehension logic
- architecture plan
- code implementation
- test strategy or validation results
- logging and observability
- security, privacy, data, or permission risk
- release, migration, deployment, packaging, or operations flow
- documentation, skill, prompt, or agent workflow

Identify what the reviewer must try to disprove:

- misunderstood requirements or missing implicit constraints
- user-visible flows, instructions, labels, states, or defaults that are hard to
  use, hard to understand, or easy to misread
- plan-to-code completeness gaps where work stops at protocols, interfaces,
  schemas, entry points, scaffolding, mock or fake data, demo scripts, or
  test-only wiring instead of production-path implementation
- target-benefit warnings where the artifact claims speed, accuracy, cost,
  reliability, quality, throughput, conversion, usability, or operational
  benefit but lacks a baseline, target, measurement method, comparison evidence,
  or regression check. Benefit warnings are non-blocking because benefit
  tradeoffs belong to user decision-making and solution design.
- assumptions that may be false in real inputs, real state, or real users
- happy-path-only behavior
- invalid, empty, duplicated, unordered, hostile, or extreme inputs
- impossible-but-observable states
- concurrency, retry, idempotency, timeout, partial-success, rollback, cache, or
  transaction failures
- dirty, lost, duplicated, inconsistent, or leaked data
- permission, injection, secret, privacy, or trust-boundary failures
- future maintenance and extension costs
- tests or logs that prove only the main agent's narrative, not the real system

Decide whether the review should happen before work, after work, or both:

- Design and planning tasks: review before the plan is treated as settled.
- Normal code tasks: review after implementation and local validation.
- High-risk tasks: review before implementation and after implementation only
  when both rounds fit the predeclared budget.
- Accepted blocking fixes: use the one focused closure round when permitted by
  the review governor.

### 2. Create Or Update The Review Report

Create a project-root report:

```text
vs_review/YYYY-MM-DD-<short-topic>-review.md
```

For multiple review rounds on the same task, append new rounds to the same
report unless the review target materially changes. A material target change is
not another closure round; stop and obtain a user decision or start a separately
authorized task. The report is a tracked project artifact and should be
committed with the related work.

Use `references/review-report-template.md` and
`references/review-governor.md`.

### 3. Build A Review Navigation Packet

The input packet is a neutral navigation aid. It should tell reviewers where to
look, what changed or is proposed, and what risks to challenge.

Include:

- objective: the frozen user or product goal
- acceptance criteria and explicit non-goals
- review target: design, code area, test plan, release process, document, skill,
  or workflow
- target locations: modules, directories, files, entry points, tests, docs, or
  relevant commands
- baseline revision and rollback checkpoint
- change introduction: a neutral description of the direction or modification
- risk focus: assumptions, boundaries, failure modes, and user constraints to
  challenge
- user-perspective focus: usability, ease of use, ease of understanding,
  onboarding, wording, feedback, recovery paths, and realistic user behaviors
- implementation-completeness focus: planned items, expected behaviors,
  production code paths, integration entries, test evidence, runtime or log
  evidence, mock or stub exposure, and known unlanded work
- target-benefit focus: claimed speed, accuracy, cost, reliability, quality,
  throughput, conversion, usability, or operational benefit, including baseline,
  target, measurement method, comparison evidence, and possible regressions
- evidence sources: known E0-E3 sources and known evidence gaps
- assumptions to attack: inputs, states, permissions, dependencies, timing,
  ownership, invariants, or user behaviors the implementation relies on
- adversarial lenses: choose the most relevant lenses from requirements, state,
  input, concurrency, failure, data, security, usability, comprehension,
  maintenance, testing, and observability
- round type: `initial`, `closure`, or `user-approved-extra`
- closure scope when applicable: earlier finding IDs and permitted causal area
- verification status: tests, smoke checks, logs, runtime validation, or known
  unverified areas
- reviewer instructions: fresh session, read targets directly, do not modify
  files, cite evidence paths and line numbers when possible

Do not include:

- full conversation history
- hidden reasoning or chain-of-thought
- conclusions like "this is already fixed"
- arguments written to convince reviewers
- full diffs by default
- large code excerpts unless the reviewer cannot access the repository
- reviewer instructions that ask for confirmation instead of falsification

### 4. Select Reviewers Dynamically

Choose exactly 1 reviewer role per review round based on the target and risk.
Do not launch a panel by default; prior multi-reviewer rounds often produced
similar findings, so one focused fresh reviewer is the normal review unit.

Read `references/reviewer-selection.md` for reviewer options and selection
rules.

### 5. Run Fresh Reviewers

Spawn each reviewer as a fresh internal subagent session. Do not fork the main
agent context. Pass only the review navigation packet and the required report
output contract.

If the current runtime cannot spawn fresh internal subagents:

1. Record the internal subagent path as unavailable in the report.
2. Search the local machine for reviewer CLI candidates across the four
   supported families with bounded discovery commands such as
   `command -v claude`, `command -v claude-code`, `command -v codex`,
   `command -v codex-cli`, `command -v opencode`, and `command -v pi`.
3. If one or more candidates are discovered, show the user the command paths
   and the proposed reviewer role.
4. Ask for explicit approval before invoking any local CLI reviewer.
5. If no candidate is discovered, ask the user whether another local agent is
   available. Require the exact command or executable path, verify it with
   `command -v` or an executable-path check, and ask for explicit approval for
   that exact command before use.
6. If the user approves one candidate or verified recommendation, run only that
   approved CLI with the same neutral review navigation packet, read-only
   instructions, and no inherited main-agent context. Record the mode as
   `approved_external_cli_substitute`.
7. If no candidate is available, the user has no other available agent, the
   user-recommended command cannot be verified, or the user does not approve,
   stop the review workflow, record `blocked_due_to_review_unavailable`, and
   tell the user the review did not run.

Local CLI substitutes are degraded replacements for unavailable internal
subagents. They may use Claude, Codex, OpenCode, Pi, or a verified
user-recommended local agent only after user approval, and they must not receive
hidden reasoning, full chat history, or persuasive summaries.

Set a timeout policy before spawning reviewers:

- `simple`: 3-5 minutes for one small file, short doc, or narrow question
- `normal`: 8-12 minutes for ordinary multi-file work or normal design review
- `complex`: 15-25 minutes for architecture, security, payment, state machine,
  release, migration, or multi-module review
- `high-risk`: 20-30 minutes for accepted blocking closure, production-impact,
  data, security, or operational review

Each reviewer role gets at most two automatic fresh-session attempts:

1. Primary reviewer.
2. Replacement reviewer if the primary times out, is lost, or becomes stuck.

Attempts are not rounds. Replacing a failed session does not consume another
review round, but a completed reviewer result does.

After the primary timeout, allow either one bounded extension or direct
replacement:

- Extend once only when the reviewer appears alive and the task was likely
  underestimated. Keep the extension at roughly 50%-100% of the initial wait.
- Replace immediately when the session is lost, `not_found`, visibly stuck, or
  the runtime is blocking progress.
- Do not keep waiting on `close_agent` or equivalent cleanup if it blocks the
  main task. Close only completed reviewers when needed to free capacity.

If the replacement also times out or is unavailable:

- record the role as `degraded` or `blocked_due_to_review_unavailable`
- do not mark the reviewer as completed
- do not write `none` or `no findings` for that reviewer
- tell the user the review did not successfully complete, include the reason,
  and ask whether to try again, narrow the scope, change reviewer type, or
  explicitly accept the risk
- for accepted blocking closure reviews, do not mark the task `passed` unless
  the user explicitly accepts the risk

For each reviewer, record a launch record in the report:

- reviewer role
- internal subagent mechanism or approved local CLI command used
- session, job, or agent identifier when available
- trace source for the spawn event, transcript, notification, or equivalent
  runtime evidence when the runtime exposes one
- whether the main-agent context was forked or inherited
- what input packet was sent
- what context was explicitly excluded
- whether the reviewer had read-only instructions
- whether the reviewer used internal subagent mode or
  `approved_external_cli_substitute`, including user approval evidence for the
  latter

For each reviewer attempt, record a timeout record. Use the same reviewer role
as the launch row. Only `completed`, `completed_after_extension`, and
`late_result` attempts may have reviewer output blocks. Timeout, loss,
superseded, degraded, and unavailable attempts must not be represented as
`none` findings.

Reviewer output must include:

- summary
- blocking findings
- non-blocking risks
- user-perspective checks for usability, ease of use, and ease of understanding
- implementation completeness checks for plan-item coverage, production code
  paths, integration entries, test evidence, runtime or log evidence, and mock
  or stub exposure
- target benefit checks for claimed benefits, baselines, targets, measurement
  method, comparison evidence, and regressions or neutral outcomes
- evidence authority level for each blocking or scope-expanding claim
- closure relation for closure-round findings
- required fixes
- missing tests
- missing logs or observability
- evidence paths and line numbers where possible

For each blocking or major finding, reviewers must state the counterexample
inline with that finding:

- broken assumption
- failure scenario
- trigger condition or misuse case
- likely impact or blast radius
- proof needed, such as a test, log, runtime check, or product decision
- evidence authority level and source
- closure relation: `original-blocker-open`, `fix-regression`,
  `direct-adjacent-objective-failure`, `unrelated-existing-risk`, or `n/a`
- plan item and production path affected, when the finding challenges
  implementation completeness
- claimed benefit, baseline, target, and measured result affected, when the
  finding challenges target benefit realization. Benefit-realization findings
  must be recorded as non-blocking warnings unless the same evidence also proves
  a separate correctness, security, data, reliability, or operational failure.

Reviewers must be read-only. They must not edit files.

### 6. Record Reviewer Outputs

Append each reviewer result to the current round in the report. Do not rely on
terminal output or chat messages as the only record.

If a reviewer reports no blocking issues, record that explicitly.

If a reviewer was spawned for a blocking re-review, link the reviewer output to
the earlier finding and the launch record for that closure round.

If a timed-out reviewer later returns, append it as a late result and triage any
findings. Late results must not erase the replacement review or rewrite the
timeout history.

Timeout record actions must use one of: `completed`, `extended`,
`replacement spawned`, or `user decision required`. Use
`completed_after_extension` when a first attempt timed out, received its single
bounded extension, and then completed.

### 7. Main Agent Triage And Scope Impact

The main agent must triage every finding. Use
`references/finding-triage-rubric.md`.

Reviewer findings should appear in `Blocking Findings` or `Non-blocking Risks`.
If `Required Fixes`, `Missing Tests`, or `Missing Logs / Observability`
contains a concrete actionable item, write it as a flush-left single-line
`- ` bullet and triage that item too.

For each finding:

- `accept`: the finding is valid; change the plan, code, tests, logs, docs, or
  operations flow and record the action taken
- `reject`: the finding is invalid; cite evidence from code, tests, logs,
  product constraints, official sources, or user confirmation
- `defer`: the finding is valid but out of scope; explain why and where it will
  be tracked

Also record:

- evidence authority and whether it is sufficient for the proposed action
- relationship to the frozen objective and current closure scope
- files and modules newly touched
- code, dependency, API, data, operational, maintenance, and testing side effects
- rollback plan and last known-good checkpoint
- whether the action needs user approval before implementation

Do not batch-dismiss findings. Do not write "handled" without evidence or an
action. Do not treat adversarial findings as personal criticism; treat them as
attempted counterexamples against the artifact.

### 8. Run The Review Governor

Before any accepted finding causes modification, and again before any new round,
apply `references/review-governor.md`.

The governor must return exactly one workflow decision:

- `continue-current-round`
- `start-closure-round`
- `pass`
- `stop-scope-drift`
- `stop-evidence-insufficient`
- `stop-non-convergent`
- `rollback-evaluation-required`
- `user-decision-required`

Stop automatically when any of these conditions holds:

- two completed automatic rounds have already run
- a closure finding is unrelated to the accepted blocker
- a scope-expanding action is supported only by E4 reasoning
- a new top-level module, dependency, public API, persistent data format, or
  cross-module abstraction would be introduced without E0 or E1 authority
- the same failure class appears in two completed rounds
- unresolved blocker count does not decrease
- fixes introduce more blockers than they close
- cumulative scope or complexity growth is no longer justified by the frozen
  objective and measured benefit
- the original objective, acceptance criteria, or non-goals need reinterpretation

When stopped, do not make another speculative repair. Record the reason, preserve
the last known-good checkpoint, evaluate rollback, and ask the user to choose
among the bounded options in the report.

### 9. Blocking Closure

If an accepted finding is blocking:

1. Confirm it is supported by sufficient E0-E3 evidence, or obtain user
   confirmation before any scope-expanding response.
2. Confirm the response remains within the frozen control contract.
3. Implement the smallest response that closes the proven failure.
4. Run the relevant validation.
5. Append the response, side effects, and validation evidence to the report.
6. Ask the review governor whether the single automatic closure round may start.
7. If permitted, run one fresh reviewer focused only on the accepted finding IDs
   and direct fix regressions.
8. Record the closure review and launch record in the same report.
9. Do not automatically fix an unrelated finding discovered during closure.
   Record it as a non-blocking or future-review candidate unless E0 or E1
   explicitly makes it part of the current objective.

The task may pass when accepted blockers are closed by the focused closure
review. If blockers remain after Round 2, automatic work is over. Record a
convergence reflection and request a user decision. Do not start Round 3 without
explicit approval.

### 10. Convergence Reflection And User Escalation

A convergence reflection is mandatory when:

- Round 2 still contains a valid blocker
- the same failure class repeats
- unresolved blockers do not decrease
- scope drift triggers
- evidence is insufficient for the proposed repair
- rollback may be safer than another patch

Record:

- original objective, acceptance criteria, and non-goals
- completed rounds and findings closed, repeated, and newly introduced
- evidence sources by E0-E4 level
- newly touched files, modules, APIs, dependencies, data, and operations
- cumulative code and complexity growth
- benefits actually achieved
- side effects and regressions introduced
- whether risk is decreasing, moving, or expanding
- last known-good checkpoint
- rollback options
- bounded user choices: accept risk, narrow scope, redefine goal, approve one
  additional round, change solution path, or roll back

Do not phrase user escalation as a generic request to "continue". Present the
specific evidence, cost, scope, and consequences of each option.

### 11. Final Response

When reporting completion or interruption to the user, include:

- report path
- reviewer roles used
- rounds used and automatic budget
- review-governor decision
- control outcome
- closure status
- unresolved blocking findings, if any
- scope growth and side effects
- external evidence used
- tests or validations run
- rollback checkpoint when not passed

## Validation Checklist

Before claiming the review is complete:

- Is there a `/vs_review/` report for this review round?
- Does the report include the frozen objective, acceptance criteria, non-goals,
  target locations, automatic round budget, and rollback checkpoint?
- Does the report include the exact review input sent to reviewers?
- Does the report include reviewer launch records with session identifiers or
  equivalent traceable handles?
- Does each launch record include a trace source when the runtime exposes one?
- Do the launch records prove reviewers avoided inherited main-agent context?
- If internal subagents were unavailable, does the report show local CLI
  discovery across Claude, Codex, OpenCode, and Pi, exact user approval,
  user-recommended agent handling when discovery found no candidates, or a
  blocked workflow when no approved reviewer was available?
- Does every finding have an `accept`, `reject`, or `defer` response?
- Does every blocking or scope-expanding claim record E0-E4 authority?
- Are rejected findings backed by evidence?
- Are deferred findings justified and tracked?
- Did the review governor authorize every modification and additional round?
- Did the workflow stay within two automatic completed rounds?
- Is any third or later round backed by explicit user approval recorded before
  that round began?
- Are closure blockers limited to the original blocker remaining open, direct
  fix regression, or direct adjacent objective failure?
- Were unrelated closure findings prevented from automatically expanding scope?
- Were scope growth, side effects, benefit, and rollback evaluated?
- If the review targets implemented plan work, does the report include
  implementation completeness checks for production paths, integration entries,
  tests, runtime/log evidence, and mock/stub exposure?
- If the target claims a benefit such as speed, accuracy, cost, reliability,
  quality, throughput, conversion, usability, or operational improvement, does
  the report check baseline, target, measurement method, comparison evidence,
  and regression risk as non-blocking warnings?
- If blockers remain after Round 2, did the workflow stop, write a convergence
  reflection, and request a user decision instead of starting another automatic
  review?
