# Dev Loop Audit Playbook

Use this reference for a repository-wide audit or a targeted investigation of a
slow local, CI, test, build, environment, or coding-Agent feedback path.

The audit is incomplete until it assigns hard priority classes, selects one Next
Best Intervention, defines a validation gate, and states when the current
governance cycle should stop.

## 1. Audit Scope

Define one or more decision boundaries before measuring:

| Boundary | Start | End |
| --- | --- | --- |
| Local edit loop | source change completed | actionable local result available |
| Pre-push loop | commit ready | enough evidence to push safely |
| PR loop | branch pushed | required merge gates complete |
| Environment loop | clean checkout or new worktree | project ready for useful work |
| Agent loop | task execution starts | Agent has trustworthy completion evidence |
| Release loop | release candidate created | release evidence and rollback readiness complete |

Do not merge these into a single average when different decisions have different
critical paths.

## 2. Evidence Collection

### Repository structure

- language, package manager, lockfiles, toolchain versions;
- monorepo or multi-module boundaries;
- dependency direction and high-centrality shared modules;
- generated code, schemas, assets, and packaging stages;
- local development entry points and common commands.

### Build and task graph

- task inputs and outputs;
- dependency edges;
- incremental and daemon behavior;
- clean versus warm behavior;
- parallelism and hidden serialization;
- repeated compilation, generation, bundling, or packaging.

### Tests and checks

- unit, component, integration, contract, end-to-end, platform, and release tests;
- lint, format, static analysis, type checking, security, and license checks;
- trigger rules and affected-test selection;
- global fixtures, service startup, database setup, browser or simulator setup;
- flaky tests, retries, quarantine, and failure-localization quality.

### CI and gates

- workflow DAG and required checks;
- queue time, setup time, execution time, artifact time, and teardown time;
- repeated dependency installation or checkout;
- job fan-out and duplicated environment setup;
- non-blocking work on the merge critical path;
- path filters, change classification, matrix expansion, and cancellation rules.

### Cache and artifacts

- dependency, compiler, task, container-layer, and remote caches;
- exact key inputs and restore-key behavior;
- cache scope across branch, runner, worktree, platform, and developer;
- artifact handoff between jobs;
- lookup, transfer, compression, storage, and invalidation costs;
- deterministic output and cache-poisoning risks.

### Environment lifecycle

- worktree creation and teardown;
- development container lifecycle;
- build daemon persistence;
- local services, databases, emulators, browsers, and simulators;
- toolchain downloads and image builds;
- state unnecessarily destroyed between steps or Agent attempts.

### Coding-Agent execution

- repeated commands with unchanged inputs;
- subagents rebuilding or retesting the same state;
- worktrees that cannot share safe dependency or build caches;
- failure recovery that immediately clears all state;
- missing command-result ledger or inability to reuse evidence;
- full validation before the implementation is stable enough to justify it.

## 3. Baseline Record

For each representative run, record:

```markdown
| Run ID | Commit / Change | Boundary | Environment | Cache State | Command / Workflow | Duration | Result | New Evidence | Notes |
|---|---|---|---|---|---|---:|---|---|---|
| B1 | ... | local edit | developer machine | warm | ... | ... | pass / fail | ... | ... |
```

Useful scenarios:

1. narrow leaf-module change, warm state;
2. narrow leaf-module change, cold state;
3. shared-module or toolchain change;
4. ordinary PR required path;
5. full asynchronous, scheduled, or release validation;
6. new Agent worktree or subagent startup.

Run repeated measurements when variance could change the conclusion. Report
median and range or another robust summary rather than selecting the best run.

## 4. Step Map

Map the actual feedback path:

```markdown
| Step | Trigger | Depends On | Inputs | Output / Evidence | Duration | Blocking | Cache / Reuse | Failure Locality |
|---|---|---|---|---|---:|---|---|---|
| dependency restore | every job | checkout | lockfile, platform | environment only | ... | yes | partial | broad |
| type check | all changes | dependencies | source graph | type evidence | ... | yes | ... | precise |
```

