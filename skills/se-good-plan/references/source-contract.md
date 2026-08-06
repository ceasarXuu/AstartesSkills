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

The release version comes from the user, repository release documentation, or an
explicit project decision. The Agent must not invent a version. Both files are
updated in place; parallel copies are invalid.

The files are independent and cross-linked. `plan.md` contains `## Execution
Contract`, `## Design`, and `## Work Units`, and lists applicable active decision
IDs. The full product decision baseline must not be merged into `plan.md`.

Other research, review, or supporting artifacts are optional.

## Protected Product Decision Baseline Contract

`decisions.md` is a protected user-authority artifact. Its top section must state:

```markdown
> PROTECTED USER-AUTHORITY ARTIFACT
> Decisions in this file MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.

- Authority: User
- Write Gate: Explicit user approval required
- Agent Self-Approval: Forbidden
```

The baseline table is:

```markdown
| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
```

Allowed decision statuses are only `active` and `superseded`.

- Every row represents a directly user-confirmed decision.
- Confirmation preserves direct user approval evidence, not Agent inference.
- Agent inference, existing code, tests, reviews, other documents, another Agent,
  implementation success, or user silence are never approval.
- An Agent must not self-promote a product interpretation into authority.
- Replacing a decision requires explicit user approval; preserve the old row as
  `superseded` rather than rewriting history.
- Ordinary implementation details, coding rules, generic risks, and speculative
  future requirements do not belong in the baseline.

The baseline is read before authoring or revising the plan, before a material
phase, and during phase reconciliation.

## Unconfirmed Product Decision Contract

Unconfirmed product choices stay in `plan.md`, never in `decisions.md`.

A material product decision is a choice whose alternatives materially affect
user-visible behavior, product rules, core domain modeling, lifecycle/state
semantics, defaults/automation, user control/reversibility, persistence,
permissions/visibility, compatibility, external side effects, or important
limits. Product-equivalent internal implementation choices remain engineering
choices.

When a material choice is not confirmed:

- defer it if the choice can remain open;
- use `provisional` behavior only when necessary, local, reversible, and bounded;
- obtain direct user confirmation before high-impact, hard-to-reverse,
  public/persistent, or broadly depended-on behavior is implemented.

Dependent plan work may use `blocked-on-user-decision`.

## Plan Execution Contract

Every formal `plan.md` contains a short `## Execution Contract` that survives
long-running execution without relying on the Agent to reread this skill. It
states that:

- `decisions.md` is user-authority protected and Agent self-approval is forbidden;
- engineering evidence may revise the technical plan, not product authority;
- unconfirmed material choices are deferred, provisional, or user-confirmed;
- every material phase performs a bounded Product Decision Delta audit;
- delta classifications are `covered`, `engineering-only`, `provisional`, or
  `conflict`;
- unresolved material `provisional` or `conflict` blocks dependent continuation.

When unresolved choices exist, `plan.md` may contain:

```markdown
## Pending Product Decisions

| ID | Decision Surface | Current / Proposed Behavior | Why Material | Evidence | Impact If Changed |
|---|---|---|---|---|---|
```

## Executable Closed-Loop Unit Contract

Every work unit identifies a concrete location, named object, one action,
resulting behavior, specific Benefit, Side Effects, exact verification, and a
safe-stop boundary. Each unit has one primary objective/change axis and is
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
Risks and recovery. Each unit covers Complexity delta and Reach / cost.

## Minimum Sufficient Pre-Investment Validation Contract

When a critical unknown could invalidate substantial later work, validate before
expensive, broad, irreversible, or dependency-sensitive implementation. Already
evidenced, narrow, reversible work does not require ceremonial validation.

Validation proves only enough investment confidence. It states the assumption,
unlocked decision, cheapest credible method/evidence level, enough-evidence
threshold, intentionally unproven scope, bounded budget, allowed artifacts,
forbidden production changes, stop condition, cleanup/promotion, and validation
status.

