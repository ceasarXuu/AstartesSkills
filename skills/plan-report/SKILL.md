---
name: plan-report
description: Use when the user asks to report, summarize, audit, or present the implementation result of a plan, roadmap, PRD, engineering plan, refactor plan, migration plan, release plan, or task list. Produces evidence-based completion reports with overall, stage, and module completion percentages; goal-to-result verification tables; explicit concrete engineering benefits; unfinished-work impact analysis; and concrete next actions, using tables and charts instead of vague prose.
---

# Plan Report

## Purpose

Use this skill to turn an implementation plan and the actual project state into
a factual completion report.

The report must answer what was planned, what was actually implemented, how
completion was calculated, what remains unfinished, why it remains unfinished,
what concrete engineering benefits were achieved or not verified, what impact
unfinished work creates, and what should happen next.

## Core Rules

- Start from the real artifact state, not from the plan author's intent.
- Treat code, tests, docs, configs, migrations, CI, logs, runbooks, screenshots,
  commands, and review records as evidence. Do not infer completion from names,
  comments, placeholders, TODOs, demos, mocks, or unused scaffolds.
- Distinguish planned, implemented, integrated, tested, documented, released,
  observed, and verified states.
- Use percentages only when the denominator is explicit. If a stage has five
  modules and three are fully verified, the stage is 60 percent complete.
- Count partial work as the verified fraction of its declared acceptance
  criteria. If the fraction cannot be defended from evidence, mark it
  `unverified` instead of guessing.
- Use `0%`, `25%`, `50%`, `75%`, or `100%` as the default module scoring scale
  unless the plan defines a more precise scoring model.
- Do not call any item complete unless its acceptance criteria are implemented
  and verified.
- Do not hide unfinished work inside summary prose. Every unfinished item must
  appear in the unfinished-work table.
- Every unfinished item must include a specific reason, the evidence behind that
  reason, and the likely impact if left unresolved.
- Every main goal must include at least one concrete engineering benefit, such
  as reduced latency, lower build time, fewer manual steps, improved test
  coverage, lower failure rate, clearer rollback path, reduced operational
  toil, improved maintainability, smaller blast radius, or stronger auditability.
- Engineering benefits must include a metric, baseline, target, observed result,
  and verification method when the data exists. If the data does not exist,
  mark the benefit `not verified` and state the exact missing measurement.
- Do not replace engineering benefits with generic value claims such as
  "improved quality", "better maintainability", or "higher efficiency" unless
  the report states the concrete mechanism and measurable effect.
- Do not use fuzzy completion language such as "basically complete", "main path
  complete", "mostly done", "no major gaps", "almost finished", or equivalent
  wording in any language.
- Prefer tables, matrices, and Mermaid charts. Use short notes only when a table
  cell would be too dense.
- Preserve uncertainty explicitly. Use `unknown` or `not verified` with the
  missing evidence, not optimistic wording.

## Workflow

### 1. Establish The Report Scope

Identify the plan or planned work being reported:

- plan document, issue, PRD, roadmap, task list, or user request
- reporting date
- repository, branch, commit, deployment, document set, or artifact boundary
- target audience if provided
- requested language and format constraints

If no plan document is provided, reconstruct the plan from the user's request,
commit messages, task lists, docs, or implementation notes, and mark the source
as reconstructed.

### 2. Build The Planned Work Breakdown

Create a hierarchy before calculating completion:

```text
Plan
  Stage
    Module
      Acceptance criterion or deliverable
```

Use the plan's own stages and modules when available. If the plan is not
structured, group work by user-visible capability, subsystem, or delivery phase.

For each item, record:

- expected outcome
- concrete completion evidence
- verification method
- status: `complete`, `partial`, `not started`, `blocked`, `deferred`,
  `removed from scope`, or `not verified`
- score and scoring rationale

### 3. Inspect Actual Artifacts

Gather evidence from the actual project, not from memory:

- read relevant source files, docs, tests, configs, workflows, migrations, and
  logs
- run available tests, type checks, validation scripts, builds, or smoke tests
- inspect git diff, commits, PRs, issues, or release artifacts when relevant
- inspect generated outputs or screenshots when the plan includes UI, docs,
  assets, or reports