For every step, ask:

1. Why did it run?
2. What distinct evidence did it produce?
3. Did it block the next decision?
4. Could the scope be smaller?
5. Could the result be safely reused?
6. Could it run in parallel?
7. Is its failure actionable and local?

## 5. Finding Taxonomy

### A. Build graph and dependency structure

- undeclared or overdeclared task inputs;
- leaf changes causing repository-wide rebuilds;
- generation, compilation, packaging, and release tasks fused together;
- high-centrality shared packages with avoidable dependencies;
- timestamp, absolute-path, random, or network inputs breaking determinism;
- incremental build disabled by workflow rather than tool limitations.

### B. Test layers and selection

- test layers duplicate the same evidence;
- every change triggers integration or end-to-end tests;
- test selection depends only on filenames and ignores dependency impact;
- global setup dominates test execution;
- shared mutable state prevents parallelism;
- slow failures provide poor localization;
- flaky retries inflate expected feedback cost.

### C. Gate policy and critical path

- every check is mandatory for every PR;
- release, compliance, matrix, or long-running work blocks low-risk changes;
- required checks have no owner or evidence rationale;
- independent jobs are serialized;
- job fan-out repeats expensive setup;
- cancelled or superseded commits continue consuming critical resources.

### D. Cache and artifacts

- key too broad, causing frequent misses;
- key too narrow, risking incorrect reuse;
- relevant compiler, lockfile, config, environment, or source inputs omitted;
- transient values invalidate all entries;
- caches are scoped so narrowly that branches, jobs, or worktrees cannot reuse;
- upload or download cost exceeds recomputation;
- expensive intermediate artifacts are discarded between jobs.

### E. Environment and cold state

- dependencies installed independently in multiple jobs;
- containers or images rebuilt after high-frequency source changes;
- daemons, services, databases, browsers, or simulators restarted unnecessarily;
- every worktree is treated as an isolated cold machine;
- cleanup policies destroy useful state without a correctness reason.

### F. Architectural validation amplification

- local modules depend on giant shared packages;
- integration requires starting the entire system;
- contract boundaries cannot be tested independently;
- code generation has no stable boundary;
- global initialization prevents isolated tests;
- a small schema or shared-library change has an unavoidable system-wide blast radius.

### G. Coding-Agent execution

- full build before and after every small edit;
- identical commands rerun without changed inputs;
- subagents do not share command evidence;
- failures trigger destructive reset before diagnosis;
- Agent chooses full validation because the project provides no affected-scope command;
- repeated environment bootstrap dominates task time.

## 6. Finding Record

Use one row per material finding:

```markdown
| ID | Domain | Priority Class | Symptom | Root Cause | Evidence | Critical-Path Cost | Frequency | Population | Confidence | Risk | Recommended Intervention |
|---|---|---|---|---|---|---:|---:|---|---|---|---|
| DL-01 | CI gates | P1 | ... | ... | file, log, run, measurement | ... | ... | ... | high / medium / low | ... | ... |
```

Do not state a root cause when only a correlation is known. Mark it as a
hypothesis and state the experiment needed to confirm it.

## 7. Hard Priority Ladder

Assign the priority class before calculating opportunity value.

| Priority | Name | Qualification | Typical examples |
| --- | --- | --- | --- |
| P0 | Restore trust or availability | The result may be wrong, a material change may be silently unvalidated, or the loop cannot complete reliably | stale cache reuse, unsafe test selection, required-check flakiness, local/CI inconsistency, hanging workflow |
| P1 | Remove blocking no-evidence work | The step blocks the decision but adds no distinct evidence | repeated dependency setup, unused artifact transfer, non-blocking packaging on PR path, duplicated Agent execution |
| P2 | Reduce validation amplification | Actual scope is materially wider than sufficient risk-based scope | leaf change triggers repository-wide build or complete E2E matrix |
| P3 | Improve reuse and incrementality | Necessary work is repeatedly recomputed | missing artifact reuse, poor cache scope, repeated cold environment, disabled daemon |
| P4 | Redesign test and gate architecture | Evidence roles, ownership, or trigger layers are structurally duplicated or misplaced | every check required on every PR, giant test suite, no high-risk path separation |
| P5 | Restore architectural locality | The architecture itself prevents local build or validation | giant shared module, global fixture, whole-system startup, unstable generation boundary |

