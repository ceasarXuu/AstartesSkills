# SE Good Plan Patterns

Use these compact structures when a formal engineering plan needs durable execution controls.

## Product Authority Selection

A plan has one effective Product Authority Source:

```text
preferred -> existing canonical PRD#confirmed-product-decisions
fallback  -> docs/releases/<version>/<topic>/decisions.md
```

Use the PRD when it contains protected directly user-confirmed material decisions with stable `PD` IDs. Do not copy those decisions into fallback `decisions.md`.

An ordinary PRD without protected directly confirmed rows is context, not hard authority.

## Formal Plan

```markdown
# <Topic> Engineering Plan

- Release Version: v1.2.3
- Topic Directory: docs/releases/v1.2.3/account-locale
- Product Authority: ../../../../prd/account-locale.md#confirmed-product-decisions
- Applicable Decisions: PD1, PD2
- Mode: Plan Authoring

## Execution Contract

- The declared Product Authority Source is user authority for active confirmed decisions.
- Changing active authority requires explicit user approval; Agent self-approval is forbidden.
- Engineering evidence may revise this plan, not silently rewrite product authority.
- Unconfirmed material choices are deferred, provisional, or user-confirmed.
- Audit the Product Decision Delta after every material phase.
- Before every material phase, rebase remaining work against actual completed implementation and evidence.
- Do not start a Phase while its Pre-Phase Plan Rebase Gate is `pending` or `blocked-on-plan-approval`.
- A material Plan Delta requires explicit user approval before the approved revision is executed.
- `provisional` or `conflict` product decisions block dependent continuation until resolved.

## Design

...

## Work Units

...
```

When the plan uses fallback authority, set:

```markdown
- Product Authority: ./decisions.md
- Applicable Decisions: D1, D2
```

## Fallback Product Decision Baseline

Create only when no qualifying canonical PRD authority exists for the scope.

```markdown
# Product Decision Baseline

> PROTECTED USER-AUTHORITY ARTIFACT
> Decisions in this file MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.
> Agent self-approval is forbidden.

- Authority: User
- Write Gate: Explicit user approval required
- Agent Self-Approval: Forbidden
- Release Version: v1.2.3
- Topic: account-locale
- Plan: ./plan.md

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | Locale remains optional | Preserve null-compatible reads | Do not require backfill before rollout | Existing accounts remain compatible | Existing null rows fail unchanged reads | user-confirmed-direct: "keep existing accounts compatible" | active |
```

Allowed statuses are `active` and `superseded`. Pending choices do not belong here.

## Material Product Decision Guidance

Treat a choice as product authority when alternatives materially change domain model, lifecycle, defaults/automation, user control, persistence, permissions/visibility, compatibility, external side effects, or important limits.

For an unconfirmed material decision:

1. defer when current work can preserve the choice;
2. use provisional behavior only when necessary, local, reversible, and bounded;
3. ask the user first when the choice is high-impact, public/persistent, hard to reverse, or controls substantial downstream work.

Do not interpret `continue`, user silence, successful tests, or existing implementation as approval.

## Pending Product Decisions

```markdown
## Pending Product Decisions

| ID | Decision Surface | Current / Proposed Behavior | Why Material | Evidence | Impact If Changed |
|---|---|---|---|---|---|
| P1 | Resume lifecycle | Current phase temporarily replaces the prior resume session | Changes history and recovery semantics | Phase 2 implementation | Persistence and UI require rework if changed |
```

After direct user confirmation, update the canonical PRD authority when one exists; otherwise update fallback `decisions.md`. Do not create a second authority copy.

## Product Decision Delta

```markdown
## Product Decision Delta

| Phase | Decision Surface | Implemented / Observed Semantics | Authority Coverage | Classification | Required Action |
|---|---|---|---|---|---|
| Phase 2 | Error visibility | Failed tasks remain visible | PD4 | covered | none |
| Phase 2 | Cache identity | Composite internal key | n/a | engineering-only | none |
| Phase 2 | Resume lifecycle | Resume replaces prior session | none | provisional | P1: ask user before dependent work |
```

Classifications:

