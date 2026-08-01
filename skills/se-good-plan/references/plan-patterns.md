# SE Good Plan Patterns

Use this reference for task-specific safety additions and compact reusable
structures. Keep output proportional to risk.

## Task-Specific Additions

### Feature Development

Separate contract, production path, integration entry, user/system validation,
and controlled release. Do not combine API, persistence, client, deployment, and
cleanup into one unit. Avoid generic extension frameworks until a second current
consumer or variation is confirmed.

### Bug Fix

Identify the exact faulty branch, condition, transition, query, handler, or
configuration and the smallest correction. Do not use a local bug to justify a
new global error framework unless the same confirmed failure class exists across
current modules.

### Refactor

Preserve external behavior unless explicitly changing it. Separate seam
creation, migration of one module/caller group, default switch, and cleanup.
Prefer deleting duplication or changing the existing structure over introducing
parallel abstractions.

### Data Migration

Separate schema preparation, job implementation, rehearsal, batches,
consistency comparison, cutover, and compensation/cleanup. State idempotency,
retry/resume, partial failure, reversibility, and the temporary complexity of
dual paths or migration artifacts.

### Architecture Migration

Separate compatibility infrastructure, route selection, dual-run validation,
traffic movement, fallback, cutover, and decommissioning. Every temporary path
requires removal criteria.

### Performance Optimization

Start with a baseline and one bottleneck hypothesis. Implement one optimization
at a time. Side Effects include cache/state growth, invalidation complexity,
resource tradeoffs, and broader validation scope.

### Security Change

Cover threat model, permissions, sensitive data, abuse cases, tests, audit
logging, review, and emergency rollback. Do not introduce broad policy engines
for one rule unless current permission variation proves the need.

### DevOps / CI/CD

Separate build graph, cache, test selection, artifact, secret/permission,
deployment, and rollout changes. Side Effects include CI latency, cache
correctness burden, environment cost, and failure-locality changes.

## Minimum Necessary Construction Guidance

Ask in order:

1. Can obsolete logic be deleted?
2. Can the existing path be changed directly?
3. Can a current mechanism be reused without widening its responsibility?
4. Is narrow local logic sufficient?
5. Which current variation or second consumer proves a new abstraction?
6. Which measured constraint proves a new dependency or infrastructure is needed?

High-risk overbuilding signals:

- interface, factory, provider, registry, strategy, or plugin with one current implementation
- configuration added instead of making a clear current decision
- cache, queue, retry, fallback, or async path without a measured failure/latency need
- generic framework built for possible future use
- temporary compatibility path without removal criteria
- incidental refactor unrelated to the requested outcome

## Benefit Guidance

Translate technical effect into why the unit matters to project participants.
Reject generic claims or duplicates of Resulting Behavior.

| Technical effect | Suitable Benefit |
|---|---|
| nullable field added without changing reads | Enables later rollout without breaking existing accounts |
| validation centralized in one handler | Prevents inconsistent data and reduces support diagnosis time |
| one caller group routed to a new path | Limits blast radius and makes production impact attributable |
| obsolete path removed after zero traffic | Reduces maintenance and compatibility cost after safe retirement |

## Side Effects Guidance

Use two concise clauses in every unit:

```text
Complexity: <net code/concept/state/path/dependency/config delta>;
Reach/Cost: <affected surfaces and continuing delivery/runtime/operational cost>.
```

Consider these dimensions when applicable:

| Dimension | Questions |
|---|---|
| Code and architecture | New/removed files, abstractions, branches, states, dependencies, configs, schemas, runtime paths? |
| Blast radius | Which modules, services, callers, clients, APIs, data, jobs, or pipelines change? |
| Validation and delivery | Does build/test scope, CI latency, release coordination, or rollback effort increase? |
| Runtime and infrastructure | CPU, memory, IO, storage, network, third-party or cloud cost? |
| Operations and support | New logs, alerts, dashboards, runbooks, on-call, debugging, support, or ownership burden? |
| Security and compliance | New permission, data exposure, privacy, audit, or compliance surface? |
| Lifecycle | Temporary logic, migration artifacts, compatibility paths, cleanup deadline, or lock-in? |

