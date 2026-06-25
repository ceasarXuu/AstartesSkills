# SE Good Plan Patterns

Read this reference when `se-good-plan` needs task-specific phase models,
required sections, or templates. Keep output proportional to task risk.

## Task-Specific Requirements

### Feature Development

Must cover user path, API and data model changes, permission boundaries,
acceptance criteria, compatibility, regression testing, release strategy, and
logs for key user-path and system-path state transitions.

Recommended phases:

1. Requirements and current-state confirmation
2. Technical design
3. Interface and foundation work
4. Feature implementation
5. Integration testing and acceptance
6. Canary release and monitoring

### Bug Fix

Must cover reproduction path, root cause, impact scope, fix design, regression
tests, prevention, release, rollback, and logs that reveal recurrence,
successful prevention, and failure reasons if the fix does not apply.

Required questions:

- Why did it happen?
- Which users, data, and paths were affected?
- How will the fix be proven?
- What prevents the same class of bug from returning?

Recommended sections:

- Reproduction
- Root Cause Analysis
- Impact Scope
- Fix Strategy
- Regression Tests
- Prevention Measures
- Release And Rollback

### Refactor

Must preserve external behavior unless behavior changes are explicit goals.
Must cover compatibility, incremental replacement, test coverage, old-logic
cleanup, and rollback.

Recommended phases:

1. Current-state inventory and test baseline
2. Target structure design
3. Compatibility or abstraction layer
4. Module-by-module migration
5. Regression validation
6. Default-path switch
7. Old implementation cleanup

Required rules:

- Each migration step must be independently verifiable.
- Old logic removal must happen after the new path is stable.
- Behavior changes must be separated from structural changes.

### Data Migration

Must cover data volume, data quality, migration, idempotency,
retry/resume behavior, dual-write or dual-read if needed, validation, rollback,
compensation, and per-batch or per-job logging for start, progress, validation,
commit, retry, compensation, and failure reason states.

Recommended phases:

1. Data current-state analysis
2. Migration design
3. Migration and validation script development
4. Small-scale rehearsal
5. Batched migration
6. Consistency validation
7. Cutover and old-data cleanup

Required rules:

- State whether migration is reversible.
- State what happens after partial failure.
- State whether scripts can be safely re-run.
- State how source and target data are compared.

### Architecture Migration

Must cover compatibility layer, dependency systems, traffic switching,
degradation path, data consistency, progressive rollout, and logs or traces that
show which route handled each request and why fallback or degradation occurred.

Recommended phases:

1. Current architecture and dependency inventory
2. Target architecture design
3. Compatibility and migration infrastructure
4. Dual-write or dual-read validation
5. Small-traffic canary
6. Phased traffic migration
7. Full cutover
8. Old system decommission

### Performance Optimization

Must start with a baseline and a bottleneck hypothesis. Include load testing,
comparison, regression risk, production observation, and logging or tracing that
can identify the slow link and failure reason without turning every request into
high-cardinality noise.

Required metrics when relevant:

- p50, p95, and p99 latency
- QPS or throughput
- error rate
- CPU, memory, and IO
- database slow queries
- cache hit rate

Recommended phases:

1. Baseline collection
2. Bottleneck analysis
3. Optimization design
4. Individual optimization implementation
5. Load test and comparison
6. Canary release and monitoring

### Security Change

Must cover threat model, permission boundaries, sensitive data, audit logging,
abuse cases, security tests, and emergency rollback.

Required inclusions:

- Threat Model
- Permission Matrix
- Sensitive Data Handling
- Abuse Cases
- Security Tests
- Audit Logging And Alerts
- Security Review

### DevOps / CI/CD

Must cover environment separation, build flow, test flow, release permissions,
failure recovery, artifact management, secret management, and pipeline logs that
capture stage state, artifact identity, success, failure, and failure reason.

Recommended phases:

1. Current pipeline inventory
2. Target process design
3. Base configuration and environment preparation
4. Pipeline implementation
5. Failure-mode and regression validation
6. Rollout and documentation

## Reusable Tables

### Metadata Block

```markdown
- Created:
- Updated:
- Version:
- Status: Draft | Reviewing | Approved | In Progress | Blocked | Completed | Deprecated
- Owner / Responsible:
- Related Systems:
- Related Links:
- Risk Level:
- Plan Type: Lightweight | Standard | Full
```