- `covered`: cite an active authority decision ID;
- `engineering-only`: no material product semantics;
- `provisional`: temporary unconfirmed behavior;
- `conflict`: behavior conflicts with active authority.

## Pre-Phase Plan Rebase Gate

Every material Phase contains its own persisted gate so execution does not depend on rereading the skill.

Initial authoring shape:

```markdown
### Phase 2: Roll Out New Path

#### Pre-Phase Plan Rebase Gate

- Rebase scope: completed implementation + remaining plan
- Material plan delta: pending
- Plan delta record: pending
- User approval: pending-if-material
- Gate status: pending

- Entry condition: ...
- Applicable decisions: PD1, PD2
- Work units: W4, W5
- Phase-local evidence: ...
- Product decision delta review: required
- Cross-unit side effects: ...
- Next-phase condition: ...
```

Before execution, inspect completed code, configuration, schemas, documentation, tests, dependency behavior, and verified runtime evidence that can affect remaining work. Compare them with remaining Design, Work Units, Phase assumptions, dependencies, verification, sequencing, Benefit, Side Effects, cost, and risk.

No material change:

```markdown
- Material plan delta: none
- Plan delta record: not-required
- User approval: not-required
- Gate status: ready
```

Material change awaiting approval:

```markdown
- Material plan delta: material
- Plan delta record: R2
- User approval: required-pending
- Gate status: blocked-on-plan-approval
```

After direct approval and application of the approved revision:

```markdown
- Material plan delta: material
- Plan delta record: R2
- User approval: user-approved-plan-direct: <specific approval>
- Gate status: ready
```

A material Plan Delta includes a changed design direction, scope, module/data/API boundary, product behavior, material Work Unit set, dependency/order, verification strategy, release/rollback, Benefit, Side Effects, cost, or risk. Local private implementation details that do not change downstream plan inputs are non-material.

## Plan Delta History

Record only when a material Plan Delta exists:

```markdown
## Plan Delta History

| ID | Before Phase | Previous Plan | Current Fact | Proposed Change | Impact | User Approval | Status |
|---|---|---|---|---|---|---|---|
| R2 | Phase 2 | W4 adds a routing adapter before rollout | Phase 1 proved the existing router exposes the required selector | Remove W4 and retarget W5 to the existing router | Less code; W5 verification target changes | user-approved-plan-direct: approve R2 | approved-applied |
```

Record the proposal before asking for approval. While approval is pending, keep the gate `blocked-on-plan-approval` and do not execute the Phase. After approval, update the canonical Design/Work Units/Phases, preserve this history row, then mark the gate `ready`.

If the implementation conflicts with active Product Authority, resolve the product-decision conflict first. Do not use Plan Rebase to reinterpret product intent.

## Authority Change Proposal

```markdown
- Product Authority: <path>
- Affected Decision: PD2 | D2
- New Evidence:
- Proposed Replacement:
- Benefit / Side Effects:
- Affected Work Units:
- User Confirmation:
```

Only after direct user confirmation may the active authority row change.

## Work Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

## Phase Reconciliation

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
```

Phase Reconciliation closes the completed phase. The next material Phase still runs its own Pre-Phase Plan Rebase Gate against the latest actual state and all remaining work.

## Minimum Necessary Construction

Ask in order:

1. Can obsolete logic be deleted?
2. Can the existing path be changed directly?
3. Can a current mechanism be reused?
4. Is narrow local logic sufficient?
5. Which current variation proves a new abstraction?
6. Which measured constraint proves new infrastructure is needed?

Reject speculative frameworks, unmeasured infrastructure, incidental refactors, and temporary paths without retirement criteria.

## Wording Guardrails

| Vague wording | Required replacement |
|---|---|
| user approved / confirmed | direct confirmation evidence for the specific decision |
| user did not object | pending; silence is not approval |
| current code already does this | observed implementation, not product authority |
| copy PRD decisions into baseline | reference canonical PRD decision IDs |
| follow the plan | reconcile completed evidence, then rebase remaining work before the next Phase |
| plan still looks fine | cite current implementation evidence and the remaining-plan comparison |
| update the plan | record the Plan Delta, obtain required approval, then apply the approved revision |
| validate feasibility | assumption, threshold, budget, isolation, stop |
