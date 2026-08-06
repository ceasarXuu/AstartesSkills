# SE Good Plan Source Contract

This file defines behavior that must remain stable across future edits.

## Trigger And Honesty Contract

The skill triggers for implementation, refactor, migration, rollout, bug-fix,
performance, security, DevOps / CI/CD, release, technical execution, plan
decomposition, decision-baseline review, validation review, stale-plan review,
and existing-plan review. It must not invent architecture, scale, schedules,
staffing, deadlines, release versions, or release commitments.

## Required Topic Artifact Contract

A formal repository plan maintains exactly two required topic artifacts:

```text
docs/releases/<confirmed-version>/<topic-slug>/
├── decisions.md
└── plan.md
```

The release version is resolved from the user, repository release documentation,
or an explicit project decision. The agent must not invent a version. Both files
are updated in place for the topic lifecycle; parallel copies such as
`plan-v2.md`, `final-plan.md`, or duplicate decision baselines are invalid.

The two files are independent and cross-linked:

- `decisions.md` links `./plan.md`.
- `plan.md` links `./decisions.md`.
- `plan.md` lists applicable active decision IDs.
- `plan.md` contains `## Design` and `## Work Units`.
- The full product decision baseline must not be merged into `plan.md`.

Other research, review, or supporting artifacts are optional and created only
when required by the work.

## Product Decision Baseline Contract

`decisions.md` records only important product-logic decisions whose silent change
would alter user intent, product behavior, scope boundaries, priority rules, or
important invariants.

The baseline uses:

```markdown
| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
```

Decision statuses are `proposed`, `active`, and `superseded`.

- Only decisions explicitly confirmed by the user may be `active`.
- Agent inference remains `proposed`.
- Every active decision states Must Do, Must Not Do, rationale, a detectable
  violation signal, and confirmation evidence.
- Ordinary implementation details, coding rules, generic risks, and speculative
  future requirements do not belong in the baseline.
- The baseline is read before authoring or revising the plan, before starting a
  material phase, and during phase reconciliation.

Verified engineering evidence may invalidate the technical plan, but it cannot
silently rewrite active user decisions. A conflict pauses affected downstream
work, records the affected IDs and plan impact, proposes a decision change, and
requires user confirmation. The old decision is preserved as `superseded`; it is
not deleted or silently overwritten.

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
formal investment. It states the critical assumption, unlocked decision,
cheapest credible method and evidence level, enough-evidence threshold, unproven
scope, bounded budget, allowed artifacts, forbidden production changes, stop
condition, cleanup/promotion path, and validation status.

Validation prefers existing/read-only evidence, isolated scripts, and sandbox
spikes. It must not silently modify production entry points, schemas, defaults,
deployment routes, long-lived configuration, or public abstractions. When
validation approaches formal implementation scope, it is narrowed or
reclassified as an implementation unit.

Mock, Sandbox, and Prototype evidence cannot satisfy production integration or
runtime-verification status. `direction-supported` never means implemented.

## Evidence And Decision Authority Contract

Verified current code, tests, logs, data, dependency behavior, and runtime
observations outrank stale technical assumptions and preplanned order.

Active product decisions remain authoritative until the user confirms a change.
Evidence-plan conflict triggers technical reconciliation. Evidence-decision
conflict triggers pause and user reconfirmation; the agent cannot lower or remove
the product constraint on its own.

## Phase Reconciliation Contract

After every material phase in Execution Tracking and before the next phase, the
plan reconciles:

- new evidence and evidence level;
- affected assumptions and prior conclusions;
- decision-baseline impact: aligned, conflict-found, change-proposed, or
  re-confirmation-required;
- conclusion status: `current`, `qualified`, `superseded`, `invalidated`, or
  `needs-revalidation`;
- impact on Benefit, Side Effects, cost, risk, dependencies, and priority;
- downstream work to continue, revise, split, remove, add, reorder, pause, or stop;
- plan validity and next action.

A decision-baseline conflict cannot continue unchanged. Phase completion does not
imply downstream-plan validity.

## Plan Revision Traceability Contract

Plan updates preserve prior conclusions and evidence history. Decision updates
preserve prior rows and confirmation history. Silent history rewriting is
invalid in either artifact.

## State Separation Contract

- Plan Authoring: `planned`, `blocked-on-discovery`, `deferred`.
- Pre-investment validation: `planned`, `direction-supported`,
  `direction-rejected`, `inconclusive`, `budget-exhausted`.
- Execution Tracking: `not-started`, `in-progress`, `verified`, `blocked`,
  `failed`, `rolled-back`.
- Plan validity: `valid`, `valid-with-qualifications`, `needs-revision`,
  `invalidated`.
- Product decisions: `proposed`, `active`, `superseded`.
- Discovery/design artifacts: `planned`, `drafted`, `reviewed`, `verified`.
- Code implementation: `planned`, `implemented`, `integrated`,
  `runtime-verified`.

These models must not be mixed.

## Proportional Output Contract

The two topic artifacts are mandatory for formal repository plans. Additional
artifacts are not. Pre-investment validation appears only for material
uncertainty. Reconciliation appears only in Execution Tracking for material
phases. Do not restore fixed oversized templates.

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
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
```

## Behavioral Validation Contract

Tests validate representative outputs and topic artifact bundles. The validator
rejects:

- missing `decisions.md` or `plan.md`;
- topic artifacts outside `docs/releases/<confirmed-version>/<topic-slug>/`;
- missing cross-links, `## Design`, `## Work Units`, or applicable decision IDs;
- an active decision without user confirmation;
- a plan that embeds the full product decision baseline instead of keeping it
  independent;
- vague or coupled work units, generic Benefits, or incomplete Side Effects;
- material uncertainty with no bounded validation;
- shadow implementation or invalid validation evidence;
- completed material execution with no reconciliation;
- continuing unchanged after invalidating evidence or decision conflict;
- silent conclusion or decision-history rewriting.

It accepts concise, cross-linked topic artifacts whose active decisions are
user-confirmed and whose plan design and work units remain aligned with them.