Do not invent owner, deadline, staffing, release date, or launch window values.
If they are not provided, write `Unknown` or list a verification step.

### Dependency Table

```markdown
| Dependency | Type | Current Status | Blocking Risk | Handling Plan |
|---|---|---|---|---|
| ... | system / person / data / environment / third-party | Ready / Pending / Unknown | ... | ... |
```

Dependency types include upstream services, downstream services, data sources,
third-party APIs, feature flag platforms, CI/CD systems, test environments,
monitoring platforms, security review, product confirmation, design artifacts,
and client releases.

### Implementation Completeness Matrix

```markdown
| Plan Item | Expected Behavior | Production Code Path | Integration Entry | Test Evidence | Runtime / Log Evidence | Mock / Stub Exposure | Status |
|---|---|---|---|---|---|---|---|
| ... | ... | file, function, module, or command | UI, API, job, CLI, pipeline, or service path | test path and assertion | command, log, trace, or artifact | none / test-only / blocks completion | planned / landed / partial / stub-only / mock-only / deferred |
```

Use this table for code-bearing implementation, refactor, migration, bug-fix,
DevOps, and release work. A plan item is complete only when the production code
path is wired through a real integration entry and validated with non-demo
evidence. Protocols, interfaces, schemas, entry points, scaffolding, mock or
fake data, demo scripts, and test-only wiring are not completion evidence by
themselves.

### Risk Table

```markdown
| Risk | Probability | Impact | Trigger Signal | Mitigation | Fallback |
|---|---:|---:|---|---|---|
| ... | Low / Medium / High | Low / Medium / High | ... | ... | ... |
```

Common risks:

- data corruption
- data inconsistency
- API incompatibility
- client parsing failure
- performance regression
- increased error rate
- rollback unavailable
- feature flag failure
- permission bypass
- sensitive data exposure
- dependency outage
- staging cannot model production traffic
- canary sample too small
- old logic removed too early
- documentation diverges from implementation

### Testing And Validation Table

```markdown
| Validation Type | Test Type | Scope | Execution Method | Passing Standard |
|---|---|---|---|---|
| Correctness | Unit | ... | ... | no regression in targeted logic |
| Correctness | Integration | ... | ... | expected system behavior works end to end |
| Correctness | Regression | ... | ... | no P0/P1 regressions or compatibility failures |
| Benefit | Performance | ... | ... | target speed, latency, throughput, or cost benefit is met |
| Benefit | Accuracy | ... | ... | target precision, recall, correctness rate, or quality lift is met |
| Security | Security | ... | ... | no unacceptable permission, data, or abuse-path risk |
```

Possible test types:

- unit tests
- integration tests
- E2E tests
- regression tests
- contract tests
- compatibility tests
- data consistency tests
- performance tests
- stress tests
- security tests
- canary validation
- manual acceptance

### Benefit Validation Table

```markdown
| Benefit Hypothesis | Metric | Baseline | Target | Measurement Method | Data Source | Observation Window | Pass / Fail Threshold |
|---|---|---:|---:|---|---|---|---|
| ... | p95 latency / accuracy / cost / error rate / conversion / toil hours | ... | ... | ... | ... | ... | ... |
```

Use benefit validation to prove the plan delivered value, not only correctness.
Correctness tests answer "does it work without breaking things?" Benefit tests
answer "did it improve the target outcome?" If baseline or target is unknown,
write `Unknown`, add baseline discovery to Phase 0, and do not invent a lift.

Common benefit categories:

- speed: latency, throughput, build time, recovery time
- accuracy: precision, recall, match rate, defect rate, false positive rate
- reliability: error rate, incident rate, retry rate, availability
- cost: cloud spend, CPU, memory, storage, operations time
- user outcome: conversion, completion rate, abandonment, time to complete
- developer outcome: lead time, test runtime, deploy frequency, toil hours

### Change-Chain Logging Matrix

```markdown
| Change Link | Key State | Success Signal | Failure Signal | Failure Reason Field | Correlation / Trace Field | Log Level | Consumer |
|---|---|---|---|---|---|---|---|
| ... | queued / started / validated / committed / published / rolled back | ... | ... | error_code / reason / exception / validation_error | request_id / job_id / trace_id / entity_id | info / warn / error | on-call / owner / dashboard / audit |
```

