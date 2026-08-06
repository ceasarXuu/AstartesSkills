---
name: se-good-plan
description: Use when the user asks for a software engineering plan, implementation plan, refactor plan, migration plan, rollout plan, bug-fix plan, performance optimization plan, security change plan, DevOps / CI/CD plan, technical execution plan, or review of an existing engineering plan. Produces concise, executable, evidence-updated plans with a user-confirmed product decision baseline and two required repository artifacts.
---

# SE Good Plan

## Purpose

Write or review engineering plans that are directly executable, proportionate to
the problem, constrained by user-confirmed product decisions, and updated by real
evidence rather than followed mechanically.

A formal repository plan maintains two independent topic artifacts:

```text
docs/releases/<confirmed-version>/<topic-slug>/
├── decisions.md
└── plan.md
```

`decisions.md` is the product decision baseline. `plan.md` is the main document
containing engineering design, work units, conditional validation, phases, and
execution-time plan updates. Other research or review artifacts are created only
when needed.

## Use This Skill When

- The user asks for an implementation, refactor, migration, rollout, bug-fix,
  performance, security, DevOps, CI/CD, release, or other engineering plan.
- The user asks to split work into executable units or phases.
- The user asks to make a plan concrete, concise, reviewable, or ready to execute.
- The user asks whether a plan is vague, oversized, over-engineered,
  insufficiently validated, stale, or drifting from confirmed product logic.

Do not use this skill for pure product clarification unless requirements must be
converted into engineering execution. Do not over-plan tiny, low-risk edits.

## Core Rules

### 1. Maintain Two Required Topic Artifacts

For a formal repository plan, create or reuse:

```text
docs/releases/<confirmed-version>/<topic-slug>/decisions.md
docs/releases/<confirmed-version>/<topic-slug>/plan.md
```

Resolve `<confirmed-version>` from the user, repository release documentation, or
an explicit project decision. Do not invent a version. If several versions remain
plausible, block artifact creation until the target version is resolved.

Use a stable lowercase topic slug. Update the same two files over the topic
lifecycle; do not create parallel `plan-v2.md`, `final-plan.md`, or copied
decision baselines.

The files are independent and cross-linked:

- `decisions.md` links `./plan.md`.
- `plan.md` links `./decisions.md` and lists the applicable active decision IDs.
- `plan.md` contains both `## Design` and `## Work Units`.
- Do not merge the full product decision baseline into `plan.md`.

### 2. Use A Product Decision Baseline

`decisions.md` records only important product-logic decisions that were confirmed
by the user and must constrain planning and execution over time.

Use a compact shape:

```markdown
# Product Decision Baseline

- Release Version:
- Topic:
- Plan: ./plan.md
- Status: Active

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | ... | ... | ... | ... | ... | user-confirmed: ... | active |
```

Decision statuses are `proposed`, `active`, or `superseded`.

- Only user-confirmed decisions may be `active`.
- Agent inference remains `proposed` and cannot constrain implementation as if
  confirmed.
- Record product behavior, scope boundaries, priority rules, and invariants whose
  silent change would alter user intent.
- Do not record ordinary implementation details, coding rules, every risk, or
  speculative future requirements.
- Each active decision must state what to do, what not to do, why it matters, and
  how a violation would be detected.

Read the baseline before authoring or revising `plan.md`, before starting a
material phase, and during phase reconciliation.

Verified engineering evidence may invalidate the technical plan, but it cannot
silently rewrite user intent. When evidence conflicts with an active decision:

1. pause affected downstream work;
2. identify the conflict and affected decision IDs;
3. propose a decision change with benefits, side effects, and plan impact;
4. obtain user confirmation;
5. preserve the old row as `superseded` and add or activate the replacement;
6. revise `plan.md`.

### 3. Plans Must Be Executable

Every work unit states:

- **Change location:** file, module, service, configuration, schema, API, job,
  pipeline stage, command, or deployment surface.
- **Target object:** function, class, table, field, endpoint, handler, worker,
  workflow, rule, or other named object.
- **Concrete action:** one explicit add/change/remove/replace/move/split/route/
  migrate/wire/validate/rename operation.