- record commands and results in the verification table

If verification cannot be run, explain the blocker and mark the affected items
`not verified` or `partial`, depending on available evidence.

### 4. Calculate Completion

Compute module, stage, and overall completion from the leaf item scores.

Default formula:

```text
module_completion = verified_points / planned_points
stage_completion = sum(module_verified_points) / sum(module_planned_points)
overall_completion = sum(stage_verified_points) / sum(stage_planned_points)
```

Use equal weights unless the plan provides explicit weights or clearly
different acceptance criteria counts. If weighted scoring is used, show the
weights.

Do not average rounded percentages if the raw numerator and denominator are
available. Calculate from points first, then round the displayed percentage.

### 5. Produce The Report

Use `references/report-template.md` as the default report structure. Preserve
the required sections unless the user explicitly asks for a shorter report.

The report must include:

- overall completion percentage and scoring basis
- stage completion table with percentages
- module completion table for every stage
- chart of stage or module completion
- Goal Alignment Matrix covering main goals and subgoals
- Engineering Benefit Matrix with concrete benefits, metrics, baselines,
  targets, observed results, and verification status
- evidence and verification matrix
- unfinished-work table with reason, evidence, and impact
- recommended next actions with owner, priority, dependency, and verification
  method when known

## Completion Scoring Scale

| Score | Meaning | Allowed Evidence |
|---:|---|---|
| 0% | No implemented artifact found, or only an idea/TODO exists. | Missing file, unimplemented path, TODO-only note, not started task. |
| 25% | Artifact exists but is isolated, scaffolded, or not integrated. | Skeleton, interface, placeholder, draft doc, local-only script. |
| 50% | Implementation is materially present but incomplete or unverified. | Partial code path, incomplete acceptance criteria, missing tests, unresolved review item. |
| 75% | Implementation is complete for the main criteria but has a concrete missing verification, docs, release, observability, or edge-case gap. | Passing narrow test with missing regression, merged code without release proof, docs missing for operator flow. |
| 100% | Acceptance criteria are implemented, integrated, and verified with cited evidence. | Passing tests, command output, code reference, release artifact, log, screenshot, review closure. |

## Evidence Rules

Use evidence labels in tables:

| Label | Meaning |
|---|---|
| `code` | Source file, function, module, config, migration, workflow, or generated artifact. |
| `test` | Unit, integration, E2E, smoke, regression, validation, or manual test result. |
| `runtime` | Logs, traces, metrics, deployed behavior, screenshots, or command output. |
| `doc` | User docs, runbooks, release notes, design docs, or PRD updates. |
| `review` | Code review, adversarial review, QA sign-off, product sign-off, or incident review. |

Every completed item should have at least one implementation evidence label and
one verification evidence label. If it does not, it cannot score 100%.

## Engineering Benefit Rules

Use this table to classify engineering benefits:

| Benefit Type | Concrete Examples |
|---|---|
| Performance | Lower latency, higher throughput, shorter render time, smaller bundle size. |
| Reliability | Lower error rate, fewer retries, stronger recovery, reduced incident risk. |
| Delivery speed | Faster CI, shorter release steps, fewer manual operations, easier rollback. |
| Maintainability | Removed duplicate logic, clearer module boundary, lower file complexity, simpler ownership. |
| Testability | Higher meaningful coverage, deterministic fixtures, better regression detection. |
| Observability | New logs, metrics, traces, dashboards, alert signals, or failure reasons. |
| Security / compliance | Stronger permission boundary, safer secret handling, better audit trail. |

Every engineering benefit must be tied to actual work and evidence. If the
implementation only creates the possibility of a future benefit, report it as a
next action, not as achieved benefit.

## Language And Style

- Write in the user's language unless the user requests otherwise.
- Prefer compact tables with concrete nouns and paths.
- Keep summaries short and numerical.
- Avoid motivational, promotional, or defensive language.
- Do not explain away unfinished work. State the reason and impact plainly.
- Use absolute dates when discussing reporting periods, releases, or deadlines.
