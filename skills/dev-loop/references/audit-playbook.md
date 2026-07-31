# Dev Loop Audit Playbook

Use this reference for a repository-wide audit or a targeted investigation of a
slow local, CI, test, build, environment, or coding-Agent feedback path.

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
| ID | Domain | Symptom | Root Cause | Evidence | Critical-Path Cost | Frequency | Confidence | Risk | Recommended Intervention |
|---|---|---|---|---|---:|---:|---|---|---|
| DL-01 | CI gates | ... | ... | file, log, run, measurement | ... | ... | high / medium / low | ... | ... |
```

Do not state a root cause when only a correlation is known. Mark it as a
hypothesis and state the experiment needed to confirm it.

## 7. Prioritization

Use the following reasoning rather than a rigid score:

```text
priority increases with:
  critical-path time saved
  x frequency
  x diagnostic confidence
  x safety of the change

priority decreases with:
  implementation effort
  x correctness risk
  x maintenance burden
  x rollback difficulty
```

Prioritize in this order when benefits are comparable:

1. remove no-evidence waiting and duplicated work;
2. narrow affected scope;
3. reuse valid environment and task results;
4. parallelize independent work;
5. optimize slow remaining tasks;
6. restructure architecture when tactical fixes cannot create locality;
7. add compute capacity only after unnecessary work is controlled.

## 8. Intervention Record

```markdown
| Change | Finding Addressed | Expected Benefit | Evidence Preserved / Moved | Correctness Risk | Rollback | Validation Plan |
|---|---|---|---|---|---|---|
| ... | DL-01 | reduce PR critical path by ... | ... | ... | ... | ... |
```

For selection or cache changes, include a deliberate invalidation or escalation
test. For gate changes, prove where the removed or deferred evidence is
recovered.

## 9. Verification Matrix

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
- the failure path became harder to reproduce or diagnose.

## 10. Audit Report Template

```markdown
# Development Feedback Loop Audit

## Scope And Evidence Quality
- Decision boundaries:
- Repository / commit:
- Environments:
- Runtime evidence available:
- Limitations:

## Executive Findings
1. ...
2. ...

## Baseline And Critical Path
| Boundary | Baseline | Blocking path | Main wait |
|---|---:|---|---|

## Findings
| ID | Severity | Root Cause | Evidence | Impact |
|---|---|---|---|---|

## Recommended Interventions
| Priority | Intervention | Expected Benefit | Risk | Effort | Rollback |
|---|---|---|---|---|---|

## Implemented Changes
- ...

## Verification
| Scenario | Before | After | Evidence Result |
|---|---:|---:|---|

## Guardrails And Budgets
- ...

## Residual Risks And Open Questions
- ...
```
