---
name: se-good-plan
description: Use when the user asks for a software engineering plan, implementation plan, refactor plan, migration plan, rollout plan, bug-fix plan, performance optimization plan, security change plan, DevOps / CI/CD plan, technical execution plan, or review of an existing engineering plan. Produces concise executable plans that reuse canonical PRD product authority when available and fall back to a protected local decision baseline only when needed.
---

# SE Good Plan

## Purpose

Write or review engineering plans that are directly executable, proportionate to the problem, constrained by user-confirmed product intent, and updated by real evidence rather than followed mechanically.

## Product Authority First

A formal plan must have exactly one effective **Product Authority Source** for material product decisions.

Use this precedence:

1. an existing canonical PRD whose `Confirmed Product Decisions` section contains directly user-confirmed active decisions;
2. otherwise a fallback `decisions.md` created for this engineering topic.

Do not copy confirmed PRD decisions into `decisions.md`. If a qualifying PRD already governs the same scope, reference its stable `PD` IDs directly from the plan.

An existing PRD without protected directly confirmed decision rows is product context, not hard authority. Prefer getting the relevant decisions confirmed in that PRD. Use fallback `decisions.md` only when no suitable canonical product-authority section is available.

## Formal Plan Artifacts

A formal repository plan uses:

```text
docs/releases/<confirmed-version>/<topic-slug>/
└── plan.md
```

and one Product Authority Source:

```text
preferred: <existing-prd>#confirmed-product-decisions
fallback:  docs/releases/<confirmed-version>/<topic-slug>/decisions.md
```

Resolve the release version from the user, repository release documentation, or an explicit project decision. Do not invent it. Reuse `plan.md`; do not create `plan-v2.md`, `final-plan.md`, or parallel copies.

`plan.md` records:

```markdown
- Product Authority: <path-or-./decisions.md>
- Applicable Decisions: <PD1, PD2, ... | D1, D2, ... | none>
```

## Fallback `decisions.md`

Create this file only when no qualifying canonical PRD authority exists for the scope.

It remains a protected user-authority artifact:

```markdown
# Product Decision Baseline

> PROTECTED USER-AUTHORITY ARTIFACT
> Decisions in this file MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.
> Agent inference, implementation, tests, reviews, existing documents, or lack
> of user objection are not approval.

- Authority: User
- Write Gate: Explicit user approval required
- Agent Self-Approval: Forbidden
- Release Version:
- Topic:
- Plan: ./plan.md

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | ... | ... | ... | ... | ... | user-confirmed-direct: ... | active |
```

Only directly user-confirmed material decisions belong here. Allowed statuses are `active` and `superseded`. Replacements require explicit user approval and preserve the old row as `superseded`.

## Material Product Decisions

A material product decision changes user-visible behavior, product rules, core domain modeling, lifecycle/state semantics, defaults or automation, user control/reversibility, persistence, permissions/visibility, compatibility, external side effects, or important limits.

Equivalent private implementation choices are engineering decisions.

For an unconfirmed material choice:

1. **defer** it when current work can preserve the choice;
2. use **provisional** behavior only when necessary, local, reversible, and bounded;
3. **ask the user before implementation** when it is high-impact, hard to reverse, public/persistent, or controls substantial downstream work.

Unconfirmed choices stay in `plan.md` under `## Pending Product Decisions`; they never become authority through implementation or Agent inference.

## Execution Contract

Every formal `plan.md` must persist a short `## Execution Contract` stating at least:

- the declared Product Authority Source is user authority for its active confirmed decisions;
- changes to active product authority require explicit user approval; Agent self-approval is forbidden;
- verified engineering evidence may revise `plan.md`, not silently rewrite product authority;
- new material product choices are deferred, provisional, or user-confirmed;
- after every material phase, audit only that phase's Product Decision Delta;
- classify each delta as `covered`, `engineering-only`, `provisional`, or `conflict`;
- dependent work cannot continue while a material `provisional` or `conflict` remains unresolved.

## Executable Work Units

Every work unit states a concrete change location, named target object, one explicit engineering action, resulting behavior, Benefit, Side Effects, exact verification, and safe-stop or rollback boundary.

Unknown locations or objects become bounded Discovery units rather than vague implementation steps.

Use the smallest closed-loop engineering unit: one primary objective, change axis, action, benefit, and bounded side-effect profile. Split independent API, data, implementation, cache, client, deployment, observability, security, and cleanup work.

## Minimum Necessary Construction

Prefer:

```text
delete/simplify
  -> change existing path
  -> reuse existing mechanism
  -> narrow local logic
  -> new abstraction
  -> new dependency or stateful infrastructure
```

New interfaces, factories, providers, registries, switches, states, runtime branches, caches, queues, jobs, dependencies, schemas, or frameworks require a current confirmed need or risk. Possible future use is insufficient.

## Benefit And Side Effects

`Resulting Behavior` explains what changes technically. `Benefit` explains why it matters. Side Effects cover expected consequences even when implementation succeeds.

