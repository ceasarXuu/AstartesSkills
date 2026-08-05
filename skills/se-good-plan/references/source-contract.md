# SE Good Plan Source Contract

This file defines behavior that must remain stable across future edits.

## Trigger And Honesty Contract

The skill triggers for implementation, refactor, migration, rollout, bug-fix,
performance, security, DevOps / CI/CD, release, technical execution, plan
decomposition, over-engineering review, validation review, stale-plan review,
and existing-plan review. It must not invent architecture, scale, schedules,
staffing, deadlines, or release commitments.

## Executable Closed-Loop Unit Contract

Every work unit identifies a concrete location, named object, one action,
resulting behavior, specific Benefit, Side Effects, exact verification, and a
safe-stop boundary. Each unit has one primary objective and change axis and is
independently inspectable, verifiable, and stoppable.

## Minimum Necessary Construction Contract

Plans prefer delete/simplify, change, reuse, and narrow local logic before new
abstractions, dependencies, state, or infrastructure. Current confirmed need or
risk is required for interfaces, factories, providers, registries, switches,
states, branches, caches, queues, jobs, schemas, dependencies, or frameworks.
Speculative future use is insufficient. Temporary construction needs retirement
criteria and cleanup.

## Benefit And Side Effects Contract

Benefit connects technical behavior to wider project value and cannot be generic
or duplicate Resulting Behavior.

Side Effects are expected costs even when work succeeds, distinct from uncertain
Risks and recovery. Each unit covers:

- **Complexity:** code/files/concepts/abstractions/states/branches/dependencies/
  configuration/schema/runtime paths/temporary logic added or removed.
- **Reach / cost:** affected modules/callers/data/tests/builds/CI/deployment/
  resources/security/operations/support/ownership/cognitive load/cleanup.

Generic no-impact wording is invalid.

## Minimum Sufficient Pre-Investment Validation Contract

When a critical unknown could invalidate substantial later work, the plan must
validate before expensive, broad, irreversible, or dependency-sensitive
implementation. Already evidenced, narrow, reversible work does not require a
ceremonial validation phase.

Validation proves only that the direction is sufficiently credible to justify
formal investment. It does not prove complete implementation, full correctness,
or production readiness.

Each validation item states:

- critical assumption and decision unlocked;
- cheapest credible method and evidence level: Static, Observed, Mock, Sandbox,
  Prototype, or Production;
- enough-evidence threshold and what remains intentionally unproven;
- bounded budget, allowed artifacts, and forbidden production changes;
- stop condition and cleanup or promotion path;
- status: `planned`, `direction-supported`, `direction-rejected`, `inconclusive`,
  or `budget-exhausted`.

Validation must prefer existing/read-only evidence, then isolated scripts or
sandbox spikes. It must not silently modify production entry points, schemas,
defaults, deployment routes, long-lived configuration, or public abstractions.
When credible validation approaches formal implementation cost or scope, it must
be narrowed or reclassified as an implementation unit.

Mock, Sandbox, and Prototype evidence cannot satisfy production integration or
runtime-verification status. `direction-supported` never means implemented.

## Evidence Supersedes Plan Contract

Verified current code, tests, logs, data, dependency behavior, and runtime
observations outrank plan assumptions and preplanned order. Material conflicts
pause affected downstream work until reconciliation.

## Phase Reconciliation Contract

After every material phase in Execution Tracking and before the next phase, the
plan must reconcile:

- new evidence and evidence level;
- affected assumptions and prior conclusions;
- conclusion status: `current`, `qualified`, `superseded`, `invalidated`, or
  `needs-revalidation`;
- impact on Benefit, Side Effects, cost, risk, dependencies, and priority;
- downstream work to continue, revise, split, remove, add, reorder, pause, or stop;
- plan validity: `valid`, `valid-with-qualifications`, `needs-revision`, or
  `invalidated`;
- next action: `continue`, `revise`, `pause`, or `stop`.

Phase completion does not imply downstream-plan validity. `needs-revision` or
`invalidated` cannot continue unchanged. When no material evidence changed, the
reconciliation may state that explicitly and continue.

## Plan Revision Traceability Contract

Plan updates preserve the prior conclusion and evidence history. The agent marks
old conclusions qualified, superseded, invalidated, or needing revalidation and
records the evidence and downstream changes. Silent history rewriting is invalid.

## State Separation Contract

- Plan Authoring: `planned`, `blocked-on-discovery`, `deferred`.
- Pre-investment validation: `planned`, `direction-supported`,
  `direction-rejected`, `inconclusive`, `budget-exhausted`.
- Execution Tracking: `not-started`, `in-progress`, `verified`, `blocked`,
  `failed`, `rolled-back`.
- Plan validity: `valid`, `valid-with-qualifications`, `needs-revision`,
  `invalidated`.
- Discovery/design artifacts: `planned`, `drafted`, `reviewed`, `verified`.
- Code implementation: `planned`, `implemented`, `integrated`,
  `runtime-verified`.

These models must not be mixed.

## Proportional Output Contract

Use the smallest shape preserving clarity. Pre-investment validation appears
only for material uncertainty. Reconciliation appears only in Execution Tracking
for material phases. Do not restore fixed oversized templates.

## Work Unit Contract

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

## Pre-Investment Validation Contract Shape

```markdown
| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
```

## Phase Reconciliation Contract Shape

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|
```

## Engineering Safety Contract

Production work includes release, rollback/fallback, observability, and
post-release validation. Data work includes idempotency, retry/resume,
validation, and compensation. Security work includes permissions,
sensitive-data handling, abuse cases, audit logging, and review.

## Behavioral Validation Contract

Tests validate representative outputs, not only keywords. The validator rejects:

- vague or coupled work units, generic Benefits, or incomplete Side Effects;
- speculative construction without current need;
- material uncertainty with no pre-investment validation;
- heavy, unbounded, production-polluting, or implementation-status validation;
- completed material execution with no reconciliation;
- continuing unchanged when plan validity needs revision or is invalidated;
- conclusion updates without traceable validity status;
- mixed plan, validation, execution, artifact, and code states.

It accepts concise authoring plans with bounded sufficient validation and concise
execution reports whose next actions follow current evidence.