Rules:

1. P0 must be restored or explicitly declared blocking before normal speed work.
2. A high-value P3-P5 item cannot outrank an unresolved P0.
3. When expected benefits are comparable, lower priority number wins.
4. Select a lower-priority prerequisite first only when the dependency is
   explicit and evidence-backed.
5. Record every deviation from the normal ladder.

## 8. Governance Stage Sequence

Use the default sequence:

```text
Stage 0: stabilize trust and availability
Stage 1: remove blocking no-evidence waste
Stage 2: reduce build and validation scope
Stage 3: improve reuse, incrementality, and parallelism
Stage 4: redesign test and gate responsibilities
Stage 5: restore architectural locality
```

| Stage | Primary priorities | Exit evidence |
| --- | --- | --- |
| 0. Stabilize | P0 | outputs and validation decisions are trustworthy and the loop completes reliably |
| 1. Remove waste | P1 | selected blocking work is removed, reused, or moved without losing evidence |
| 2. Reduce scope | P2 | narrow changes use a smaller path and escalation cases still run broader validation |
| 3. Improve reuse | P3 | repeated necessary work is reused correctly in warm and invalidating scenarios |
| 4. Redesign gates | P4 | each test or gate has a distinct evidence role, trigger, owner, and budget |
| 5. Restore locality | P5 | a local change can build and validate locally across the new boundary |

Skip a stage only when evidence shows no applicable finding. Do not start a
large structural stage while unresolved higher-priority work remains unless the
structural change is a proven prerequisite.

## 9. Same-Tier Opportunity Ranking

Only compare opportunity value among findings in the same hard priority class.

```text
opportunity value increases with:
  critical-path time saved
  x frequency
  x affected population
  x diagnostic confidence
  x benefit durability

opportunity value decreases with:
  implementation and verification effort
  x correctness risk
  x maintenance burden
  x rollback difficulty
```

Use this comparison table:

```markdown
| Finding | Priority | Critical-Path Saving | Frequency | Population | Confidence | Durability | Effort | Correctness Risk | Maintenance | Rollback | Relative Rank |
|---|---|---:|---:|---|---|---|---|---|---|---|---:|
| DL-01 | P1 | ... | ... | ... | high | high | low | low | low | easy | 1 |
```

Do not invent precise numbers when evidence supports only qualitative ratings.
An enabling intervention may rank first when it safely unlocks several higher-
value P1 or P2 changes; record those dependencies.

## 10. Next Best Intervention

Every audit must select exactly one intervention to perform next.

```markdown
## Next Best Intervention

| Field | Decision |
|---|---|
| Finding | DL-... |
| Priority class | P0-P5 |
| Why first | ... |
| Expected critical-path benefit | per run and recurring estimate |
| Scope | files, jobs, tests, environments, or Agents |
| Effort | low / medium / high and rationale |
| Correctness risk | low / medium / high and failure mode |
| Evidence preserved or moved | ... |
| Rollback | ... |
| Validation | before/after plus invalidation or escalation test |
| Follow-up gate | measured condition for retain / revise / rollback / next / stop |
```

The audit must also name the nearest deferred alternatives and explain why they
are not first.

If implementation choice is blocked by weak evidence, choose a bounded
measurement intervention:

- name the uncertain claim;
- run or inspect a specific scenario;
- define the expected observation;
- state which priority or intervention decision the result will resolve.

Do not use “collect more data” as an unbounded placeholder.

## 11. Governance Work-In-Progress Limit

Default limit outside a P0 incident:

```text
1 primary governance intervention
+
1 directly associated regression guardrail
```