- **Resulting behavior:** the immediate technical behavior or invariant.
- **Benefit:** wider project value.
- **Side Effects:** expected complexity, affected surface, and continuing cost.
- **Verification:** exact evidence proving the action worked.

“Add an abstraction”, “refactor the module”, “optimize caching”, “improve error
handling”, or “complete integration” are not executable by themselves. Unknown
locations or objects become a bounded Discovery unit.

### 4. Use The Smallest Closed-Loop Engineering Unit

Each unit has one primary objective, change axis, action, benefit, and bounded
side-effect profile. It must be independently inspectable, auditable, verifiable,
and reversible, disableable, or safely stoppable.

Split independent API, data, implementation, cache, client, deployment,
observability, security, and cleanup work. A phase may sequence units but cannot
hide their individual actions, evidence, states, or safe-stop boundaries.

### 5. Prefer Minimum Necessary Construction

Use this order:

```text
delete or simplify existing logic
  -> change an existing path
  -> reuse an existing mechanism
  -> add narrow local logic
  -> add a new abstraction
  -> add a new dependency or stateful infrastructure
```

New interfaces, factories, providers, registries, configuration switches,
states, runtime branches, caches, queues, jobs, dependencies, schemas, or
frameworks require a current confirmed need or risk. Possible future use is not
enough. Temporary construction needs retirement criteria and cleanup.

### 6. Make Benefit And Side Effects Explicit

`Resulting Behavior` explains what changes technically. `Benefit` explains why
it matters to users, delivery, reliability, maintenance, cost, support, risk, or
operations. Generic claims or copies of Resulting Behavior are invalid.

A Side Effect is an expected consequence even when implementation works. A Risk
is uncertain; Rollback is recovery. Every Side Effects field covers:

- **Complexity:** code/files/concepts/abstractions/states/branches/dependencies/
  configuration/schema/runtime paths/temporary logic added or removed.
- **Reach / cost:** affected modules/callers/data/tests/builds/CI/deployment/
  resources/security/operations/support/ownership/cognitive load/cleanup.

`None`, `minimal impact`, `low risk`, or `N/A` are invalid.

### 7. Use Minimum Sufficient Pre-Investment Validation

Before expensive, broad, irreversible, or dependency-sensitive implementation,
identify any critical assumption whose failure would invalidate substantial later
work. Validate only enough to decide whether the direction merits formal
investment.

Use the cheapest credible evidence ladder:

```text
existing evidence / static inspection
  -> read-only observation
  -> isolated request or script
  -> sandbox or disposable spike
  -> formal implementation only when the uncertainty cannot be isolated
```

Validation states the assumption, unlocked decision, evidence level,
enough-evidence threshold, intentionally unproven scope, bounded budget, allowed
artifacts, forbidden production changes, stop condition, and cleanup/promotion.

Validation is not shadow implementation. Mock, Sandbox, and Prototype evidence
cannot be reported as production integration. If credible validation approaches
formal implementation scope, reclassify it as an implementation unit.

### 8. Evidence Supersedes The Plan

The technical plan is a hypothesis based on earlier information. Verified current
code, tests, logs, data, dependency behavior, and runtime observations outrank
plan assumptions and preplanned order.

After every material phase in Execution Tracking, reconcile new evidence,
affected assumptions and conclusions, Benefit, Side Effects, cost, risk,
dependencies, priority, and downstream units. Do not automatically continue
because the phase completed. Preserve old conclusions and mark them `current`,
`qualified`, `superseded`, `invalidated`, or `needs-revalidation`.

Evidence supersedes stale technical planning, but active product decisions remain
authoritative until the user confirms a change.

### 9. Keep State Models Separate

- Plan Authoring: `planned`, `blocked-on-discovery`, `deferred`.
- Pre-investment validation: `planned`, `direction-supported`,
  `direction-rejected`, `inconclusive`, `budget-exhausted`.
- Execution Tracking: `not-started`, `in-progress`, `verified`, `blocked`,
  `failed`, `rolled-back`.
- Plan validity: `valid`, `valid-with-qualifications`, `needs-revision`,
  `invalidated`.
- Product decisions: `proposed`, `active`, `superseded`.
- Discovery/design artifacts: `planned`, `drafted`, `reviewed`, `verified`.
- Code implementation: `planned`, `implemented`, `integrated`,
  `runtime-verified`.

