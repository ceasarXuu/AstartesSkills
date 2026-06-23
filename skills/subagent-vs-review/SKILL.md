---
name: subagent-vs-review
description: Use when a task needs independent adversarial review during vibe coding, design work, implementation, testing, release planning, documentation, skill creation, or agent workflow design. It uses fresh internal subagents, or a user-approved local CLI reviewer fallback when internal subagents are unavailable, to attack artifact assumptions, happy paths, implementation completeness, target benefit realization, user-perspective usability, failure scenarios, and evidence gaps through formal /vs_review/ reports and mandatory response closure.
---

# subagent-vs-review

## Purpose

Run adversarial review rounds with fresh internal subagents while keeping the
main task moving under an auditable review trail.

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
   main-agent responses, and closure status.
7. The report must include reviewer launch records that make freshness and
   context isolation auditable.
8. The main agent must respond to every finding with `accept`, `reject`, or
   `defer`.
9. A blocking finding that is accepted must trigger an additional fresh
   internal subagent review after the main agent responds.
10. Blocking findings should not be deferred unless the user explicitly accepts
   the risk.
11. If fresh internal subagents are unavailable, search for local CLI reviewer
    candidates, ask the user before calling one, and interrupt the review
    workflow if no approved candidate or user-recommended reviewer is
    available. Do not pretend independent review happened.
12. The adversarial stance targets the artifact, assumptions, and failure paths,
    not the authoring agent or user.
13. Reviewers must focus on high-impact failure modes. Do not inflate style
    preferences or subjective disagreement into blocking findings.
14. Reviewer timeout, loss, or unavailability is not a pass and not "no
    findings". If the primary and replacement attempts both fail, tell the user
    the review did not complete, explain why, and ask whether to try again.

## Workflow

### 1. Identify The Review Target

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
  or regression check. Benefit warnings are non-blocking because benefit tradeoffs
  belong to user decision-making and solution design.
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
- High-risk tasks: review before implementation and again after implementation.
- Accepted blocking fixes: review again after the response is implemented.

### 2. Create Or Update The Review Report

Create a project-root report:

```text
vs_review/YYYY-MM-DD-<short-topic>-review.md
```

For multiple review rounds on the same task, append new rounds to the same
report unless the review target materially changes. The report is a tracked
project artifact and should be committed with the related work.

Use `references/review-report-template.md` when writing the report.

### 3. Build A Review Navigation Packet

The input packet is a neutral navigation aid. It should tell reviewers where to
look, what changed or is proposed, and what risks to challenge.

Include:

- objective: the user or product goal
- review target: design, code area, test plan, release process, document, skill,
  or workflow
- target locations: modules, directories, files, entry points, tests, docs, or
  relevant commands
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
- assumptions to attack: inputs, states, permissions, dependencies, timing,
  ownership, invariants, or user behaviors the implementation relies on
- adversarial lenses: choose the most relevant lenses from requirements, state,
  input, concurrency, failure, data, security, usability, comprehension,
  maintenance, testing, and observability
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
   approved CLI with the same
   neutral review navigation packet, read-only instructions, and no inherited
   main-agent context. Record the mode as `approved_external_cli_substitute`.
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

### 7. Main Agent Response

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
  product constraints, or user confirmation
- `defer`: the finding is valid but out of scope; explain why and where it will
  be tracked

Do not batch-dismiss findings. Do not write "handled" without evidence or an
action. Do not treat adversarial findings as personal criticism; treat them as
attempted counterexamples against the artifact.

### 8. Blocking Closure

If any accepted finding is blocking:

1. Implement the response.
2. Run the relevant validation.
3. Append the response and validation evidence to the report.
4. Start a new fresh internal subagent review round focused on closure.
5. Record the closure review and its launch record in the same report.
6. Link the closure round back to the accepted blocking finding.

The task is not complete while an accepted blocking finding has not passed an
additional fresh review, unless the user explicitly changes the goal or accepts
the risk.

### 9. Final Response

When reporting completion to the user, include:

- report path
- reviewer roles used
- closure status
- unresolved blocking findings, if any
- tests or validations run

## Validation Checklist

Before claiming the review is complete:

- Is there a `/vs_review/` report for this review round?
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
- Are rejected findings backed by evidence?
- Are deferred findings justified and tracked?
- If the review targets implemented plan work, does the report include
  implementation completeness checks for production paths, integration entries,
  tests, runtime/log evidence, and mock/stub exposure?
- If the target claims a benefit such as speed, accuracy, cost, reliability,
  quality, throughput, conversion, usability, or operational improvement, does
  the report check baseline, target, measurement method, comparison evidence,
  and regression risk as non-blocking warnings?
- Did accepted blocking findings receive an additional fresh review linked to a
  closure round and launch record?
