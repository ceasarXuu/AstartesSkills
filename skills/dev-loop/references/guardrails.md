# Dev Loop Guardrails

Use this reference when `dev-loop` is applied during normal feature work,
refactoring, test development, build-system changes, CI changes, or coding-Agent
execution.

The guardrails should prevent feedback-loop regression without turning every
change into a process-heavy audit.

## 1. Change Classification

Classify the change before choosing validation.

| Class | Typical examples | Default validation posture |
| --- | --- | --- |
| Local leaf change | isolated implementation or UI behavior with narrow dependencies | targeted build, unit/component tests, local static checks |
| Shared-module change | common library, utility, shared configuration, SDK wrapper | affected dependents plus contract or integration evidence |
| Interface or data change | API, schema, serialization, migration, generated clients | compatibility, migration, contract, integration, rollback evidence |
| Toolchain change | lockfile, compiler, runtime, build scripts, test selection, cache keys | cold and warm validation, cache invalidation, broader repository checks |
| Security or concurrency change | auth, permissions, secrets, race conditions, ordering | broader negative, integration, and failure-path validation |
| Release-path change | packaging, deployment, signing, platform matrix | release gate, artifact, rollback, and environment-specific evidence |

Patch size is not a classification criterion by itself.

## 2. Minimum Sufficient Validation

Before coding, state:

```markdown
- Changed surfaces:
- Direct dependents:
- Main failure modes:
- Minimum sufficient evidence:
- Escalation triggers:
- Reusable prior evidence:
```

Start with the narrowest sufficient evidence and escalate deliberately. Do not
run the full repository merely because the affected scope is unknown; first try
to determine why the scope is unknown.

## 3. Build Guardrails

- Task inputs must reflect real dependencies, not entire repository roots by
  default.
- Task outputs should be declared and reusable where the build system supports
  it.
- Keep generation, compilation, packaging, signing, and release steps separate
  unless a real dependency requires fusion.
- Avoid global shared modules that become dependencies of unrelated packages.
- Preserve build daemons and incremental state unless correctness evidence
  requires a reset.
- Do not add unconditional clean steps to ordinary developer or PR workflows.
- Changes to build selection or incremental behavior require both a positive
  affected case and a negative unaffected case.
- Toolchain or lockfile changes require a cold-path validation because warm
  state may conceal missing inputs.

### Build review questions

1. Does this change widen the build graph?
2. Which new dependency edge causes that widening?
3. Can the affected target be built independently?
4. Does the task remain deterministic?
5. Can previous outputs still be reused safely?
6. What invalidates the result?

## 4. Test Guardrails

Every test must have an evidence role and a trigger policy.

| Layer | Primary role | Typical trigger |
| --- | --- | --- |
| Unit | local logic and edge cases | affected source or package |
| Component / module | behavior across local collaborators | affected module or contract |
| Contract | provider-consumer compatibility | interface or schema change |
| Integration | real subsystem interaction | subsystem or dependency-boundary change |
| End-to-end | critical user or business journey | risk-based PR, release, scheduled regression |
| Platform / environment | supported runtime or device behavior | platform-sensitive or release changes |

Guardrails:

- Do not add a higher-layer test when a lower layer can provide the same
  confidence more cheaply.
- Do not duplicate identical assertions across layers without a distinct
  failure mode.
- Make setup reusable and tests isolated enough to parallelize where practical.
- Avoid shared mutable global state that forces serialization.
- A slow test must have an owner, evidence role, and trigger policy.
- Flaky retry is not a permanent repair. Track expected retry cost and fix or
  isolate the root cause.
- Test selection must have a safe escalation path when dependency impact is
  uncertain.
- Changes to selection logic require tests proving that affected tests run and
  unaffected tests can be skipped.

## 5. CI And Gate Guardrails

Use gate layers rather than one undifferentiated pipeline.

```text
instant local checks
  -> pre-commit / pre-push checks
  -> ordinary PR required gates
  -> risk-triggered extended gates
  -> release gates
  -> asynchronous or scheduled full validation
```

A new required gate must document:

```markdown
- Failure prevented:
- Distinct evidence produced:
- Why pre-merge blocking is necessary:
- Trigger scope:
- Expected p50 / p95 duration:
- Owner:
- Failure escalation path:
- Conditions for removal or redesign:
```

Additional rules:

- Independent checks should run in parallel when setup duplication does not
  outweigh the benefit.
- Do not create many jobs if each job repeats checkout, dependency restore,
  service startup, or artifact generation.
- Reuse artifacts between jobs instead of recomputing them.
- Cancel superseded runs when safe.
- Keep long release, platform, compliance, or broad regression work off the
  ordinary PR critical path unless the change risk requires it.
- Required checks must remain actionable. A gate that often fails for unrelated
  reasons is itself a feedback-loop defect.

## 6. Cache Guardrails

For every material cache, define:

```markdown
- Cached output:
- Producer command and version:
- Required key inputs:
- Scope of reuse:
- Explicit invalidators:
- Fallback on miss:
- Poisoning or stale-result detection:
- Typical compute saved:
- Lookup / transfer cost:
```

Rules:

- Include toolchain, lockfile, relevant configuration, platform, and true source
  inputs as required by the output.
- Exclude timestamps, random identifiers, machine-specific absolute paths, and
  unrelated files unless they truly affect the output.