Every Side Effects field covers:

- **Complexity:** code/files/concepts/abstractions/states/branches/dependencies/config/schema/runtime paths/temporary logic added or removed;
- **Reach / cost:** affected modules/callers/data/tests/builds/CI/deployment/resources/security/operations/support/ownership/cognitive load/cleanup.

## Minimum Sufficient Pre-Investment Validation

Before expensive, broad, irreversible, or dependency-sensitive implementation, identify any critical assumption whose failure would invalidate substantial later work. Validate only enough to decide whether the direction merits investment.

Prefer existing/read-only evidence, then an isolated request or script, then a sandbox/disposable spike. Validation is not shadow implementation. Mock, Sandbox, and Prototype evidence cannot be reported as production integration.

## Evidence And Product Authority

Verified current code, tests, logs, data, dependency behavior, and runtime observations outrank stale technical assumptions and preplanned order.

They do **not** authorize changes to the Product Authority Source. Evidence-plan conflict triggers technical reconciliation. Evidence-authority conflict triggers a pause and direct user reconfirmation.

## Product Decision Delta

After every material phase, audit only product semantics introduced or changed by that phase.

```markdown
| Phase | Decision Surface | Implemented / Observed Semantics | Authority Coverage | Classification | Required Action |
|---|---|---|---|---|---|
```

Classifications:

- `covered`: cite an active decision ID from the Product Authority Source;
- `engineering-only`: no material product semantics changed;
- `provisional`: temporary unconfirmed product behavior;
- `conflict`: implementation or evidence conflicts with active authority.

A material `provisional` or `conflict` blocks dependent downstream work until the user confirms the product outcome.

## Plan State Models

Keep these separate:

- Plan Authoring: `planned`, `blocked-on-discovery`, `blocked-on-user-decision`, `deferred`.
- Pre-investment validation: `planned`, `direction-supported`, `direction-rejected`, `inconclusive`, `budget-exhausted`.
- Execution Tracking: `not-started`, `in-progress`, `verified`, `blocked`, `failed`, `rolled-back`.
- Plan validity: `valid`, `valid-with-qualifications`, `needs-revision`, `invalidated`.
- Product decisions: `active`, `superseded`.
- Discovery/design artifacts: `planned`, `drafted`, `reviewed`, `verified`.
- Code implementation: `planned`, `implemented`, `integrated`, `runtime-verified`.

## Generation Workflow

### 1. Resolve Product Authority And Topic

Inspect existing PRDs and release docs before creating authority artifacts.

- If a canonical PRD has protected directly confirmed decisions for this scope, use it and reference its `PD` IDs.
- Otherwise create/reuse fallback `decisions.md` and use its `D` IDs.
- Never maintain both as independent authority for the same decisions.

Resolve `docs/releases/<confirmed-version>/<topic-slug>/plan.md` without inventing a version.

### 2. Write The Plan Contract And Design

Record Product Authority, applicable active IDs, Execution Contract, current/expected behavior, goals/non-goals, assumptions, open questions, and least-construction technical design.

If unresolved material choices exist:

```markdown
## Pending Product Decisions

| ID | Decision Surface | Current / Proposed Behavior | Why Material | Evidence | Impact If Changed |
|---|---|---|---|---|---|
```

### 3. Add Bounded Validation When Needed

```markdown
| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
```

### 4. Build Work Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

### 5. Group Into Phases Only When Useful

Each phase has entry conditions, applicable decisions, work units, phase-local evidence, Product Decision Delta review, cross-unit side effects, and a next-phase condition.

### 6. Reconcile Before Continuing

After a material phase, record the bounded Product Decision Delta, then reconcile new evidence against technical assumptions and product authority. A material `provisional` or `conflict` cannot proceed unchanged.

## Reviewing Existing Plans

Lead with findings. Check for duplicated product authority, Agent-authored authority, missing Product Authority metadata, unresolved product choices embedded silently in design/code, missing phase delta audit, continued work after provisional/conflict, vague or oversized units, speculative construction, shadow validation, stale-plan continuation, mixed states, and unsupported facts.

## Output Quality Checklist

- [ ] Exactly one effective Product Authority Source governs material product decisions.
- [ ] Canonical PRD authority is referenced instead of copied when available.
- [ ] Fallback `decisions.md` exists only when canonical PRD authority is unavailable.
- [ ] Only directly user-confirmed decisions are active authority.
- [ ] `plan.md` contains Product Authority, applicable IDs, Execution Contract, Design, and Work Units.
- [ ] Unconfirmed material choices stay pending, provisional, or user-blocked.
- [ ] Units are concrete, minimum-necessary, beneficial, side-effect-aware, and stoppable.
- [ ] Critical uncertainty is validated before disproportionate investment.
- [ ] Every material phase performs bounded Product Decision Delta audit.
- [ ] `provisional` / `conflict` blocks dependent continuation until user confirmation.