Validation prefers existing/read-only evidence, isolated scripts, and sandbox
spikes. It must not become shadow implementation. Mock, Sandbox, and Prototype
evidence cannot satisfy production integration or runtime-verification status.

## Evidence And Decision Authority Contract

Verified current code, tests, logs, data, dependency behavior, and runtime
observations outrank stale technical assumptions and preplanned order.

They do not authorize changes to `decisions.md`. Evidence-plan conflict triggers
technical reconciliation. Evidence-decision conflict triggers pause and direct
user reconfirmation.

## Product Decision Delta Contract

After every material phase, audit only the product semantics introduced or
changed by that phase. Do not use an unbounded whole-project search as the phase
gate.

Use:

```markdown
| Phase | Decision Surface | Implemented / Observed Semantics | Baseline Coverage | Classification | Required Action |
|---|---|---|---|---|---|
```

Classifications:

- `covered`: an active baseline decision governs the behavior;
- `engineering-only`: no material product decision was introduced;
- `provisional`: implementation temporarily chose an unconfirmed behavior;
- `conflict`: observed or implemented behavior conflicts with active authority.

A material `provisional` or `conflict` blocks dependent downstream work until the
user confirms the product outcome.

## Phase Reconciliation Contract

After every material phase in Execution Tracking and before the next phase, the
plan reconciles new evidence, affected assumptions/conclusions, decision-baseline
impact, conclusion validity, Benefit/Side Effects/cost/risk/dependencies,
downstream plan changes, plan validity, and next action.

Decision Baseline Impact values are `aligned`, `conflict-found`,
`change-proposed`, or `re-confirmation-required`. A baseline conflict or
unresolved Product Decision Delta cannot continue unchanged.

## Plan Revision Traceability Contract

Plan updates preserve prior conclusions and evidence history. Decision updates
preserve prior rows and direct confirmation history. Silent history rewriting is
invalid in either artifact.

## State Separation Contract

- Plan Authoring: `planned`, `blocked-on-discovery`,
  `blocked-on-user-decision`, `deferred`.
- Pre-investment validation: `planned`, `direction-supported`,
  `direction-rejected`, `inconclusive`, `budget-exhausted`.
- Execution Tracking: `not-started`, `in-progress`, `verified`, `blocked`,
  `failed`, `rolled-back`.
- Plan validity: `valid`, `valid-with-qualifications`, `needs-revision`,
  `invalidated`.
- Product decisions: `active`, `superseded`.
- Discovery/design artifacts: `planned`, `drafted`, `reviewed`, `verified`.
- Code implementation: `planned`, `implemented`, `integrated`,
  `runtime-verified`.

These models must not be mixed.

## Proportional Output Contract

The two topic artifacts are mandatory for formal repository plans. Additional
artifacts are not. Pending Product Decisions, pre-investment validation, Product
Decision Delta, and reconciliation appear only when triggered. Do not restore
fixed oversized templates.

## Work Unit Contract

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

## Product Decision Delta Contract Shape

```markdown
| Phase | Decision Surface | Implemented / Observed Semantics | Baseline Coverage | Classification | Required Action |
|---|---|---|---|---|---|
```

## Phase Reconciliation Contract Shape

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
```

## Behavioral Validation Contract

Tests validate representative outputs, topic artifact bundles, protected product
authority, and phase decision audits. They reject at least:

- missing or misplaced required topic artifacts;
- an unprotected `decisions.md`;
- a baseline row not backed by direct user confirmation;
- `proposed` or other Agent-authored pending decisions inside `decisions.md`;
- a plan missing Execution Contract, Design, or Work Units;
- a material phase with no Product Decision Delta audit;
- continued dependent work after material `provisional` or `conflict`;
- vague/coupled work units, generic Benefits, incomplete Side Effects;
- material uncertainty without bounded validation or shadow implementation;
- stale-plan continuation or silent decision/conclusion rewriting.

It accepts concise protected topic artifacts and bounded phase audits whose
product authority remains external to the Agent.
