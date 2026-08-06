---
name: se-good-plan
description: Use when the user asks for a software engineering plan, implementation plan, refactor plan, migration plan, rollout plan, bug-fix plan, performance optimization plan, security change plan, DevOps / CI/CD plan, technical execution plan, or review of an existing engineering plan. Produces concise, executable, evidence-updated plans with a protected user-confirmed product decision baseline and two required repository artifacts.
---

# SE Good Plan

## Purpose

Write or review engineering plans that are directly executable, proportionate to
the problem, constrained by user-confirmed product intent, and updated by real
evidence rather than followed mechanically.

A formal repository plan maintains exactly two required topic artifacts:

```text
docs/releases/<confirmed-version>/<topic-slug>/
├── decisions.md
└── plan.md
```

`decisions.md` is a protected user-authority product decision baseline. `plan.md`
is the main working document containing engineering design, execution controls,
work units, conditional validation, phases, pending product decisions, and
execution-time updates. Other research or review artifacts are created only when
needed.

## Use This Skill When

- The user asks for an implementation, refactor, migration, rollout, bug-fix,
  performance, security, DevOps, CI/CD, release, or other engineering plan.
- The user asks to split work into executable units or phases.
- The user asks to make a plan concrete, concise, reviewable, or ready to execute.
- The user asks whether a plan is vague, oversized, over-engineered,
  insufficiently validated, stale, or drifting from product intent.

Do not use this skill for pure product clarification unless requirements must be
converted into engineering execution. Do not over-plan tiny, low-risk edits.

## Core Rules

### 1. Maintain Two Required Topic Artifacts

For a formal repository plan, create or reuse:

```text
docs/releases/<confirmed-version>/<topic-slug>/decisions.md
docs/releases/<confirmed-version>/<topic-slug>/plan.md
```

Resolve `<confirmed-version>` from the user, repository release documentation, or
an explicit project decision. Do not invent a version. Reuse the same files over
the topic lifecycle; do not create `plan-v2.md`, `final-plan.md`, or copied
decision baselines.

The files are independent and cross-linked:

- `decisions.md` links `./plan.md`.
- `plan.md` links `./decisions.md` and lists applicable active decision IDs.
- `plan.md` contains `## Execution Contract`, `## Design`, and `## Work Units`.
- The full decision baseline must not be copied into `plan.md`.

### 2. Treat `decisions.md` As A Protected User-Authority Artifact

The top of `decisions.md` must make the write boundary explicit:

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
```

Use a compact decision table:

```markdown
| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | ... | ... | ... | ... | ... | user-confirmed-direct: ... | active |
```

Only directly user-confirmed decisions belong in this file. Allowed statuses are
`active` and `superseded`; there is no Agent-created `proposed` state in the
baseline. Each row preserves direct confirmation evidence.

An Agent must never promote its own interpretation, already-written code, tests,
review results, another Agent's statement, or user silence into product
authority. A replacement also requires explicit user approval; preserve the old
row as `superseded` rather than rewriting history.

### 3. Keep Unconfirmed Product Decisions In `plan.md`

A **material product decision** is a choice whose alternatives materially change
user-visible behavior, product rules, core domain modeling, lifecycle/state
semantics, defaults or automation, user control/reversibility, persistence,
permissions/visibility, compatibility, external side effects, or important
limits. Purely internal equivalent implementation choices remain engineering
decisions.

When an unconfirmed material product choice appears:

1. **Defer** it when the choice can remain open without harming the current unit.
2. Use a **provisional** implementation only when a temporary choice is necessary,
   local, reversible, and prevented from becoming a broad dependency.
3. **Ask the user before implementation** when the choice is high-impact,
   hard-to-reverse, changes public/persistent behavior, or controls substantial
   downstream work.

Never write an unconfirmed choice into `decisions.md`. Record unresolved choices
in `plan.md` under `## Pending Product Decisions` when they exist.

### 4. Materialize The Execution Contract In `plan.md`

Do not rely on a long-running Agent to reread this skill. Every formal `plan.md`
must contain a short `## Execution Contract` stating at least:

