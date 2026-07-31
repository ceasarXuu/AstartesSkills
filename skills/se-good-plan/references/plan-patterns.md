# SE Good Plan Patterns

Read this reference for task-specific safety additions and compact reusable
structures. Keep the final plan proportional to the actual engineering risk.

## Task-Specific Additions

### Feature Development

Cover the user or system path, API and data changes, permission boundaries,
compatibility, regression tests, release strategy, and observable state
transitions.

Prefer separate units for one contract, one production path, one integration
entry, one user/system-path validation, and one controlled release boundary.
Do not combine API, persistence, client wiring, deployment, and cleanup into one
"implement feature" unit.

### Bug Fix

Cover reproduction, root cause, impact scope, the smallest behavior-changing
fix, regression proof, prevention, release, rollback, and recurrence signals.
The fix unit should identify the exact faulty branch, condition, state
transition, query, handler, or configuration and the exact correction.

### Refactor

Preserve external behavior unless behavior change is an explicit goal. Separate
compatibility or seam creation, migration of one module or caller group,
default-path switch, and old-path cleanup. Structural change and behavior
change should normally be different units.

### Data Migration

Separate schema preparation, migration job implementation, rehearsal, batch
execution, consistency comparison, cutover, and compensation or cleanup when
they exist. State reversibility, partial-failure behavior, idempotency, retry or
resume behavior, source-to-target comparison, and per-batch evidence.

### Architecture Migration

Separate compatibility infrastructure, route selection, dual-run validation,
traffic movement, fallback, cutover, and decommissioning. Do not hide these
behind one "migration implementation" phase.

### Performance Optimization

Start with a baseline and one bottleneck hypothesis. Implement and measure
individual optimizations separately so the effect and Benefit of each change
remain attributable.

Relevant metrics may include p50, p95, p99, throughput, error rate, CPU, memory,
IO, slow queries, build time, or cache hit rate.

### Security Change

Cover threat model, permission boundaries, sensitive-data handling, abuse
cases, security tests, audit logging, review, and emergency rollback. Separate
policy or permission changes from data migration, client integration, and
release actions when they can be checked independently.

### DevOps / CI/CD

Separate build graph changes, cache strategy, test selection, artifact
management, permission or secret handling, deployment flow, and rollout. Each
pipeline unit must identify the exact workflow, job, step, configuration, or
command being changed.

## Benefit Guidance

Every work unit requires a Benefit that a broader project member can understand.
The Benefit should translate the technical effect into why the unit matters.

| Technical effect | Suitable Benefit |
|---|---|
| nullable field added without changing reads | Enables later API and client rollout without breaking existing accounts |
| validation centralized in one handler | Prevents inconsistent data across clients and reduces support diagnosis time |
| one caller group routed to a new path | Limits blast radius and makes production impact attributable |
| obsolete path removed after zero traffic | Reduces maintenance and compatibility cost after safe retirement |
| structured failure reason emitted | Lets support and on-call identify the failing step without reproducing the full flow |

A Benefit may be qualitative. Use formal metrics only when the claim is
measurable or decision-critical. Reject generic phrases such as "improves
quality", "adds value", or "makes the system better".

## Work Unit Quality Examples

### Invalid: Abstract

```markdown
| W1 | Improve caching | cache | backend | cache layer | Optimize caching | Faster requests | Improves quality | Run tests | Revert | planned |
```

Why invalid:

- `backend` and `cache layer` are not concrete enough
- `Optimize caching` does not describe the mechanism
- `Improves quality` does not identify who benefits or how
- verification is not tied to a behavior or threshold

### Invalid: Coupled

```markdown
| W2 | Ship new account flow | data + API + client + deployment | several services | account flow | Add schema, update API, wire UI, deploy canary | New flow works | Delivers the feature | E2E | Roll back everything | planned |
```

Why invalid:

- multiple independent change axes
- several primary actions
- no isolated verification or rollback boundary
- the Benefit is too broad to explain the value of each hidden change

