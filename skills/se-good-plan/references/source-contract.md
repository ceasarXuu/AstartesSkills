# SE Good Plan Source Contract

This file defines behavior that must remain stable across future edits.

## Trigger And Honesty Contract

The skill triggers for implementation, refactor, migration, rollout, bug-fix, performance, security, DevOps / CI/CD, release, technical execution, plan decomposition, product-authority review, validation review, stale-plan review, and existing-plan review. It must not invent architecture, scale, schedules, staffing, deadlines, release versions, or release commitments.

## Formal Plan Artifact Contract

A formal repository plan always uses:

```text
docs/releases/<confirmed-version>/<topic-slug>/plan.md
```

The release version comes from the user, repository release documentation, or an explicit project decision. The Agent must not invent it. `plan.md` is updated in place; parallel copies are invalid.

## Single Product Authority Contract

Every formal plan declares exactly one effective Product Authority Source for material product decisions.

Authority precedence:

1. an existing canonical PRD with a protected `Confirmed Product Decisions` section containing directly user-confirmed active decisions;
2. otherwise fallback `docs/releases/<confirmed-version>/<topic-slug>/decisions.md`.

When canonical PRD authority exists for the same scope:

- reference its stable `PD` decision IDs from `plan.md`;
- do not copy those decisions into `decisions.md`;
- do not maintain two independent authority documents for the same decision.

A PRD without protected directly confirmed rows may inform design but is not hard product authority.

`plan.md` contains:

```markdown
- Product Authority: <path-or-./decisions.md>
- Applicable Decisions: <PD1, PD2 | D1, D2 | none>
```

## Fallback Product Decision Baseline Contract

Create fallback `decisions.md` only when qualifying canonical PRD authority is unavailable for the scope.

It states:

```markdown
> PROTECTED USER-AUTHORITY ARTIFACT
> Decisions in this file MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.

- Authority: User
- Write Gate: Explicit user approval required
- Agent Self-Approval: Forbidden
```

The fallback table is:

```markdown
| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
```

Allowed statuses are only `active` and `superseded`.

- Every active row represents a directly user-confirmed material decision.
- Confirmation preserves direct user approval evidence.
- Agent inference, code, tests, reviews, documents, another Agent, implementation success, or user silence are not approval.
- Replacing a decision requires explicit user approval; preserve the old row as `superseded`.
- Ordinary implementation details and speculative requirements do not belong in the baseline.

## Unconfirmed Product Decision Contract

Unconfirmed product choices stay in `plan.md`, never in the Product Authority Source.

A material product decision changes user-visible behavior, product rules, core domain modeling, lifecycle/state semantics, defaults/automation, user control/reversibility, persistence, permissions/visibility, compatibility, external side effects, or important limits. Product-equivalent internal implementation choices remain engineering choices.

When a material choice is not confirmed:

- defer it if the choice can remain open;
- use `provisional` behavior only when necessary, local, reversible, and bounded;
- obtain direct user confirmation before high-impact, hard-to-reverse, public/persistent, or broadly depended-on behavior is implemented.

## Plan Execution Contract

Every formal `plan.md` contains a short `## Execution Contract` that survives long-running execution without relying on the Agent to reread this skill. It states that:

- the declared Product Authority Source governs active confirmed product decisions;
- changing active authority requires explicit user approval and Agent self-approval is forbidden;
- engineering evidence may revise the technical plan, not product authority;
- unconfirmed material choices are deferred, provisional, or user-confirmed;
- every material phase performs a bounded Product Decision Delta audit;
- before every material phase, the remaining plan is rebased against actual completed implementation and evidence;
- a material Phase cannot start while its Pre-Phase Plan Rebase Gate is `pending` or `blocked-on-plan-approval`;
- material Plan Delta requires a recorded proposal and explicit user approval before the approved revision is applied and dependent implementation continues;
- unresolved material product `provisional` or `conflict` blocks dependent continuation.

## Executable Closed-Loop Unit Contract

Every work unit identifies a concrete location, named object, one action, resulting behavior, specific Benefit, Side Effects, exact verification, and a safe-stop boundary. Each unit has one primary objective/change axis and is independently inspectable, verifiable, and stoppable.

## Minimum Necessary Construction Contract

Plans prefer delete/simplify, direct change, reuse, and narrow local logic before new abstractions, dependencies, state, or infrastructure. Current confirmed need or risk is required for interfaces, factories, providers, registries, switches, states, branches, caches, queues, jobs, schemas, dependencies, or frameworks. Speculative future use is insufficient.

## Benefit And Side Effects Contract

Benefit connects technical behavior to wider project value and cannot be generic or duplicate Resulting Behavior. Side Effects are expected costs even when work succeeds and cover both Complexity delta and Reach / cost.

## Minimum Sufficient Pre-Investment Validation Contract

When a critical unknown could invalidate substantial later work, validate before expensive, broad, irreversible, or dependency-sensitive implementation. Validation proves only enough investment confidence and must not become shadow implementation.

## Evidence And Authority Contract

Verified current code, tests, logs, data, dependency behavior, and runtime observations outrank stale technical assumptions and preplanned order.