- `decisions.md` is user-authority protected and each change requires explicit
  user approval; Agent self-approval is forbidden.
- Verified engineering facts may revise `plan.md`, not silently rewrite
  user-confirmed product intent.
- New material product choices are deferred, provisional, or user-confirmed;
  they are never silently finalized.
- After every material phase, audit only the product-semantics delta introduced
  by that phase.
- Classify each delta as `covered`, `engineering-only`, `provisional`, or
  `conflict`.
- Dependent work cannot continue while a material `provisional` or `conflict`
  remains unresolved.

### 5. Plans Must Be Executable

Every work unit states a concrete change location, named target object, one
explicit engineering action, resulting behavior, Benefit, Side Effects, exact
verification, and safe-stop or rollback boundary.

Abstract statements such as “add an abstraction”, “refactor the module”,
“optimize caching”, or “complete integration” are not executable by themselves.
Unknown locations or objects become bounded Discovery units.

### 6. Use The Smallest Closed-Loop Engineering Unit

Each unit has one primary objective, change axis, action, benefit, and bounded
side-effect profile. It must be independently inspectable, auditable, verifiable,
and reversible, disableable, or safely stoppable.

Split independent API, data, implementation, cache, client, deployment,
observability, security, and cleanup work. A phase may sequence units but cannot
hide their individual actions, evidence, states, or safe-stop boundaries.

### 7. Prefer Minimum Necessary Construction

Prefer:

```text
delete/simplify
  -> change existing path
  -> reuse existing mechanism
  -> narrow local logic
  -> new abstraction
  -> new dependency or stateful infrastructure
```

New interfaces, factories, providers, registries, switches, states, runtime
branches, caches, queues, jobs, dependencies, schemas, or frameworks require a
current confirmed need or risk. Possible future use is insufficient. Temporary
construction needs retirement criteria and cleanup.

### 8. Make Benefit And Side Effects Explicit

`Resulting Behavior` explains what changes technically. `Benefit` explains why
it matters to users, delivery, reliability, maintenance, cost, support, risk, or
operations. Generic claims or copies of Resulting Behavior are invalid.

Side Effects are expected consequences even when implementation works; Risks are
uncertain and Rollback is recovery. Every Side Effects field covers:

- **Complexity:** code/files/concepts/abstractions/states/branches/dependencies/
  config/schema/runtime paths/temporary logic added or removed.
- **Reach / cost:** affected modules/callers/data/tests/builds/CI/deployment/
  resources/security/operations/support/ownership/cognitive load/cleanup.

### 9. Use Minimum Sufficient Pre-Investment Validation

Before expensive, broad, irreversible, or dependency-sensitive implementation,
identify any critical assumption whose failure would invalidate substantial later
work. Validate only enough to decide whether the direction merits investment.

Prefer existing/read-only evidence, then an isolated request/script, then a
sandbox/disposable spike. Validation states the assumption, unlocked decision,
evidence level, enough-evidence threshold, intentionally unproven scope, bounded
budget, allowed artifacts, forbidden production changes, stop condition, and
cleanup/promotion.

Validation is not shadow implementation. Mock, Sandbox, and Prototype evidence
cannot be reported as production integration. If credible validation approaches
formal implementation scope, reclassify it as implementation.

### 10. Evidence Supersedes The Technical Plan

Verified current code, tests, logs, data, dependency behavior, and runtime
observations outrank stale technical assumptions and preplanned order. They do
not outrank user authority in `decisions.md`.

After every material phase, reconcile evidence and audit the **Product Decision
Delta**: only product semantics introduced or changed by that phase, not an
unbounded rescan of the whole project.

Classify each material delta:

- `covered`: an active decision already governs it.
- `engineering-only`: no material product semantics changed.
- `provisional`: implementation temporarily chose an unconfirmed product behavior.
- `conflict`: implementation or evidence conflicts with an active decision.

A material `provisional` or `conflict` pauses dependent downstream work until the
user confirms the product outcome. Phase completion alone never authorizes
continuation.