Use the logging matrix to make the plan observable along the whole change
chain. A complete row answers:

- where in the chain the state is emitted
- which key state proves the change is progressing
- what log, metric, trace, or audit event proves success
- what signal proves failure or ambiguity
- which structured field explains the failure reason
- which correlation or trace field links the event to a request, job, release,
  migration batch, entity, or user-visible operation
- who consumes the signal during rollout, debugging, audit, or support

Common chain links:

- user action, API ingress, authorization, validation, business operation,
  persistence, async enqueue, worker execution, downstream call, publish,
  notification, cache invalidation, rollback, compensation, and cleanup
- build trigger, test stage, artifact publish, deploy stage, health check,
  traffic shift, rollback, and post-release verification
- migration batch selection, read, transform, write, compare, commit, retry,
  resume, compensation, and final consistency check

Logging guardrails:

- Prefer structured fields over free-form messages for status and reason.
- Include enough correlation to reconstruct one affected request, job, batch,
  release, or entity across the chain.
- Avoid sensitive data, secrets, raw tokens, payment details, or unnecessary
  personal data in logs.
- Avoid unbounded high-cardinality labels in metrics; put detailed values in
  logs or traces when safe.
- Define sampling only after specifying which failures must always be captured.
- State retention, dashboard, alert, or runbook expectations when the change is
  production-impacting.

### Release, Rollback, And Fallback

```markdown
## Release, Rollback, And Fallback Strategy

### Release Strategy
- Release method:
- Canary scope:
- Expansion criteria:
- Pause criteria:
- Owner:
- Release window:

### Rollback Strategy
- Rollbackable changes:
- Non-directly rollbackable changes:
- Rollback triggers:
- Rollback steps:
- Rollback validation:
- Owner:

### Fallback / Degradation Strategy
- Degradable capability:
- Trigger:
- User-visible impact:
- System behavior while degraded:
- Recovery steps:

### Data Compensation Strategy
- Compensation required:
- Script or procedure:
- Validation:
- Failure handling:
```

### Observability And Success Metrics

```markdown
| Metric | Current Baseline | Target | Alert Threshold | Observation Window |
|---|---:|---:|---:|---|
| Error rate | ... | ... | ... | ... |
| p95 latency | ... | ... | ... | ... |
| Success rate | ... | ... | ... | ... |
| QPS | ... | ... | ... | ... |
| Resource usage | ... | ... | ... | ... |
```

Cover logs, metrics, traces, dashboards, alerts, user behavior, business
metrics, and data consistency metrics when relevant.

Observability must include log design, not only metric names. The plan should
show how operators identify the affected chain's current state, successful
completion, failed step, and failure reason during rollout and post-release
validation.

## Wording Guardrails

Replace vague wording with evidence:

| Vague phrase | Require |
| --- | --- |
| optimize | metric, baseline, target, measurement method |
| improve | target delta and validation method |
| benefit | benefit hypothesis, metric, baseline, target, and pass/fail threshold |
| complete tests | exact paths, test types, and passing standard |
| support | scenario, inputs, outputs, and acceptance criteria |
| handle errors | named errors and expected system behavior |
| ensure stability | health metrics and observation window |
| add logging | chain link, key state, success signal, failure signal, failure reason field, correlation field, consumer |
| launch soon | release gate, canary plan, and pause criteria |
| implemented | production code path, integration entry, test evidence, runtime/log evidence, and mock/stub exposure |

## Anti-Patterns

Do not output:

- a task list without problem, risk, validation, or rollback
- a roadmap without executable tasks and gates
- a technical solution without proof strategy
- production changes with only "tests pass" as a release gate
- acceptance plans that verify correctness but never test whether the expected
  benefit was achieved
- observability plans that list metrics but omit chain-state logs, failure
  signals, or failure reason fields
- implementation plans that treat protocols, scaffolds, mocks, fake data, demo
  scripts, or entry points as complete without production-path evidence
- data migration without idempotency, validation, and compensation
- security work without permission boundaries and audit strategy
- project-specific facts that were not provided or verified