They do not authorize changes to the Product Authority Source. Evidence-plan conflict triggers technical reconciliation. Evidence-authority conflict triggers pause and direct user reconfirmation.

## Product Decision Delta Contract

After every material phase, audit only the product semantics introduced or changed by that phase.

```markdown
| Phase | Decision Surface | Implemented / Observed Semantics | Authority Coverage | Classification | Required Action |
|---|---|---|---|---|---|
```

Classifications:

- `covered`: cite an active decision ID from the declared Product Authority Source;
- `engineering-only`: no material product decision was introduced;
- `provisional`: implementation temporarily chose an unconfirmed behavior;
- `conflict`: implementation/evidence conflicts with active authority.

A material `provisional` or `conflict` blocks dependent downstream work until the user confirms the product outcome.

## Phase Reconciliation Contract

After every material phase in Execution Tracking, reconcile new evidence, affected assumptions/conclusions, product-authority impact, downstream plan changes, plan validity, and next action. Authority conflict or unresolved Product Decision Delta cannot continue unchanged.

Phase Reconciliation describes what the completed phase changed. It does not by itself authorize the next phase to start.

## Pre-Phase Plan Rebase Contract

Before **every material Phase**, the Phase itself contains and runs a persisted `#### Pre-Phase Plan Rebase Gate` in `plan.md`.

The gate compares the current implemented state produced by completed phases with **all remaining planned work**. Relevant evidence includes code, configuration, schemas, documentation, tests, dependency behavior, and verified runtime evidence as applicable. The comparison covers remaining Design, Work Units, Phase assumptions, dependencies, verification, sequencing, Benefit, Side Effects, cost, and risk.

A Phase gate records:

```markdown
- Rebase scope: completed implementation + remaining plan
- Material plan delta: pending | none | material
- Plan delta record: pending | not-required | <delta ID>
- User approval: pending-if-material | not-required | required-pending | user-approved-plan-direct: ...
- Gate status: pending | ready | blocked-on-plan-approval
```

Rules:

- `pending` means the latest completed implementation has not yet been compared with the remaining plan; the Phase cannot start.
- `none` means current facts still support the remaining plan; user approval is `not-required` and the gate may become `ready`.
- `material` means the remaining plan materially changes in design direction, scope, module/data/API boundary, product behavior, material Work Units, dependencies/order, verification strategy, release/rollback, Benefit, Side Effects, cost, or risk.
- A material Plan Delta is first recorded as a proposal with previous plan, current fact, proposed change, and impact; the gate becomes `blocked-on-plan-approval`.
- The Agent cannot self-approve a material Plan Delta. `ready` after a material delta requires `user-approved-plan-direct:` evidence for that specific revision.
- After direct approval, apply the approved revision to the canonical `plan.md` and preserve the Plan Delta history before execution.
- Local implementation-detail changes that do not alter downstream plan inputs are not material and do not require approval.
- If current implementation conflicts with Product Authority, resolve the product-authority conflict first; do not rebase product authority to match code.

A compact Plan Delta history may use:

```markdown
| ID | Before Phase | Previous Plan | Current Fact | Proposed Change | Impact | User Approval | Status |
|---|---|---|---|---|---|---|---|
```

## Plan Revision Traceability Contract

Plan updates preserve prior conclusions and evidence history. Material Plan Delta preserves the previous plan claim, current fact, approved change, and approval evidence. Product-authority updates preserve prior confirmed decision history. Silent history rewriting is invalid.

## State Separation Contract

- Plan Authoring: `planned`, `blocked-on-discovery`, `blocked-on-user-decision`, `deferred`.
- Pre-investment validation: `planned`, `direction-supported`, `direction-rejected`, `inconclusive`, `budget-exhausted`.
- Execution Tracking: `not-started`, `in-progress`, `verified`, `blocked`, `failed`, `rolled-back`.
- Plan validity: `valid`, `valid-with-qualifications`, `needs-revision`, `invalidated`.
- Pre-Phase Plan Rebase Gate: `pending`, `ready`, `blocked-on-plan-approval`.
- Product decisions: `active`, `superseded`.
- Discovery/design artifacts: `planned`, `drafted`, `reviewed`, `verified`.
- Code implementation: `planned`, `implemented`, `integrated`, `runtime-verified`.

These models must not be mixed.

## Behavioral Validation Contract

Tests should reject at least:

- missing or misplaced `plan.md`;
- no declared Product Authority Source;
- duplicated canonical PRD decisions in fallback authority;
- Agent-authored active authority;
- a fallback baseline row without direct user confirmation;
- a plan missing Execution Contract, Design, or Work Units;
- a material phase with no Product Decision Delta audit;
- a multi-phase plan whose material Phase lacks a persisted Pre-Phase Plan Rebase Gate;
- a Phase starting while its rebase gate is `pending` or `blocked-on-plan-approval`;
- a material Plan Delta marked `ready` without direct user approval;
- a material Plan Delta applied or executed without preserving its change/approval history;
- continued dependent work after material product `provisional` or `conflict`;
- vague/coupled work units, generic Benefits, incomplete Side Effects;
- shadow validation, stale-plan continuation, or silent authority/plan rewriting.
