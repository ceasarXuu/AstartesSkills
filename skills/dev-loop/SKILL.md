---
name: dev-loop
description: Use when the user wants to audit, diagnose, optimize, or protect a software project's development feedback loop, including slow local builds, slow tests, oversized validation scope, small changes triggering full test suites, inefficient CI gates, poor cache reuse, repeated dependency installation, frequent cold builds, duplicated Agent work, or daily engineering constraints that prevent feedback latency from degrading over time.
---

# Dev Loop

## Purpose

Use this skill to audit, optimize, and protect the feedback loop between a code
change and the point where a developer or coding Agent has enough trustworthy
evidence to continue safely.

The primary objective is not raw command speed. It is **Time to Trusted
Feedback**:

```text
code change
  -> choose the necessary evidence
  -> build / check / test / package
  -> receive trustworthy, actionable feedback
  -> continue, revise, or escalate validation
```

A valid optimization must reduce delay without silently weakening necessary
correctness, compatibility, security, release, or operational evidence.

## Use This Skill When

- A project feels slow to develop even when production runtime performance is
  acceptable.
- Small changes trigger full builds, full test suites, platform matrices, or
  expensive end-to-end environments.
- Local development, CI, or coding Agents repeatedly reinstall dependencies,
  recreate environments, clear caches, or perform cold builds.
- Build, test, lint, type-check, packaging, or CI gates are poorly layered or
  unnecessarily serialized.
- Cache hit rate is low, cache invalidation is unsafe, or cache transfer costs
  exceed the work avoided.
- A monorepo or modular repository cannot select affected packages, tests, or
  build targets accurately.
- The user wants an audit of the current development feedback loop.
- The user wants ongoing engineering constraints that keep the feedback loop
  healthy during feature work, refactors, test additions, build-system changes,
  or CI changes.
- A coding Agent is duplicating builds, tests, environment setup, or worktree
  initialization across attempts or subagents.

Do not use this skill as the primary workflow for production API latency,
database query tuning, frontend runtime rendering performance, memory leaks, or
algorithmic optimization unless those issues directly slow the development
feedback loop.

## Operating Modes

Choose one mode before acting.

### Audit / Recovery

Use when the current feedback loop is already slow, unstable, wasteful, or
poorly understood.

The goal is to:

1. establish a measurable baseline;
2. identify where time and evidence are misaligned;
3. locate the blocking critical path;
4. classify findings with the P0-P5 priority ladder;
5. select one Next Best Intervention;
6. implement the smallest reliable improvement;
7. verify both speed and evidence coverage;
8. install a proportional guardrail that prevents regression.

### Guard / Prevention

Use during ordinary project work when the user wants `dev-loop` constraints to
shape implementation decisions.

The goal is to prevent a new change from:

- expanding unrelated build or validation scope;
- adding an unjustified blocking gate;
- breaking incremental execution or cacheability;
- introducing repeated cold setup;
- duplicating evidence already provided elsewhere;
- forcing local changes to depend on global environments;
- causing coding Agents to rerun expensive work without new evidence.

Guard mode must remain proportional. Do not turn every small edit into a full
feedback-loop audit.

## Core Model

Analyze four related graphs.

| Graph | Question |
| --- | --- |
| Change Graph | What modules, interfaces, data, packages, and environments can this change affect? |
| Evidence Graph | What evidence is sufficient to trust this change? |
| Execution Graph | What commands, jobs, setup steps, and gates actually run? |
| Critical Path | Which steps block the next useful engineering decision? |

The main diagnostic signal is mismatch between these graphs. Examples:

- a narrow Change Graph with a repository-wide Execution Graph;
- a small Evidence Graph hidden behind a long non-evidence setup path;
- duplicated tests that produce the same evidence at multiple layers;
- non-blocking release or compliance work placed on the PR critical path;
- a large Change Graph caused by unnecessary architectural coupling.

## Governance Priority Model

A large audit must not return an unranked backlog and call the work complete.
Use four decision layers in order:

```text
hard priority class
  -> governance stage
  -> same-tier opportunity value
  -> one measurable Next Best Intervention
```

### Hard Priority Ladder

Assign every material finding exactly one priority class before comparing
benefit or effort.