Side Effects are expected costs/impacts. Put uncertain failure scenarios in
Risks instead.

## Work Unit Quality Examples

### Invalid: Speculative Construction

```markdown
| W1 | Generalize locale lookup | internal | src/account/locale.ts | LocaleProvider | Introduce a provider interface around the only current locale source | Locale lookup goes through a provider | Makes future integrations easier | Complexity: adds an interface, factory, and registry; Reach/Cost: all locale callers depend on the new layer | Run locale tests | Revert the layer | planned |
```

Invalid because no current variation proves the abstraction is needed; its
Benefit is speculative while complexity and maintenance increase immediately.

### Valid: Small Closed-Loop Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Store account locale | data | db/migrations/042_account_locale.sql | accounts.locale | Add a nullable locale column without changing reads | Existing reads remain compatible and the target field exists | Enables later rollout without breaking existing accounts | Complexity: +1 nullable field and migration artifact; Reach/Cost: database deployment and rollback coordination increase, read paths stay unchanged | Apply migration in staging and inspect schema | Reverse before writes | planned |
| W2 | Accept locale updates | API | src/account/update_account.ts | updateAccountLocale() | Add validation and persistence for locale | Valid locale values persist through the existing endpoint | Prevents inconsistent locale data across clients | Complexity: +1 validation/persistence branch, no new abstraction or dependency; Reach/Cost: account API and contract-test scope increase | Run valid/invalid contract tests | Disable field handling | planned |
| W3 | Expose locale control | client | web/settings/LocaleField.tsx | LocaleField | Wire the control to the existing update endpoint | Users can update locale | Removes support intervention for locale changes | Complexity: +1 UI integration path using existing components; Reach/Cost: web bundle, UI tests, and support documentation are affected | Run component and E2E tests | Hide with existing flag | planned |
```

## Compact Supporting Tables

### Planning Artifacts

```markdown
| Artifact | Kind | Expected Output | Status |
|---|---|---|---|
| ... | discovery / design | ... | planned / drafted / reviewed / verified |
```

### Execution Tracking

```markdown
| Work Unit | Execution Status | Evidence | Missing Evidence | Decision |
|---|---|---|---|---|
| W1 | not-started / in-progress / verified / blocked / failed / rolled-back | ... | ... | proceed / pause / n/a |
```

### Formal Benefit Validation

Use only when measurable, disputed, or decision-critical.

```markdown
| Work Unit | Benefit Hypothesis | Metric | Baseline | Target | Method | Data Source | Window | Threshold |
|---|---|---|---:|---:|---|---|---|---|
```

### Risks

```markdown
| Risk | Trigger Signal | Mitigation | Safe Stop / Fallback |
|---|---|---|---|
```

## Wording Guardrails

| Vague wording | Required replacement |
|---|---|
| add abstraction | current variations/consumers, smaller alternative, exact boundary, retirement if temporary |
| future-proof / for flexibility | confirmed current need or preserve a decision boundary without implementation |
| minimal impact / low risk | Complexity delta plus affected surfaces and continuing cost |
| optimize cache | key/value path, invalidation, TTL, fallback, metric, state/cost side effects |
| improve error handling | named failure state and exact behavior |
| improve quality / add value | affected audience and specific Benefit |
| run tests | exact target, command, assertion, or threshold |

## Anti-Patterns

Reject plans with speculative construction, one-implementation frameworks,
configuration replacing decisions, unmeasured caches/queues/retries, hidden
code/state/path growth, generic Side Effects, missing module/cost impact,
oversized units, temporary paths without cleanup, mixed statuses, template
filler, unsupported facts, or invented commitments.
