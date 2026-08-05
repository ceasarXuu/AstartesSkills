---
name: se-good-plan
description: Use when the user asks for a software engineering plan, implementation plan, refactor plan, migration plan, rollout plan, bug-fix plan, performance optimization plan, security change plan, DevOps / CI/CD plan, technical execution plan, or review of an existing engineering plan. Produces concise, executable, evidence-updated plans built from minimum-necessary engineering changes and small independently checkable work units.
---

# SE Good Plan

## Purpose

Write or review engineering plans that are directly executable, proportionate to
the problem, and updated by real evidence rather than followed mechanically.
Plans must minimize unnecessary construction, use small closed-loop work units,
explain benefit and side effects, validate high-cost directions before major
investment, and reconsider downstream work when implementation changes the facts.

A good plan answers:

- What exact problem, location, object, and action are involved?
- Is this the smallest necessary construction?
- What behavior, project benefit, complexity, reach, and continuing cost result?
- Which critical uncertainty could invalidate later investment?
- What is the cheapest credible evidence needed before committing?
- After each material phase, do current facts still support the remaining plan?

## Use This Skill When

- The user asks for an implementation, refactor, migration, rollout, bug-fix,
  performance, security, DevOps, CI/CD, release, or other engineering plan.
- The user asks to split work into executable units or phases.
- The user asks to make a plan concrete, concise, reviewable, or ready to execute.
- The user asks whether a plan is vague, oversized, over-engineered, insufficiently
  validated, over-validated, stale, or unsafe to continue.

Do not use this skill for pure product clarification unless requirements must be
converted into engineering execution. Do not over-plan tiny, low-risk edits.

## Core Rules

### 1. Plans Must Be Executable

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

### 2. Use The Smallest Closed-Loop Engineering Unit

Each unit has one primary objective, change axis, action, benefit, and bounded
side-effect profile. It must be independently inspectable, auditable, verifiable,
and reversible, disableable, or safely stoppable.

Split independent API, data, implementation, cache, client, deployment,
observability, security, and cleanup work. A phase may sequence units but cannot
hide their individual actions, evidence, states, or safe-stop boundaries.

### 3. Prefer Minimum Necessary Construction

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
enough. Preserve future decision space without implementing unconfirmed features.

Temporary compatibility or migration logic needs retirement criteria and a
cleanup unit. Benefit must justify complexity and continuing cost.

### 4. Make Benefit And Side Effects Explicit

`Resulting Behavior` explains what changes technically. `Benefit` explains why
it matters to users, delivery, reliability, maintenance, cost, support, risk, or
operations. Generic claims or copies of Resulting Behavior are invalid.

A Side Effect is an expected consequence even when implementation works. A Risk
is uncertain; Rollback is recovery. Every Side Effects field covers:

- **Complexity:** code/files/concepts/abstractions/states/branches/dependencies/
  configuration/schema/runtime paths/temporary logic added or removed.
- **Reach / cost:** affected modules/callers/data/tests/builds/CI/deployment/
  resources/security/operations/support/ownership/cognitive load/cleanup.

`None`, `minimal impact`, `low risk`, or `N/A` are invalid. A no-material-effect
claim must name the unchanged dimensions and why.

### 5. Use Minimum Sufficient Pre-Investment Validation

Before expensive, broad, irreversible, or dependency-sensitive implementation,
identify any **critical assumption** whose failure would invalidate substantial
later work. Validate only to the level needed to decide whether the direction is
worth formal investment.

Use the cheapest credible evidence ladder:

```text
existing evidence / static inspection
  -> read-only observation
  -> isolated request or script
  -> sandbox or disposable spike
  -> formal implementation only when the uncertainty cannot be isolated
```

Validation must define:

- the critical assumption and decision it unlocks;
- what counts as enough evidence and what is intentionally not proven;
- a bounded time/code/environment budget;
- allowed artifacts and forbidden production changes;
- stop condition and cleanup or promotion path;
- evidence level: Static, Observed, Mock, Sandbox, Prototype, or Production.

Validation is not a shadow implementation. It must not silently modify production
entry points, schemas, defaults, deployment routes, long-lived configuration, or
public abstractions. If credible validation requires near-formal implementation,
reclassify it as an implementation unit instead of calling it validation.

A supported direction is not an implemented feature. Mock, Sandbox, and
Prototype evidence cannot be reported as production integration evidence.

### 6. Evidence Supersedes The Plan

The plan is a hypothesis based on earlier information. Verified current code,
tests, logs, data, dependency behavior, and runtime observations outrank plan
assumptions and preplanned order.

After every material phase in Execution Tracking, reconcile:

- new facts and evidence level;
- assumptions or prior conclusions confirmed, qualified, superseded, invalidated,
  or requiring revalidation;
- change in Benefit, Side Effects, cost, risk, dependencies, or priority;
- downstream units to continue, revise, split, remove, add, reorder, pause, or stop.

Do not automatically continue because the phase completed. Preserve old
conclusions and mark their new validity; never silently rewrite history. If
material evidence conflicts with the plan, pause affected downstream work until
reconciliation produces an explicit next action.

### 7. Separate State Models

