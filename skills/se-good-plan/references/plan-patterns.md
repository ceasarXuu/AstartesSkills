# SE Good Plan Patterns

Use this reference for compact reusable structures. Keep output proportional to
risk, uncertainty, and the two required topic artifacts.

## Required Topic Artifact Guidance

For a formal repository plan, create or reuse:

```text
docs/releases/<confirmed-version>/<topic-slug>/
├── decisions.md
└── plan.md
```

Resolve the release version from explicit user or repository evidence. Do not
guess it. Reuse the exact files throughout planning and execution.

### `decisions.md`

The baseline is protected user authority, not an Agent working note:

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
- Release Version: v1.2.3
- Topic: account-locale
- Plan: ./plan.md

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | Locale remains optional | Preserve null-compatible reads | Do not require backfill before rollout | Existing accounts remain compatible | Existing null rows fail unchanged reads | user-confirmed-direct: "keep existing accounts compatible" | active |
```

Only directly confirmed user decisions appear here. Allowed statuses are
`active` and `superseded`. Do not use the baseline to store pending questions,
Agent proposals, implementation observations, or inferred intent.

A later replacement also needs direct user approval. Preserve the old row as
`superseded`; never rewrite it to make the history look cleaner.

### `plan.md`

The main plan links the baseline and persists execution rules:

```markdown
# <Topic> Engineering Plan

- Release Version: v1.2.3
- Topic Directory: docs/releases/v1.2.3/account-locale
- Decision Baseline: ./decisions.md
- Applicable Decisions: D1, D2
- Mode: Plan Authoring

## Execution Contract

- `decisions.md` is user-authority protected; each decision change requires
  explicit user approval and Agent self-approval is forbidden.
- Engineering evidence may revise this plan, not silently rewrite product authority.
- Unconfirmed material choices are deferred, provisional, or user-confirmed.
- Audit the Product Decision Delta after every material phase.
- `provisional` or `conflict` blocks dependent continuation until resolved.

## Design

...

## Work Units

...
```

Summarize applicable decision IDs; do not copy the full baseline into the plan.

## Material Product Decision Guidance

A choice belongs to the user decision domain when alternatives materially change
one or more of:

| Surface | Typical product questions |
|---|---|
| Domain model | Core entity identity, relationship, ownership, cardinality? |
| Lifecycle | State transitions, terminal/recovery behavior, replacement rules? |
| Defaults / automation | What happens automatically or by default? |
| User control / UX | What can the user do, undo, see, or recover from? |
| Persistence | What is saved, overwritten, retained, or deleted? |
| Permission / visibility | Who may see or operate on what? |
| Compatibility | How old clients/data/behavior are treated? |
| External effects / limits | Notifications, costs, side effects, quotas, concurrency, frequency? |

Equivalent private implementation choices are engineering-only.

For an unconfirmed material decision:

1. defer if the current unit can preserve the choice;
2. use a provisional choice only when local, necessary, reversible, and bounded;
3. ask the user first if it is high-impact, public/persistent, hard to reverse, or
   becomes an input to substantial downstream work.

Do not interpret “continue”, lack of objection, successful tests, or already
implemented behavior as approval for a product decision.

## Pending Product Decisions

Pending items stay in `plan.md`:

```markdown
## Pending Product Decisions

| ID | Decision Surface | Current / Proposed Behavior | Why Material | Evidence | Impact If Changed |
|---|---|---|---|---|---|
| P1 | Resume lifecycle | Current phase temporarily replaces the prior resume session | Changes history and recovery semantics | Phase 2 implementation | Persistence and UI require rework if changed |
```

A pending item is not a baseline decision and cannot be cited as user authority.
After direct user confirmation, write the approved decision to `decisions.md` and
update the plan references.

## Product Decision Delta Audit

After a material phase, audit only the product semantics introduced or changed by
that phase. Use changed code, tests, runtime behavior, API/schema/model changes,
defaults, persistence, permissions, compatibility, and user-visible states as
bounded evidence. Do not rescan the whole repository looking for every possible
product decision.

```markdown
## Product Decision Delta