| Priority | Name | Meaning | Default action |
| --- | --- | --- | --- |
| P0 | Restore trust or availability | Results may be wrong, validation may silently miss risk, or the loop cannot complete reliably | Fix immediately before ordinary speed work |
| P1 | Remove blocking no-evidence work | Work blocks the next decision but produces no distinct engineering evidence | Remove, reuse, parallelize, or move it off the critical path first |
| P2 | Reduce validation amplification | Actual build or validation scope is materially larger than the minimum sufficient scope | Introduce safe affected-scope selection and explicit escalation |
| P3 | Improve reuse and incrementality | Necessary work is repeatedly recomputed because cache, artifact, daemon, or environment reuse is poor | Improve reuse only after confirming the work is necessary |
| P4 | Redesign test and gate architecture | Test layers, gate roles, ownership, or trigger policy are structurally duplicated or misplaced | Redesign with explicit evidence ownership and rollout controls |
| P5 | Restore architectural locality | Module, service, fixture, generation, or dependency structure makes local validation impossible | Use incremental structural change after tactical options are exhausted |

Examples of P0 include:

- cache reuse can return stale or incompatible outputs;
- affected-test selection can silently omit high-risk changes;
- required checks are so flaky that pass or fail results are not trustworthy;
- local and CI results are systematically inconsistent;
- incremental builds are unreliable, forcing repeated clean builds;
- the feedback path deadlocks, hangs, or cannot complete;
- failures cannot be reproduced well enough to restore confidence.

Priority rules:

1. P0 outranks every speed opportunity, even when its direct time cost is small.
2. A high-value P3 or P4 item cannot outrank an unresolved P0.
3. When benefits are comparable, P1 outranks P2, P2 outranks P3, and so on.
4. A lower-priority item may be selected first only when it is a documented
   prerequisite for the higher-priority fix or materially reduces the risk of
   that fix.
5. Record the reason whenever the selected intervention does not follow the
   normal ladder.

### Governance Sequence

Use this default stage order:

```text
stabilize trust and availability
  -> remove blocking waste
  -> reduce execution and validation scope
  -> improve reuse, incrementality, and parallelism
  -> redesign test and gate responsibilities
  -> restore architectural locality
  -> retain only the guardrails proven useful
```

A stage may be skipped when evidence shows that no relevant finding exists. Do
not begin with a build-system replacement, remote execution platform, or large
module split merely because those changes appear comprehensive.

### Same-Tier Opportunity Value

Use opportunity value only after hard priority classification.

```text
opportunity value increases with:
  critical-path time saved
  x frequency
  x affected developers, Agents, PRs, or platforms
  x diagnostic confidence
  x durability of the benefit

opportunity value decreases with:
  implementation and verification effort
  x correctness or cache-poisoning risk
  x maintenance burden
  x rollback difficulty
```

Use measured values when available. Otherwise use explicit qualitative ratings
such as high, medium, and low. Do not manufacture precise scores from weak data.

An enabling intervention may outrank a larger isolated saving when it safely
unlocks several P1 or P2 improvements. State the unlocked work and the evidence
for that dependency.

### Next Best Intervention

Every Audit / Recovery output must select exactly one **Next Best Intervention**.
Do not stop at a ranked list.

Use this contract:

| Field | Required content |
| --- | --- |
| Finding | The specific problem to address now |
| Priority class | P0-P5 |
| Why first | Why it outranks the other findings |
| Expected critical-path benefit | Per-run and recurring benefit when estimable |
| Scope | Files, jobs, tests, environments, or Agents affected |
| Effort | Low / medium / high with rationale |
| Correctness risk | Low / medium / high with failure mode |
| Evidence preserved or moved | What confidence remains and where deferred evidence runs |
| Rollback | How to disable or revert the intervention |
| Validation | Before/after and invalidation or escalation tests |
| Follow-up gate | What result determines the next intervention |

If evidence is too weak to choose an implementation change, the Next Best
Intervention must be a bounded measurement or experiment, not a generic request
to gather more data.

### Governance Work-In-Progress Limit

Except during a P0 incident, default to:

```text
one primary governance intervention
+
one directly associated regression guardrail
```

Do not simultaneously change cache semantics, test selection, CI gate policy,
and module architecture unless the changes are independently attributable and
independently reversible.

P0 work may be parallelized when separate failures require immediate
containment. Record ownership and avoid conflicting changes to the same evidence
path.

### Stop Conditions

Stop or pause the current governance cycle when one or more of these are true:

- the target Time to Trusted Feedback is inside the agreed project budget;
- remaining findings do not materially affect a blocking decision;
- the expected benefit is smaller than implementation, validation, or ongoing
  maintenance cost;
- remaining issues are rare and have low population impact;
- further progress requires a high-risk structural change without a justified
  business or engineering case;