| Work type | Default concurrent limit |
| --- | ---: |
| P0 containment and trust restoration | parallel only when failures are independent and ownership is explicit |
| P1 tactical removal | 1, or 2 only when attribution remains independent |
| P2 selection or scope change | 1 |
| P3 cache or incrementality change | 1 |
| P4 test or gate redesign | 1 |
| P5 structural locality change | 1 |
| Guardrail | follows the selected intervention; it is not a separate program |

Do not combine cache semantics, test selection, gate policy, and architecture in
one experiment unless each result and rollback path is independently observable.

## 12. Intervention Record

```markdown
| Change | Finding Addressed | Priority | Expected Benefit | Evidence Preserved / Moved | Correctness Risk | Rollback | Validation Plan | Follow-Up Gate |
|---|---|---|---|---|---|---|---|---|
| ... | DL-01 | P1 | reduce PR critical path by ... | ... | ... | ... | ... | ... |
```

For selection or cache changes, include a deliberate invalidation or escalation
test. For gate changes, prove where the removed or deferred evidence is
recovered.

## 13. Verification Matrix

```markdown
| Scenario | Before | After | Change | Required Evidence | Result | Notes |
|---|---:|---:|---:|---|---|---|
| leaf change, warm | ... | ... | ... | unit + type + affected build | pass | ... |
| shared API change | ... | ... | ... | broader contract + integration | pass | escalation verified |
| cache-invalidating toolchain change | ... | ... | ... | cold rebuild | pass | stale result not reused |
```

Do not claim improvement when:

- only total compute decreased but the blocking path did not;
- the before run was cold and the after run was warm without disclosure;
- skipped tests or gates removed necessary evidence;
- cache correctness was not tested;
- the failure path became harder to reproduce or diagnose;
- several simultaneous changes make the benefit impossible to attribute.

## 14. Stop Conditions

End or pause the current governance cycle when:

- the target Time to Trusted Feedback is inside the agreed budget;
- remaining findings do not materially block the target decision;
- expected benefit is below implementation, verification, or maintenance cost;
- remaining findings are low-frequency and affect few developers or Agents;
- the next change is high-risk and structural but lacks a justified engineering
  or business case;
- timing variance is comparable to or larger than the expected saving;
- an external dependency now dominates and cannot reasonably be controlled by
  the project;
- the Next Best Intervention failed its safety or benefit gate and requires a
  new diagnosis.

Record one of these decisions after verification:

```text
retain and guard
revise and remeasure
rollback and rediagnose
select the next intervention
stop: budget met
stop: marginal value too low
blocked: external or unresolved dependency
```

## 15. Audit Report Template

```markdown
# Development Feedback Loop Audit

## Scope And Evidence Quality
- Decision boundaries:
- Repository / commit:
- Environments:
- Runtime evidence available:
- Limitations:

## Baseline And Critical Path
| Boundary | Baseline | Blocking path | Main wait |
|---|---:|---|---|

## Executive Findings
1. [P0-P5] ...
2. [P0-P5] ...

## Findings
| ID | Priority | Domain | Root Cause | Evidence | Critical-Path Impact |
|---|---|---|---|---|---|

## Governance Stage
- Current stage:
- Higher-priority unresolved work:
- Stage exit evidence:

## Same-Tier Ranking
| Rank | Finding | Priority | Expected Benefit | Confidence | Effort | Risk | Why this rank |
|---:|---|---|---|---|---|---|---|

## Next Best Intervention
| Field | Decision |
|---|---|
| Finding | ... |
| Priority class | ... |
| Why first | ... |
| Expected critical-path benefit | ... |
| Scope | ... |
| Effort | ... |
| Correctness risk | ... |
| Evidence preserved or moved | ... |
| Rollback | ... |
| Validation | ... |
| Follow-up gate | ... |

## Deferred Findings
| Finding | Why not first | Reconsider when |
|---|---|---|

## Implemented Change
- ...

## Verification
| Scenario | Before | After | Evidence Result |
|---|---:|---:|---|

## Guardrail
- ...

## Cycle Decision
- retain / revise / rollback / next / stop / blocked:
- stop condition or next trigger:

## Residual Risks And Open Questions
- ...
```
