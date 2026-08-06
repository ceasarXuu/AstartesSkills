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

Keep the product decision baseline small:

```markdown
# Product Decision Baseline

- Release Version: v1.2.3
- Topic: account-locale
- Plan: ./plan.md
- Status: Active

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | Locale remains optional | Preserve null-compatible reads | Do not require backfill before rollout | Existing accounts must stay compatible | Existing null rows fail reads | user-confirmed: request review | active |
```

Use `proposed` for an Agent interpretation that still needs confirmation.
Never silently edit an active decision. Preserve it as `superseded` when the user
confirms a replacement.

Include decisions only when changing them would materially alter product logic,
scope, user expectations, or priority. Do not duplicate implementation details,
coding conventions, every risk, or the whole plan.

### `plan.md`

The main plan links the baseline and includes both design and execution:

```markdown
# <Topic> Engineering Plan

- Release Version: v1.2.3
- Topic Directory: docs/releases/v1.2.3/account-locale
- Decision Baseline: ./decisions.md
- Applicable Decisions: D1, D2
- Mode: Plan Authoring

## Design

...

## Work Units

...
```

Summarize applicable IDs; do not copy the full decision table into `plan.md`.
Validation, phases, and reconciliation remain in this file when triggered.

## Decision Baseline Use

Read `decisions.md`:

- before writing or revising Design and Work Units;
- before starting a material phase;
- while reconciling phase evidence;
- before accepting scope expansion, a new product behavior, or removal of an
  existing constraint.

When evidence conflicts with a technical assumption, revise the plan. When
evidence conflicts with an active product decision, pause and request a product
decision change. Do not let implementation difficulty, existing code, or sunk
cost silently redefine user intent.

A compact change proposal states:

```markdown
- Affected Decision: D2
- New Evidence:
- Proposed Replacement:
- Benefit / Side Effects:
- Affected Work Units:
- User Confirmation:
```

After confirmation, retain D2 as `superseded`, add or activate its replacement,
and revise `plan.md`.

## Task-Specific Additions

### Feature Development

Separate contract, production path, integration entry, user/system validation,
and controlled release. Confirm product-scope decisions before building broad
integration. Avoid generic extension frameworks until a second current consumer
or variation is confirmed.

### Bug Fix

Identify the exact faulty branch, condition, transition, query, handler, or
configuration and the smallest correction. Do not use a local bug to justify a
global framework or an unconfirmed product behavior change.

### Refactor

Preserve external behavior unless an active product decision explicitly changes
it. Separate seam, caller migration, default switch, and cleanup. Do not let
structural convenience override Must Not Do boundaries.

### Data Or Architecture Migration

Validate the highest-risk compatibility, routing, data-quality, or reversibility
assumption with bounded evidence. Separate preparation, execution, cutover,
fallback, and cleanup. Reconcile runtime evidence and decision-baseline impact
after each material migration phase.

### Performance Optimization

Start with a baseline and one bottleneck hypothesis. Validate investment
confidence without implementing the complete optimization stack. Reconcile after
each optimization because measured attribution can make later units unnecessary.

### Security Or DevOps Change

Cover permission, sensitive-data, audit, secret, deployment, and rollback
boundaries that actually apply. Do not alter an active product privacy or
operating-model decision merely because a platform default is easier.

## Minimum Necessary Construction Guidance

Ask in order:

1. Can obsolete logic be deleted?
2. Can the existing path be changed directly?
3. Can a current mechanism be reused without widening responsibility?
4. Is narrow local logic sufficient?
5. Which current variation proves a new abstraction?
6. Which measured constraint proves new infrastructure is needed?

Reject one-implementation frameworks, configuration replacing decisions,
unmeasured caches/queues/retries, generic future-proofing, incidental refactors,
and temporary paths without removal criteria.

## Pre-Investment Validation Guidance

Trigger validation only when failure of a critical assumption would waste
substantial later work. Choose the lowest-cost credible evidence:

| Evidence Level | Appropriate use |
|---|---|
| Static Evidence | docs, source, contracts, existing tests |
| Observed Evidence | current logs, metrics, data samples, runtime behavior |
| Mock Evidence | parser/protocol shape when real access is unavailable |
| Sandbox Evidence | isolated real request or disposable environment |
| Prototype Evidence | minimal throwaway mechanism, not production integration |
| Production Evidence | read-only or narrowly controlled formal-path observation |

A validation row states:

```text
enough: observation needed to justify investment;
not proven: correctness, scale, edge cases, hardening, or production readiness.
```

Budget/Isolation states explicit Budget, Allowed, and Forbidden scope.
Stop/Cleanup states when to stop and whether the artifact is deleted, retained
as a test, or rewritten under production standards.

## Evidence Reconciliation Guidance

At a material phase boundary, do not treat completion as permission to continue.
Record evidence, affected conclusions, decision-baseline impact, downstream
changes, plan validity, and next action.

Decision Baseline Impact values:

- `aligned`: evidence and work remain inside active decisions;
- `conflict-found`: current work or evidence conflicts with an active decision;
- `change-proposed`: a replacement decision has been presented;
- `re-confirmation-required`: downstream work remains paused pending the user.

A conflict cannot use `continue`.

Conclusion prefixes remain `current`, `qualified`, `superseded`, `invalidated`,
or `needs-revalidation`. Preserve history and list units added, removed, split,
reordered, or revalidated.

## Benefit And Side Effects Guidance

Every unit translates technical effect into wider project value and states:

```text
Complexity: <net code/concept/state/path/dependency/config delta>;
Reach/Cost: <affected surfaces and continuing delivery/runtime/operational cost>.
```

## Compact Structures

### Work Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

### Pre-Investment Validation

```markdown
| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
```

### Phase Reconciliation

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
```

## Wording Guardrails

| Vague wording | Required replacement |
|---|---|
| confirmed requirement | decision ID plus user-confirmation evidence |
| update the decisions | preserve old row, record confirmation, activate replacement |
| follow the plan | reconcile evidence and active decisions before continuing |
| validate feasibility | assumption, decision, threshold, budget, isolation, stop |
| build a prototype | smallest disposable mechanism and forbidden production changes |
| minimal impact | Complexity delta plus Reach/Cost |
| future-proof | current need or preserved boundary without implementation |

## Anti-Patterns

Reject missing or merged topic artifacts, guessed version paths, inferred active
decisions, plans without Design or Work Units, copied decision tables inside the
plan, silent decision edits, and continued work after a decision conflict. Also
reject shadow validation, stale-plan continuation, speculative construction,
generic Benefits/Side Effects, oversized units, mixed states, unsupported facts,
and invented commitments.