Do not mix these models.

### 10. Prefer Concise Structure

Use the smallest document shape preserving engineering clarity. The two topic
artifacts are mandatory for formal repository plans; additional artifacts are
not. Add validation or reconciliation sections only when their trigger exists.
Do not duplicate decisions, risks, tests, logs, benefits, side effects, or
evidence merely to fill a template.

### 11. Preserve Engineering Safety

- Separate facts, assumptions, constraints, risks, and open questions.
- Do not invent architecture, scale, schedules, staffing, deadlines, or releases.
- Production work includes release, rollback/fallback, observability, and
  post-release validation.
- Data changes include idempotency, retry/resume, validation, and compensation.
- Security changes include permissions, sensitive-data handling, abuse cases,
  audit logging, and review.
- Runtime-changing work exposes success, failure, and failure reasons.

## Generation Workflow

### 1. Resolve The Topic Directory And Baseline

Inspect `docs/releases/` and resolve the confirmed release version and topic slug.
Create or reuse:

```text
docs/releases/<confirmed-version>/<topic-slug>/decisions.md
docs/releases/<confirmed-version>/<topic-slug>/plan.md
```

Extract only user-confirmed product decisions into `decisions.md`. Mark uncertain
interpretations `proposed`. Link both files and identify applicable active IDs in
`plan.md`.

### 2. Classify Scope, Risk, And Material Uncertainty

| Depth | Use when | Typical shape |
|---|---|---|
| Lightweight | narrow, low-risk, easy rollback | 1-3 units |
| Standard | several moving parts or controlled production risk | useful phases with small units |
| Full | data, security, compatibility, cross-system, hard rollback | Standard plus relevant safety material |

Mark `Material Uncertainty: yes` only when a critical unknown could invalidate
substantial later investment.

### 3. Write The Design In `plan.md`

State current and expected behavior, gap, affected surfaces, goals, non-goals,
assumptions, open questions, applicable decision IDs, and the least-construction
technical design. Explain control flow, data flow, compatibility, migration, or
structural changes only to the level needed to support the work units.

### 4. Add A Bounded Validation Gate When Needed

```markdown
| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
```

### 5. Build Work Units In `plan.md`

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
```

### 6. Group Into Phases Only When Useful

```markdown
### Phase N: <Outcome>

- Entry condition:
- Applicable decisions:
- Work units:
- Phase-local evidence:
- Cross-unit side effects:
- Next-phase condition:
```

### 7. Reconcile Before The Next Material Phase

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
```

If `Decision Baseline Impact` identifies a conflict, the next action cannot be
`continue` until the user confirms the decision outcome and both artifacts are
updated.

## Reviewing Existing Plans

Lead with findings. Check for:

- missing or misplaced `decisions.md` and `plan.md`;
- missing cross-links, `## Design`, `## Work Units`, or applicable decision IDs;
- active decisions that were inferred rather than user-confirmed;
- plans or work units that violate `Must Not Do`;
- silent edits or deletion of active decisions;
- vague actions, speculative construction, or missing smaller alternatives;
- missing/generic Benefits or Side Effects;
- material uncertainty with no bounded validation;
- validation that becomes production implementation;
- phase evidence ignored while stale downstream work continues;
- mixed states, oversized units, template bloat, or unsupported facts.

## Output Quality Checklist

- [ ] Topic artifacts exist at `docs/releases/<confirmed-version>/<topic-slug>/`.
- [ ] `decisions.md` and `plan.md` are independent, cross-linked, and reused.
- [ ] Active decisions are user-confirmed and state Must Do, Must Not Do,
      rationale, and violation signal.
- [ ] `plan.md` contains Design, Work Units, and applicable active decision IDs.
- [ ] Units are concrete, minimum-necessary, small, and safely stoppable.
- [ ] Every unit has specific Benefit and Complexity plus Reach/Cost Side Effects.
- [ ] Critical uncertainty is validated before disproportionate investment.
- [ ] Material phases reconcile evidence and decision-baseline impact.
- [ ] Current facts outrank stale plan details, while user intent is not silently
      rewritten.
- [ ] State models remain separate and structure remains concise.