- measurement variance is similar to or greater than the expected improvement;
- the dominant delay is an external dependency that this project cannot
  reasonably control;
- the selected intervention failed its benefit or safety gate and requires a
  new diagnosis.

Do not optimize every slow step. Optimize the work that repeatedly blocks an
important decision and whose benefit exceeds its governance cost.

## Non-Negotiable Principles

### 1. Optimize trusted feedback, not green status

Do not claim success merely because a pipeline became faster or a check was
removed. State what evidence was removed, retained, moved, or made conditional.

### 2. Small diffs are not automatically low risk

Risk depends on blast radius and semantics, not line count. Public interfaces,
shared utilities, schemas, migrations, authentication, concurrency, build
configuration, lockfiles, generated code, and toolchains may require broader
validation even when the patch is small.

### 3. Preserve incremental state by default

Do not default to:

```text
clean build
clear all caches
remove all dependencies
recreate every environment
run every test
```

Use destructive reset only when evidence indicates stale or corrupted state,
and record why narrower invalidation is insufficient.

### 4. Every blocking gate must justify its position

A blocking gate must answer:

1. What failure does it prevent?
2. Why must it complete before merge or the next action?
3. Why can it not be scoped to affected changes?
4. What distinct evidence does it add?
5. Does its latency fit the project's feedback budget?

### 5. Prefer less work before faster work

Use this optimization order:

```text
eliminate unnecessary work
  -> narrow execution scope
  -> reuse valid results
  -> parallelize independent work
  -> accelerate remaining work
  -> add compute capacity last
```

### 6. Cache correctness precedes cache hit rate

A cache is useful only if reuse is correct and the avoided computation is worth
more than lookup, transfer, storage, and invalidation costs.

### 7. Static inspection is not measured proof

When execution is available, measure representative runs. If execution is not
possible, label conclusions as a static audit and identify the commands or CI
runs needed to validate them.

## Audit / Recovery Workflow

Read `references/audit-playbook.md` for the detailed checklist and report
schema.

### Step 1: Define the decision boundary

Clarify the feedback loop being optimized:

- edit-to-local-feedback;
- commit-to-pre-push confidence;
- push-to-PR-gate completion;
- PR-to-merge readiness;
- clean checkout-to-working environment;
- Agent task start-to-trusted completion.

Do not combine every loop into one number when different users or decisions are
blocked by different paths.

### Step 2: Inventory the system

Inspect relevant evidence before recommending changes:

- repository and module structure;
- package-manager and lockfiles;
- build definitions and task graphs;
- test configuration and test layers;
- lint, formatting, static analysis, and type-check configuration;
- CI workflow files and required checks;
- cache keys, restore keys, artifact boundaries, and remote-cache settings;
- container, toolchain, simulator, database, and service setup;
- generated-code and asset pipelines;
- recent command timings, CI timelines, failure logs, retries, and flaky tests;
- coding-Agent command history, worktree behavior, and subagent duplication.

### Step 3: Establish a baseline

Measure the smallest representative set available. Prefer:

- narrow change, warm state;
- narrow change, cold state;
- broad or shared change, warm state;
- required PR critical path;
- full asynchronous or release validation.

Record environment, commit, command, cache state, duration, result, and whether
the run produced new evidence.

Do not compare a cold baseline with a warm optimized run without labeling the
difference.

### Step 4: Build the feedback map

For every material step, record:

| Step | Trigger | Inputs | Output / Evidence | Duration | Blocking? | Reusable? | Failure locality |
| --- | --- | --- | --- | ---: | --- | --- | --- |
| ... | ... | ... | ... | ... | yes / no | yes / partial / no | precise / broad / poor |

Identify:

- the actual blocking critical path;
- repeated setup or duplicated computation;
- work that produces no new engineering evidence;
- unnecessarily broad triggers;
- hidden serialization;
- invalid or low-value cache boundaries;
- architecture or dependency edges that force global validation.

### Step 5: Classify findings

Use these diagnostic domains:

1. **Build graph and dependency structure**
2. **Test layers and change-to-test mapping**
3. **Gate policy and critical-path placement**
4. **Cache, artifacts, and reproducibility**
5. **Environment startup and cold-state lifecycle**
6. **Architectural coupling and validation amplification**
7. **Coding-Agent execution strategy**

Separate tactical causes from structural causes.

- Tactical: duplicate installation, poor job ordering, missing artifact reuse,
  overly broad path filters, daemon shutdown, incorrect Docker layer order.
