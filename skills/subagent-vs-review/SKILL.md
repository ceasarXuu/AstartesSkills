---
name: subagent-vs-review
description: Use when a task needs independent adversarial review during vibe coding, design work, implementation, testing, release planning, documentation, skill creation, or agent workflow design. It uses fresh internal subagents, minimal review navigation packets, formal /vs_review/ reports, dynamic reviewer selection, and mandatory main-agent response closure.
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

## Hard Rules

1. Use the current agent runtime's internal subagent mechanism only.
2. Do not call external agents, external CLI reviewers, or third-party review
   tools as a substitute for this skill.
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
11. If fresh internal subagents are unavailable, say the review path is
    unavailable or degraded. Do not pretend independent review happened.

## Workflow

### 1. Identify The Review Target

Classify what is being reviewed:

- product design or requirement logic
- architecture plan
- code implementation
- test strategy or validation results
- logging and observability
- security, privacy, data, or permission risk
- release, migration, deployment, packaging, or operations flow
- documentation, skill, prompt, or agent workflow

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

### 4. Select Reviewers Dynamically

Choose 1-3 reviewer roles based on the target and risk. Do not always use the
same fixed set.

Read `references/reviewer-selection.md` for reviewer options and selection
rules.

### 5. Run Fresh Internal Subagents

Spawn each reviewer as a fresh internal subagent session. Do not fork the main
agent context. Pass only the review navigation packet and the required report
output contract.

For each reviewer, record a launch record in the report:

- reviewer role
- internal subagent mechanism or tool used
- session, job, or agent identifier when available
- trace source for the spawn event, transcript, notification, or equivalent
  runtime evidence when the runtime exposes one
- whether the main-agent context was forked or inherited
- what input packet was sent
- what context was explicitly excluded
- whether the reviewer had read-only instructions

Reviewer output must include:

- summary
- blocking findings
- non-blocking risks
- required fixes
- missing tests
- missing logs or observability
- evidence paths and line numbers where possible

Reviewers must be read-only. They must not edit files.

### 6. Record Reviewer Outputs

Append each reviewer result to the current round in the report. Do not rely on
terminal output or chat messages as the only record.

If a reviewer reports no blocking issues, record that explicitly.

If a reviewer was spawned for a blocking re-review, link the reviewer output to
the earlier finding and the launch record for that closure round.

### 7. Main Agent Response

The main agent must triage every finding. Use
`references/finding-triage-rubric.md`.

For each finding:

- `accept`: the finding is valid; change the plan, code, tests, logs, docs, or
  operations flow and record the action taken
- `reject`: the finding is invalid; cite evidence from code, tests, logs,
  product constraints, or user confirmation
- `defer`: the finding is valid but out of scope; explain why and where it will
  be tracked

Do not batch-dismiss findings. Do not write "handled" without evidence or an
action.

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
- Does every finding have an `accept`, `reject`, or `defer` response?
- Are rejected findings backed by evidence?
- Are deferred findings justified and tracked?
- Did accepted blocking findings receive an additional fresh review linked to a
  closure round and launch record?