| Phase | Decision Surface | Implemented / Observed Semantics | Baseline Coverage | Classification | Required Action |
|---|---|---|---|---|---|
| Phase 2 | Error visibility | Failed tasks remain visible | D4 | covered | none |
| Phase 2 | Cache identity | Composite internal key | n/a | engineering-only | none |
| Phase 2 | Resume lifecycle | Resume replaces prior session | none | provisional | P1: ask user before dependent work |
```

Classifications:

- `covered`: cite an active D-ID.
- `engineering-only`: no material product semantics; no user confirmation needed.
- `provisional`: temporary unconfirmed product behavior; record a pending item and
  stop dependent work until the user decides.
- `conflict`: implementation/evidence conflicts with active authority; pause and
  request a decision change.

This is bounded completeness: prove that the current phase delta was checked
across the material product surfaces, not that the Agent has discovered every
implicit decision in the entire codebase.

## Decision Baseline Use

Read `decisions.md` before revising Design or Work Units, before a material phase,
and during reconciliation. Engineering evidence may invalidate the plan. It
cannot silently lower, reinterpret, or remove a user-confirmed constraint.

A compact decision-change proposal states:

```markdown
- Affected Decision: D2
- New Evidence:
- Proposed Replacement:
- Benefit / Side Effects:
- Affected Work Units:
- User Confirmation:
```

Only after direct user confirmation may the Agent modify `decisions.md`.

## Task-Specific Additions

### Feature Development

Separate contract, production path, integration entry, user/system validation,
and controlled release. Confirm material product behavior before broad integration.
Avoid generic extension frameworks until a current variation proves the need.

### Bug Fix

Identify the exact faulty branch, condition, transition, query, handler, or
configuration and the smallest correction. Do not turn a local bug fix into an
unconfirmed product behavior change.

### Refactor

Preserve product semantics unless the protected baseline explicitly changes them.
Separate seam, caller migration, default switch, and cleanup.

### Data Or Architecture Migration

Validate high-risk compatibility, routing, data-quality, or reversibility with
bounded evidence. Reconcile technical evidence and product-decision delta after
material migration phases.

### Performance Optimization

Start with a baseline and one bottleneck hypothesis. Do not implement the complete
optimization stack during validation; measured results may make later units
unnecessary.

### Security Or DevOps Change

Cover permission, sensitive-data, audit, secret, deployment, and rollback
boundaries that actually apply. Platform convenience cannot override protected
privacy or operating-model decisions.

## Minimum Necessary Construction Guidance

Ask in order:

1. Can obsolete logic be deleted?
2. Can the existing path be changed directly?
3. Can a current mechanism be reused without widening responsibility?
4. Is narrow local logic sufficient?
5. Which current variation proves a new abstraction?
6. Which measured constraint proves new infrastructure is needed?

Reject one-implementation frameworks, configuration replacing decisions,
unmeasured caches/queues/retries, future-proofing, incidental refactors, and
temporary paths without removal criteria.

## Pre-Investment Validation Guidance

Trigger only when failure of a critical assumption would waste substantial later
work. Prefer Static/Observed evidence, then Mock/Sandbox, then the smallest
throwaway Prototype. State `enough:` and `not proven:`, plus explicit Budget,
Allowed, Forbidden, Stop, and Cleanup/Promotion boundaries.

Over-validation includes production-path changes, formal schema/default/deployment
changes, production dependency on validation code, complete hardening, or cost
approaching the formal implementation.

## Evidence Reconciliation Guidance

At a material phase boundary, do not treat completion as permission to continue.
Record evidence, affected conclusions, Decision Baseline Impact, downstream
changes, plan validity, and next action.

Decision Baseline Impact values:

- `aligned`
- `conflict-found`
- `change-proposed`
- `re-confirmation-required`

A baseline conflict, material `provisional`, or material `conflict` cannot use
`continue`.

## Compact Structures

### Work Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

### Phase Reconciliation

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
```

## Wording Guardrails

| Vague wording | Required replacement |
|---|---|
| user approved / confirmed | direct user confirmation evidence for the specific decision |
| user did not object | pending; silence is not approval |
| current code already does this | observed implementation, not product authority |
| update decisions.md | identify explicit user approval before the write |
| follow the plan | reconcile evidence, active decisions, and phase delta first |
| validate feasibility | assumption, threshold, budget, isolation, stop |
| minimal impact | Complexity delta plus Reach/Cost |

## Anti-Patterns

Reject unprotected baselines, Agent self-approval, pending decisions stored as
baseline authority, missing Execution Contract, unreviewed material phase deltas,
continued work after provisional/conflict, guessed version paths, copied baselines,
shadow validation, stale-plan continuation, speculative construction, generic
Benefits/Side Effects, oversized units, mixed states, unsupported facts, and
invented commitments.