### Valid: Small Closed-Loop Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Store account locale | data | db/migrations/042_account_locale.sql | accounts.locale | Add a nullable locale column without changing reads | Existing reads remain compatible and the target field exists | Enables later API and client rollout without breaking existing accounts | Apply migration in staging and inspect schema | Reverse migration before any writes | planned |
| W2 | Accept locale updates | API | src/account/update_account.ts | updateAccountLocale() | Add validation and persistence for the locale field | Valid locale values persist through the existing endpoint | Keeps locale rules consistent across clients and prevents invalid account data | Contract test for valid and invalid locale values | Disable field handling and keep the nullable column | planned |
| W3 | Expose locale control | client | web/settings/LocaleField.tsx | LocaleField | Wire the control to the existing account update endpoint | Users can view and update locale | Lets users manage locale without support intervention | Component test and settings-flow E2E | Hide the control with the existing feature flag | planned |
```

## Compact Supporting Tables

Use only tables that add decision or execution value.

### Planning Artifacts

```markdown
| Artifact | Kind | Expected Output | Status |
|---|---|---|---|
| ... | discovery / design | ... | planned / drafted / reviewed / verified |
```

### Execution Tracking

Use only when actual implementation evidence exists.

```markdown
| Work Unit | Execution Status | Evidence | Missing Evidence | Decision |
|---|---|---|---|---|
| W1 | not-started / in-progress / verified / blocked / failed / rolled-back | ... | ... | proceed / pause / n/a |
```

### Verification

```markdown
| Work Unit | Validation Type | Method | Passing Standard |
|---|---|---|---|
| W1 | correctness / compatibility / benefit / security / observability | exact test, command, review, metric, log, trace, or artifact | explicit pass condition |
```

### Formal Benefit Validation

Use when a Benefit is measurable, disputed, or material to a decision or gate.

```markdown
| Work Unit | Benefit Hypothesis | Metric | Baseline | Target | Measurement Method | Data Source | Observation Window | Pass / Fail Threshold |
|---|---|---|---:|---:|---|---|---|---|
| W1 | ... | ... | ... | ... | ... | ... | ... | ... |
```

Unknown baselines or targets remain `Unknown` and are discovered before making
a quantitative benefit claim.

### Change-Chain Logging

```markdown
| Change Link | Key State | Success Signal | Failure Signal | Failure Reason Field | Correlation Field | Consumer |
|---|---|---|---|---|---|---|
| ... | ... | ... | ... | error_code / reason / validation_error | request_id / job_id / trace_id / entity_id | on-call / owner / dashboard / audit |
```

Use this only where state reconstruction matters.

### Risks

```markdown
| Risk | Trigger Signal | Mitigation | Safe Stop / Fallback |
|---|---|---|---|
| ... | ... | ... | ... |
```

## Wording Guardrails

| Vague wording | Required replacement |
|---|---|
| refactor module | exact location, target object, structural action, preserved invariant |
| add abstraction | interface or boundary introduced, callers moved, compatibility behavior |
| optimize cache | key, value, read/write path, invalidation, TTL, fallback, metric |
| improve error handling | named error or failure state and exact resulting behavior |
| improve quality / add value | affected audience and specific project, user, reliability, delivery, cost, support, or operational Benefit |
| run tests | exact test target, command, assertion, or passing threshold |
| implement feature | separately named contract, production path, integration, and release units |
| finish phase | required phase-local evidence; no completion claim in Plan Authoring mode |

## Anti-Patterns

Reject plans that contain:

- abstract logic discussion without concrete locations, objects, and actions
- missing, generic, or behavior-duplicating Benefits
- one row or phase that combines multiple independent engineering changes
- a large implementation phase whose internal work cannot be audited separately
- future execution work marked complete, landed, verified, or proceed
- design or discovery artifacts using code implementation states
- repeated global and per-phase tables containing the same information
- ceremonial sections filled with `N/A` or generic statements
- production changes without relevant rollback and observability
- data migration without idempotency, validation, and compensation
- security work without permission boundaries and audit strategy
- unsupported project facts or invented delivery commitments