`Plan Authoring` uses `planned`, `blocked-on-discovery`, and `deferred`. It cannot
claim completed execution.

Pre-investment validation uses `planned`, `direction-supported`,
`direction-rejected`, `inconclusive`, or `budget-exhausted`. These states do not
mean implementation is complete.

`Execution Tracking` uses `not-started`, `in-progress`, `verified`, `blocked`,
`failed`, or `rolled-back`. Plan validity is separately `valid`,
`valid-with-qualifications`, `needs-revision`, or `invalidated`.

Discovery/design artifacts use `planned`, `drafted`, `reviewed`, or `verified`.
Code implementation uses `planned`, `implemented`, `integrated`, or
`runtime-verified`. Do not mix these models.

### 8. Prefer Concise Structure

Use the smallest document shape preserving engineering clarity. Add validation
or reconciliation sections only when their trigger exists. Do not duplicate
risks, tests, logs, benefits, side effects, or evidence merely to fill a template.

### 9. Preserve Engineering Safety

- Separate facts, assumptions, constraints, risks, and open questions.
- Do not invent architecture, scale, schedules, staffing, deadlines, or releases.
- Production work includes release, rollback/fallback, observability, and
  post-release validation.
- Data changes include idempotency, retry/resume, validation, and compensation.
- Security changes include permissions, sensitive-data handling, abuse cases,
  audit logging, and review.
- Runtime-changing work exposes success, failure, and failure reasons.

## Generation Workflow

### 1. Classify Scope, Risk, And Material Uncertainty

Read `references/plan-patterns.md` for task-specific additions.

| Depth | Use when | Typical shape |
|---|---|---|
| Lightweight | narrow, low-risk, easy rollback | 1-3 units |
| Standard | several moving parts or controlled production risk | useful phases with small units |
| Full | data, security, compatibility, cross-system, hard rollback | Standard plus only relevant safety material |

Mark `Material Uncertainty: yes` only when a critical unknown could invalidate
substantial later investment. Do not force validation for already evidenced,
narrow, reversible work.

### 2. Define The Problem And Least-Construction Approach

State current/expected behavior, gap, affected surfaces, goals, non-goals,
assumptions, and open questions briefly. Explain what existing logic is deleted,
changed, or reused before proposing new structures.

### 3. Add A Bounded Pre-Investment Validation Gate When Needed

```markdown
| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
| V1 | ... | ... | Sandbox Evidence: ... | enough: ...; not proven: ... | Budget: ...; Allowed: ...; Forbidden: ... | Stop: ...; Cleanup/Promotion: ... | planned |
```

If the validation method requires full production integration, broad production
changes, or formal hardening, shrink it or move that work into implementation.

### 4. Build Work Units

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | ... | internal / API / data / cache / client / deployment / observability / cleanup / security | concrete location | named object | one action | technical effect | wider value | Complexity: ...; Reach/Cost: ... | exact evidence | ... | planned |
```

### 5. Group Into Phases Only When Useful

```markdown
### Phase N: <Outcome>

- Entry condition:
- Work units:
- Phase-local evidence:
- Cross-unit side effects:
- Next-phase condition:
```

### 6. Reconcile Before Starting The Next Material Phase

In Execution Tracking, add:

```markdown
| Phase | New Evidence | Affected Assumption / Prior Conclusion | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|
| Phase N | ... | ... | qualified: ... | revise W4; remove W5 | needs-revision | revise |
```

Allowed conclusion prefixes: `current:`, `qualified:`, `superseded:`,
`invalidated:`, `needs-revalidation:`. Allowed next actions: `continue`, `revise`,
`pause`, or `stop`. `needs-revision` or `invalidated` cannot continue unchanged.

### 7. Add Only Relevant Supporting Sections

Add only applicable formal benefit validation, release/rollback, migration,
compatibility, security, observability, risks/dependencies, alternatives,
decisions, or open questions.

## Reviewing Existing Plans

Lead with findings. Check for:

- vague actions, speculative construction, or missing smaller alternatives;
- missing/generic Benefits or Side Effects;
- expensive implementation started before a critical assumption is validated;
- validation with no evidence threshold, budget, isolation, stop, or cleanup;
- validation that nearly implements the formal solution or pollutes production;
- Mock/Prototype evidence presented as implementation or production evidence;
- material phase evidence ignored while the old downstream plan continues;
- prior conclusions silently overwritten instead of qualified or superseded;
- mixed state models, oversized units, template bloat, or unsupported facts.

## Output Quality Checklist

- [ ] Units are concrete, minimum-necessary, small, and safely stoppable.
- [ ] Every unit has specific Benefit and Complexity plus Reach/Cost Side Effects.
- [ ] Critical uncertainty is validated before disproportionate investment.
- [ ] Validation proves only investment confidence, with budget and isolation.
- [ ] Validation artifacts cannot masquerade as implementation evidence.
- [ ] Material phases end with evidence reconciliation before downstream work.
- [ ] Current facts outrank stale plan assumptions and order.
- [ ] Prior conclusions remain traceable when qualified or superseded.
- [ ] State models remain separate and structure remains concise.