- Structural: giant shared modules, undeclared inputs, global test fixtures,
  non-isolated services, code generation bound to every compile, or module
  boundaries that cannot support local validation.

### Step 6: Prioritize and choose the intervention

1. Assign P0-P5 to every material finding.
2. Resolve P0 before ordinary speed work.
3. Place the remaining findings in the governance sequence.
4. Compare only same-tier findings using opportunity value.
5. Select exactly one Next Best Intervention.
6. Record why other high-ranked findings are not first.
7. Apply the governance WIP limit and define the follow-up gate.

Do not recommend a new build system, remote execution platform, or large module
split unless simpler interventions cannot address the measured bottleneck.

### Step 7: Implement the Next Best Intervention

Examples include:

- remove duplicate dependency installation;
- persist safe dependency, compiler, or task outputs;
- fix cache inputs and invalidation boundaries;
- select affected packages or tests from the dependency graph;
- split setup from execution and reuse the setup result;
- move non-blocking validation off the PR critical path;
- parallelize independent checks;
- separate code generation, compilation, packaging, and release tasks;
- make tests hermetic enough to parallelize;
- stop coding Agents from rebuilding identical states across subagents.

Prefer one measurable intervention at a time so benefit and failure attribution
remain clear.

### Step 8: Verify the result

A successful optimization must verify:

- representative warm and cold timings where relevant;
- critical-path improvement rather than only total compute reduction;
- unchanged or explicitly redesigned evidence coverage;
- cache correctness and reproducibility;
- failure localization and debuggability;
- behavior for high-risk changes that require validation escalation;
- rollback or disable path for new cache, selection, or gate logic.

If the optimized path skips work, deliberately test at least one case that must
invalidate the cache or escalate validation.

Use the follow-up gate to decide whether to:

- retain and guard the change;
- revise or roll back the change;
- select the next intervention;
- stop the governance cycle.

### Step 9: Install one proportional guardrail

Convert the successful optimization into a durable project constraint, such as:

- latency budget;
- changed-scope or affected-test policy;
- cache-key contract;
- required-gate ownership;
- slow-test ownership;
- warm/cold benchmark;
- CI critical-path monitoring;
- Agent command-reuse rule;
- periodic full-validation schedule where needed.

Do not create a separate large governance program when a narrow regression check
or ownership rule is sufficient.

## Guard / Prevention Workflow

Read `references/guardrails.md` when applying this skill during ordinary
implementation work.

### Before implementation

1. Classify the change by blast radius and risk.
2. Identify the minimum sufficient validation set.
3. Identify conditions that require broader validation.
4. Preserve existing incremental state and reusable outputs.
5. Note whether the change touches build, test, CI, cache, environment, shared
   architecture, or Agent orchestration.

### During implementation

Continuously challenge changes that:

- widen task inputs without a dependency reason;
- introduce a global dependency from a local module;
- add a test with a global environment when a lower layer is sufficient;
- add a blocking check without unique pre-merge evidence;
- make a previously deterministic task depend on time, random state, absolute
  paths, network state, or mutable external inputs;
- force clean builds or dependency reinstallations;
- duplicate setup across CI jobs or subagents;
- serialize independent work;
- hide test or cache selection behind heuristics with no safe fallback.

When multiple regressions are found, fix any P0 introduced by the current change
first. Otherwise block only the highest-priority regression needed to keep the
current change from degrading the loop; record lower-priority legacy debt rather
than expanding the task without limit.

### After implementation

1. Run the narrowest sufficient validation first.
2. Escalate according to risk and touched surfaces.
3. Reuse valid prior results instead of rerunning unchanged work.
4. Confirm no feedback budget or critical-path regression was introduced.
5. Record any new gate, cache, test layer, setup dependency, or global coupling.
6. Run full validation when the change itself modifies selection, caching,
   build graphs, test infrastructure, or gate policy.

## Validation Escalation Signals

Broaden validation when a change affects one or more of these surfaces:

- public API or protocol compatibility;
- shared libraries with high dependency centrality;
- schemas, migrations, serialization, or generated clients;
- authentication, authorization, security boundaries, or secrets;
- concurrency, ordering, timing, or distributed coordination;
- build scripts, lockfiles, compilers, SDKs, runtimes, or dependency resolution;
- test selection, cache invalidation, CI conditions, or release packaging;
- platform-specific behavior or supported environment matrices;
- recovery, rollback, persistence, or irreversible workflows.

The response must state why escalation is needed and which additional evidence
it provides.

## Metrics

