# SE Good Plan Source Contract

This file defines behavior that must remain stable across future edits.

## Trigger Contract

The skill triggers for implementation, refactor, migration, rollout, bug-fix,
performance, security, DevOps / CI/CD, release, technical execution, plan
decomposition, over-engineering review, and existing-plan review requests.

## Context Honesty Contract

The skill must not invent architecture, services, databases, scale, business
rules, schedules, staffing, deadlines, release dates, or maintenance windows.
Missing information becomes an assumption, open question, or Discovery unit.

## Executable Specificity Contract

Every work unit identifies a concrete change location, named target object, one
explicit action, resulting behavior, specific Benefit, Side Effects, exact
verification evidence, and a safe-stop or rollback boundary. Abstract statements
do not satisfy this contract by themselves.

## Smallest Closed-Loop Engineering Unit Contract

Every unit has one primary objective/invariant, change axis, and action; a
bounded change surface; explicit dependencies; independent verification; an
independent safe-stop boundary; one Benefit; and one side-effect profile. Split
independent API, data, implementation, cache, client, deployment, observability,
security, or cleanup changes.

## Minimum Necessary Construction Contract

Plans prefer, in order:

1. delete or simplify existing logic
2. change an existing path
3. reuse an existing mechanism
4. add narrow local logic
5. add a new abstraction
6. add a new dependency or stateful infrastructure

New interfaces, factories, providers, registries, configuration switches,
states, runtime branches, caches, queues, jobs, dependencies, schemas, or
frameworks require a current confirmed need or risk. Speculative future use is
not sufficient. New abstractions for one current implementation require an
explicit reason that a smaller alternative cannot satisfy.

Temporary compatibility or migration construction requires retirement criteria
and a cleanup unit. A unit is invalid when its Benefit does not justify the
complexity and continuing cost it introduces.

## Benefit Communication Contract

Every unit contains a `Benefit` understandable beyond implementation details.
It connects the technical change to a project, user, team, delivery,
reliability, maintainability, cost, support, risk, or operational outcome. It is
specific, distinguishes the unit from neighbors, and does not repeat Resulting
Behavior. Generic claims are invalid. Formal metrics are conditional on the
claim being measurable, disputed, or decision-critical.

## Side Effects Contract

Every unit contains `Side Effects`. A side effect is an expected consequence or
continuing obligation even when the change works correctly; it is not an
uncertain Risk or a Rollback action.

The field covers two minimum dimensions:

- **Complexity:** net additions/removals in code, files, concepts, abstractions,
  states, branches, dependencies, configuration, persistent structures, runtime
  paths, temporary compatibility logic, and cleanup obligations.
- **Reach / cost:** affected modules, callers, clients, data, tests, builds, CI,
  deployment, runtime resources, infrastructure spend, security/privacy,
  operations, on-call, support, documentation, ownership, and cognitive load
  when applicable.

`None`, `N/A`, `minimal impact`, `low risk`, or similarly generic wording is
invalid. A no-material-effect claim must explain why and name unchanged
relevant dimensions. Side Effects cannot merely repeat Resulting Behavior or
Benefit.

## Plan And Execution State Contract

Plan Authoring uses `planned`, `blocked-on-discovery`, or `deferred` and cannot
claim completed execution without evidence. Execution Tracking uses
`not-started`, `in-progress`, `verified`, `blocked`, `failed`, or `rolled-back`.
Proceed/pause belongs to Execution Tracking.

## Artifact And Code Status Contract

Discovery/design artifacts use `planned`, `drafted`, `reviewed`, or `verified`.
Code uses `planned`, `implemented`, `integrated`, or `runtime-verified`.
Planning artifacts cannot use production-code states, and scaffolds/mocks do not
prove production integration.

## Proportional Output Contract

Use the smallest document shape preserving clarity. Lightweight plans use 1-3
units. Standard plans add concise approach and useful phases. Full plans add only
risk-relevant data, compatibility, security, release, observability,
alternative, or decision material. Do not restore fixed oversized templates.

## Work Unit Contract

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

A valid row has one primary axis/action, a specific Benefit, and Side Effects
covering Complexity and Reach/Cost. Dependencies set order but do not justify
coupling unrelated changes.

## Phase Contract

Phases are optional sequencing/risk containers. They state entry condition,
work units, phase-local evidence, cross-unit side effects, and next-phase
condition. Cross-unit side effects capture cumulative/interacting effects or
explain why none exist beyond unit-level effects. Plan Authoring does not mark
phase evidence complete or decide proceed.

## Engineering Safety Contract

Production work includes release, rollback/fallback, observability, and
post-release validation. Data changes include idempotency, retry/resume,
validation, and compensation. Security changes include permission boundaries,
sensitive-data handling, abuse cases, audit logging, and review.

## Existing Plan Review Contract

Review leads with findings and checks vague actions, speculative construction,
missing delete/change/reuse alternatives, missing/generic Benefits or Side
Effects, hidden code/state/path growth, affected modules and costs, oversized
units, temporary logic without cleanup, mixed statuses, template bloat, missing
verification/rollback, and unsupported facts.

## Behavioral Validation Contract

Tests validate representative outputs, not only keywords. The quality validator
rejects at least:

- vague actions
- multiple primary axes/actions
- missing/generic/duplicated Benefits
- missing/generic/incomplete Side Effects
- speculative construction without a current need
- an abstraction around one current implementation without justification
- execution-complete states in Plan Authoring
- production-code states on planning artifacts

It accepts concise, concrete, minimum-necessary, independently verifiable units
with specific Benefits and explicit Complexity plus Reach/Cost Side Effects.