- Do not maximize hit rate by weakening invalidation.
- Do not retain a cache whose transfer cost regularly exceeds recomputation.
- Validate at least one hit, miss, and intentional invalidation path after
  changing cache logic.
- Keep cache restoration observable enough to distinguish a real hit from a
  fallback rebuild.

## 7. Environment Guardrails

- New worktrees should reuse safe package-manager and compiler caches where
  supported.
- Do not reinstall identical dependencies in every CI job.
- Place low-frequency dependency or toolchain layers before high-frequency
  source layers in container builds.
- Reuse service, database, browser, emulator, and simulator setup when isolation
  and correctness permit.
- Do not destroy the development environment after every command or Agent turn.
- If hermetic isolation requires cold setup, measure and budget it rather than
  pretending it is free.
- A destructive reset must record the suspected stale state and why narrower
  invalidation was insufficient.

## 8. Architecture Guardrails

Challenge a design when it makes local change impossible to validate locally.

Warning signs:

- a new dependency on a giant shared package;
- a module can only be tested by starting the full system;
- interfaces cannot be validated through contracts;
- code generation runs for unrelated modules;
- global initialization is required for simple tests;
- a local change invalidates all packages because boundaries are not declared;
- one shared configuration file becomes an input to every task.

Do not force architecture changes solely for theoretical purity. Require a
measurable or recurring feedback cost before recommending structural work.

## 9. Coding-Agent Guardrails

Coding Agents must manage their own execution feedback loop.

### Command evidence ledger

Track material commands conceptually or explicitly:

```markdown
| Command / Job | Inputs / Commit | Environment | Result | Evidence Produced | Reusable Until |
|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | source/config/toolchain change |
```

Rules:

- Do not rerun an expensive command when its inputs and environment are
  unchanged and its evidence is still valid.
- Subagents should reuse available build and test evidence rather than each
  starting a full validation path.
- Run narrow validation while implementation is changing rapidly; run broader
  validation when the code stabilizes or risk requires it.
- Diagnose stale-state evidence before clearing all caches or deleting the
  environment.
- Do not create a new worktree or container when the current isolated context is
  sufficient.
- When a full run is required, state what changed since the previous run and
  what new evidence the run will provide.

## 10. Feedback Budgets

Budgets must be based on project baselines and decision needs. Do not impose one
universal number on every repository.

Suggested budget categories:

| Budget | Meaning |
| --- | --- |
| Instant feedback | formatting, syntax, or local static result expected during editing |
| Focused feedback | affected build and tests for an ordinary local change |
| PR critical path | required merge confidence for an ordinary PR |
| High-risk path | extended evidence for shared, data, security, toolchain, or release changes |
| Cold environment | clean checkout or new Agent worktree to useful state |
| Scheduled full path | comprehensive regression not required for every ordinary change |

When a change exceeds a budget:

1. identify the added step;
2. state the evidence it provides;
3. determine whether the increase is necessary;
4. offset, redesign, or explicitly accept the regression;
5. assign ownership and a follow-up trigger.

## 11. Review Checklist By Change Type

### Adding a test

- [ ] Evidence role and layer are explicit.
- [ ] Trigger scope is defined.
- [ ] It does not duplicate cheaper evidence without reason.
- [ ] Setup is reusable and isolation is adequate.
- [ ] Parallelism and failure locality are acceptable.
- [ ] Expected latency impact is within budget.

### Changing CI

- [ ] Critical-path effect is known.
- [ ] Required versus asynchronous placement is justified.
- [ ] Setup and artifacts are not duplicated unnecessarily.
- [ ] Conditions and path filters have a safe fallback.
- [ ] Failure output is actionable.
- [ ] Superseded work is cancelled where safe.

### Changing cache logic

- [ ] All true inputs are included.
- [ ] Unrelated volatile inputs are excluded.
- [ ] Hit, miss, and invalidation paths are verified.
- [ ] Stale or poisoned results cannot silently pass.
- [ ] Net saved time is positive.

### Changing build or dependency boundaries

- [ ] Affected graph expansion is understood.
- [ ] Local targets remain independently buildable where expected.
- [ ] Incremental and cold paths are verified.
- [ ] Generated code and packaging do not become universal prerequisites.
- [ ] New shared dependencies are justified.

### Finishing ordinary implementation work

- [ ] Narrow validation ran first.
- [ ] Escalation matched risk.
- [ ] Existing valid evidence was reused.
- [ ] No unjustified clean build or full test was performed.
- [ ] No new gate, cache, setup, or global dependency silently regressed the loop.
- [ ] Final evidence is recorded clearly.

## 12. Guard Mode Output Template

```markdown
## Dev Loop Guard Result

### Change Classification
- Risk class:
- Affected surfaces:
- Escalation signals:

### Validation Strategy
- Minimum sufficient validation:
- Reused evidence:
- Broader validation performed and why:

### Feedback-Loop Impact
- Build graph:
- Test scope:
- CI critical path:
- Cache / incremental state:
- Environment startup:
- Agent execution:

### Findings
- No material regression found.

or

| Finding | Evidence | Impact | Required correction |
|---|---|---|---|
| ... | ... | ... | ... |

### Final Evidence
- Commands / checks:
- Results:
- Residual risk:
```