Use metrics only when they support a decision. Prefer project baselines over
universal thresholds.

| Metric | Definition |
| --- | --- |
| Time to Trusted Feedback | Time from a completed change to enough evidence for the next safe decision |
| Blocking Critical Path | Longest dependency path that blocks that decision |
| Validation Amplification | Actual validation cost divided by estimated minimum sufficient validation cost |
| Cold / Warm Ratio | Cold feedback duration divided by warm feedback duration |
| No-Evidence Wait Share | Blocking time spent on work that adds no new validation evidence |
| Cache Value | Avoided computation time minus lookup, transfer, storage, and invalidation cost |
| Retry-Adjusted Feedback Cost | Initial duration plus expected retry and failure-localization cost |
| Governance Payback | Recurring critical-path benefit divided by implementation and maintenance cost |

Do not optimize cache hit rate, job count, or total CPU minutes in isolation.

## Output Requirements

### Audit output

Lead with findings, ordered by the P0-P5 ladder and then opportunity value.
Include:

1. audit scope and evidence quality;
2. baseline and critical path;
3. findings with priority class, root cause, and supporting evidence;
4. governance stage and same-tier ranking;
5. exactly one Next Best Intervention;
6. expected benefit, risk, rollback, and validation for that intervention;
7. deferred findings and why they are not first;
8. implemented changes when requested;
9. before-and-after validation;
10. follow-up gate, stop decision, residual risks, and recommended guardrail.

Distinguish measured facts, repository-derived facts, hypotheses, and estimates.
Do not return only a problem inventory or an unranked recommendation list.

### Guard output

Keep the response proportional. Include:

- selected validation scope;
- feedback-loop risks introduced by the change;
- highest-priority regression addressed or prevented;
- constraints applied during implementation;
- escalation decisions;
- any budget, cache, gate, or architecture regression found;
- deferred legacy debt that was intentionally kept out of scope;
- final validation evidence.

Do not generate a long governance report for a routine change unless a material
risk or regression is found.

## Anti-Patterns

Reject or challenge these patterns unless evidence justifies them:

- returning a long unranked backlog without choosing what to do first;
- using a single score that allows a P3 optimization to outrank a P0 trust issue;
- launching cache, gate, test-selection, and architecture changes together;
- continuing governance after the feedback budget is met and marginal value is
  lower than governance cost;
- "Run everything because it is safer.";
- "Clear all caches and reinstall dependencies first.";
- "The patch is small, so it is low risk.";
- "The cache hit rate increased, so the optimization worked.";
- "Move every slow test to nightly.";
- "Allow the slow or flaky gate to fail without fixing its evidence role.";
- "Buy larger runners before removing unnecessary work.";
- "Split every CI step into a separate job" when setup duplication dominates;
- "Put every check on the PR path" because ownership and trigger policy are
  undefined;
- "Replace the build system" before proving the current system is the root
  cause;
- coding Agents repeatedly running identical commands without new inputs.

## Completion Checklist

Before claiming the task complete, verify:

- [ ] The optimized decision boundary is explicit.
- [ ] The critical path is identified or the lack of runtime evidence is stated.
- [ ] Findings distinguish tactical waste from structural coupling.
- [ ] Every material finding has a P0-P5 priority class.
- [ ] P0 trust or availability issues are resolved or explicitly blocking.
- [ ] Same-tier ranking uses evidence rather than invented precision.
- [ ] Exactly one Next Best Intervention is selected.
- [ ] The reason it outranks other findings is explicit.
- [ ] Governance WIP is limited unless a P0 incident justifies parallel work.
- [ ] A follow-up gate and stop condition are defined.
- [ ] Validation scope is based on risk and dependency impact, not patch size.
- [ ] Incremental state is preserved unless invalidation is justified.
- [ ] Cache changes include correctness and invalidation evidence.
- [ ] Blocking gates provide distinct necessary evidence.
- [ ] Speed improvements do not silently remove required evidence.
- [ ] Warm and cold conditions are not compared dishonestly.
- [ ] Agent and subagent duplication is considered when relevant.
- [ ] Results are measured where execution is available.
- [ ] A successful intervention has one proportional guardrail.

## References

- `references/audit-playbook.md`: detailed audit evidence checklist, P0-P5
  priority ladder, governance sequencing, Next Best Intervention contract,
  prioritization model, WIP limits, stop conditions, and report template.
- `references/guardrails.md`: daily engineering constraints for builds, tests,
  CI, caches, environments, architecture, and coding Agents.