### 11. Keep State Models Separate

- Plan Authoring: `planned`, `blocked-on-discovery`,
  `blocked-on-user-decision`, `deferred`.
- Pre-investment validation: `planned`, `direction-supported`,
  `direction-rejected`, `inconclusive`, `budget-exhausted`.
- Execution Tracking: `not-started`, `in-progress`, `verified`, `blocked`,
  `failed`, `rolled-back`.
- Plan validity: `valid`, `valid-with-qualifications`, `needs-revision`,
  `invalidated`.
- Product decisions in `decisions.md`: `active`, `superseded`.
- Discovery/design artifacts: `planned`, `drafted`, `reviewed`, `verified`.
- Code implementation: `planned`, `implemented`, `integrated`,
  `runtime-verified`.

Do not mix these models.

### 12. Prefer Concise Structure

The two topic artifacts are mandatory for formal repository plans; additional
artifacts are not. Add Pending Product Decisions, validation, or reconciliation
only when triggered. Do not duplicate decisions, risks, tests, logs, benefits,
side effects, or evidence merely to fill a template.

## Generation Workflow

### 1. Resolve The Topic Directory And Protected Baseline

Inspect `docs/releases/` and resolve the confirmed release version and topic slug.
Create or reuse `decisions.md` and `plan.md`. Read the protected baseline before
designing the plan. Do not write or alter decision rows unless the user directly
approved the specific change.

### 2. Write The Execution Contract And Design In `plan.md`

Link `./decisions.md`, list applicable active IDs, write the compact Execution
Contract, then state current/expected behavior, goals/non-goals, assumptions,
open questions, and least-construction technical design.

If a material product choice is unresolved, either ask before dependent design,
or record it under:

```markdown
## Pending Product Decisions

| ID | Decision Surface | Current / Proposed Behavior | Why Material | Evidence | Impact If Changed |
|---|---|---|---|---|---|
```

### 3. Add Bounded Pre-Investment Validation When Needed

```markdown
| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
```

### 4. Build Work Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

Use `blocked-on-user-decision` when a dependent material choice requires direct
user confirmation.

### 5. Group Into Phases Only When Useful

```markdown
### Phase N: <Outcome>

- Entry condition:
- Applicable decisions:
- Work units:
- Phase-local evidence:
- Product decision delta review: required / not-material
- Cross-unit side effects:
- Next-phase condition:
```

### 6. Reconcile And Audit Before The Next Material Phase

In Execution Tracking, first record the bounded phase delta:

```markdown
## Product Decision Delta

| Phase | Decision Surface | Implemented / Observed Semantics | Baseline Coverage | Classification | Required Action |
|---|---|---|---|---|---|
```

Then reconcile:

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
```

If a material delta is `provisional` or `conflict`, or baseline impact requires
reconfirmation, the next action cannot be `continue`.

## Reviewing Existing Plans

Lead with findings. Check for missing or unprotected topic artifacts,
Agent-authored authority, missing Execution Contract, unresolved product choices
silently embedded in design/code, missing phase decision-delta audit, continued
work after a provisional/conflict, vague or oversized units, speculative
construction, shadow validation, stale-plan continuation, mixed states, and
unsupported facts.

## Output Quality Checklist

- [ ] `decisions.md` is protected, user-authority only, and directly confirmed.
- [ ] `plan.md` contains Execution Contract, Design, Work Units, and active IDs.
- [ ] Unconfirmed material product choices stay in `plan.md`, never the baseline.
- [ ] High-impact or hard-to-reverse product choices are confirmed before implementation.
- [ ] Units are concrete, minimum-necessary, beneficial, side-effect-aware, and stoppable.
- [ ] Critical uncertainty is validated before disproportionate investment.
- [ ] Every material phase performs bounded Product Decision Delta audit.
- [ ] `provisional` / `conflict` blocks dependent continuation until user confirmation.
- [ ] Current evidence can revise the technical plan but not self-authorize product intent.
- [ ] Structure remains concise and only two fixed artifacts are required.
