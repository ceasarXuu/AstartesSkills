# SE Good Plan Patterns

Use this reference for task-specific safety additions and compact reusable
structures. Keep output proportional to risk and uncertainty.

## Task-Specific Additions

### Feature Development

Separate contract, production path, integration entry, user/system validation,
and controlled release. Validate external capability or critical UX/technical
assumptions before building broad integration. Avoid generic extension frameworks
until a second current consumer or variation is confirmed.

### Bug Fix

Identify the exact faulty branch, condition, transition, query, handler, or
configuration and the smallest correction. Existing reproduction evidence often
makes extra pre-investment validation unnecessary. Do not use a local bug to
justify a global framework.

### Refactor

Preserve external behavior unless explicitly changing it. Separate seam,
one module/caller migration, default switch, and cleanup. Validate only uncertain
structural assumptions that could invalidate the refactor; do not implement the
new architecture merely to prove it.

### Data Migration

Separate schema preparation, migration job, rehearsal, batches, comparison,
cutover, and compensation/cleanup. Before major investment, use samples or a
bounded sandbox to validate transform feasibility, data quality assumptions, and
reversibility. A validation spike must not perform the production migration.

### Architecture Migration

Validate the highest-risk compatibility, routing, dependency, or data-consistency
assumption with the smallest isolated evidence. Then separate compatibility,
dual-run, traffic movement, fallback, cutover, and decommissioning. Reconcile the
plan after each traffic or dependency phase because runtime evidence may change
the remaining sequence.

### Performance Optimization

Start with baseline and one bottleneck hypothesis. A trace, targeted benchmark,
or isolated experiment should establish investment confidence; do not build the
complete optimization stack during validation. Reconcile after each optimization
because measured attribution can make later units unnecessary.

### Security Change

Cover threat model, permissions, sensitive data, abuse cases, tests, audit
logging, review, and emergency rollback. Use bounded validation for uncertain
platform or policy behavior, but do not weaken production boundaries or install
a broad policy engine merely to validate one rule.

### DevOps / CI/CD

Separate build graph, cache, test selection, artifact, secret/permission,
deployment, and rollout. Validate uncertain tool or cache behavior in an isolated
workflow or disposable branch. Reconcile after each gate change because actual
latency, failure locality, and evidence coverage may invalidate later work.

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
substantial later work. Choose the lowest-cost credible method:

| Evidence Level | Appropriate use |
|---|---|
| Static Evidence | official docs, source, type signatures, contracts, existing tests |
| Observed Evidence | current logs, metrics, data samples, existing runtime behavior |
| Mock Evidence | parser/protocol shape where real dependency access is unavailable |
| Sandbox Evidence | isolated real request or disposable environment |
| Prototype Evidence | minimal throwaway mechanism proof, not production integration |
| Production Evidence | read-only or narrowly controlled observation of the formal path |

A strong validation row says both:

```text
enough: the exact observation needed to justify investment;
not proven: correctness, scale, edge cases, hardening, or production readiness left for implementation.
```

Budget/Isolation must state:

```text
Budget: explicit time/code/environment cap;
Allowed: disposable artifact or read-only action;
Forbidden: production entry/schema/default/deployment/public-abstraction changes.
```

Stop/Cleanup must state when evidence is sufficient or impossible and whether the
artifact is deleted, retained as a test, or rewritten under production standards.

Over-validation signals:

- validation touches multiple production modules;
- formal schema, default, deployment, or public API changes are required;
- validation code becomes a production dependency;
- full error handling, complete compatibility, production observability, or all
  edge cases are implemented;
- validation cost approaches the expected formal implementation;
- no budget, stop condition, or cleanup boundary exists.

## Evidence Reconciliation Guidance

At a material phase boundary, current evidence may confirm the plan or change it.
Do not treat phase completion as automatic permission to continue.

Use conclusion prefixes:

- `current:` evidence still supports the prior conclusion;
- `qualified:` conclusion remains true only under narrower conditions;
- `superseded:` a better conclusion replaces it;
- `invalidated:` evidence disproves it;
- `needs-revalidation:` evidence is insufficient or stale.

Plan-validity decisions:

| Plan Validity | Expected action |
|---|---|
| valid | continue, unless deliberately paused |
| valid-with-qualifications | continue with explicit downstream qualifications or revise |
| needs-revision | revise or pause; never continue unchanged |
| invalidated | stop, pause, or redesign; never continue unchanged |

Material evidence delta includes changed feasibility, dependency behavior,
benefit, side effects, cost order, security/data/compatibility exposure, critical
path, necessity of later units, or discovery of a substantially smaller path.
Local implementation detail changes that do not affect downstream inputs do not
require plan rewriting.

Preserve old conclusions in history. Record which evidence changed them and
which units are added, removed, split, reordered, or revalidated.

## Benefit And Side Effects Guidance

Every unit translates technical effect into wider project value and states:

```text
Complexity: <net code/concept/state/path/dependency/config delta>;
Reach/Cost: <affected surfaces and continuing delivery/runtime/operational cost>.
```

Side Effects are expected impacts. Uncertain failure scenarios belong in Risks.

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

### Execution Tracking

```markdown
| Work Unit | Execution Status | Evidence | Missing Evidence | Decision |
|---|---|---|---|---|
```

### Phase Reconciliation

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|
```

### Risks

```markdown
| Risk | Trigger Signal | Mitigation | Safe Stop / Fallback |
|---|---|---|---|
```

## Wording Guardrails

| Vague wording | Required replacement |
|---|---|
| validate feasibility | critical assumption, decision, evidence threshold, budget, isolation, stop |
| build a prototype | smallest disposable mechanism and explicit production changes forbidden |
| fully validate | investment-confidence threshold plus what remains unproven |
| tests passed | evidence level and exact claim supported |
| follow the plan | reconcile current evidence against assumptions and downstream validity |
| update the plan | preserve prior conclusion, cite evidence, and list downstream changes |
| minimal impact | Complexity delta plus Reach/Cost |
| future-proof | current need or preserved decision boundary without implementation |

## Anti-Patterns

Reject plans that skip a material feasibility gate, turn validation into shadow
implementation, present Mock/Prototype evidence as production evidence, validate
without budget or cleanup, continue after invalidating evidence, silently rewrite
prior conclusions, or mechanically follow stale downstream work. Also reject
speculative construction, generic Benefits/Side Effects, oversized units, mixed
states, template filler, unsupported facts, and invented commitments.
