---
name: se-good-plan
description: Use when the user asks for a software engineering plan, implementation plan, refactor plan, migration plan, rollout plan, bug-fix plan, performance optimization plan, security change plan, DevOps / CI/CD plan, technical execution plan, or review of an existing engineering plan. Produces concise, executable plans built from minimum-necessary engineering changes and small independently checkable work units whose benefits and side effects are understandable to the wider project team.
---

# SE Good Plan

## Purpose

Use this skill to write or review software engineering plans that engineers can
execute directly and wider project members can understand. Plans must make the
intended change concrete, minimize unnecessary construction, split work into
small closed-loop engineering units, and explain both the benefit and side
effects of each unit without turning the document into a ceremonial template.

A good plan answers:

- What exact engineering problem is being solved?
- Where will the change happen, to which object, and through which action?
- Is this the smallest necessary construction, or can existing logic be deleted,
  changed, or reused instead?
- What behavior and project benefit will result?
- What complexity, affected surface, and continuing cost will the unit add?
- How will the unit be verified and safely stopped or reverted?

## Use This Skill When

- The user asks for an implementation, refactor, migration, rollout, bug-fix,
  performance, security, DevOps, CI/CD, release, or other engineering plan.
- The user asks to split engineering work into phases or executable steps.
- The user asks to make an existing plan more concrete, concise, reviewable, or
  ready for execution.
- The user asks whether a plan is vague, oversized, over-engineered, too coupled,
  or unsafe to execute.

Do not use this skill for pure product requirement clarification unless the
request is to convert requirements into engineering execution. Do not over-plan
tiny, low-risk edits.

## Core Rules

### 1. Plans Must Be Executable

A plan is not executable when it only says "add an abstraction", "refactor the
module", "optimize caching", "improve error handling", or "complete integration".

For every work unit, state:

- **Change location:** module, file, component, service, configuration, schema,
  API, job, pipeline stage, command, or deployment surface.
- **Target object:** function, class, interface, table, field, key, endpoint,
  handler, worker, workflow, rule, or other named engineering object.
- **Concrete action:** add, change, remove, replace, move, split, route, migrate,
  wire, validate, rename, or another explicit operation.
- **Resulting behavior:** the immediate technical behavior or invariant.
- **Benefit:** why the unit matters to the project or its participants.
- **Side Effects:** expected complexity, affected surface, and continuing cost
  even when the implementation works as designed.
- **Verification:** exact evidence that proves the action worked.

If a location or object is unknown, mark it `Unknown` and add a concrete
Discovery unit instead of pretending the plan is implementation-ready.

### 2. Use The Smallest Closed-Loop Engineering Unit

Decompose work into the smallest coherent unit that is independently:

- executable
- inspectable, reviewable, and auditable
- verifiable
- reversible, disableable, or safely stoppable

Each unit should have one primary engineering objective or invariant, one
primary change axis, one primary action, one benefit, and one bounded side-effect
profile. Execute one small, checkable piece, verify it, then move to the next.

Split a unit when it couples independent API, data, internal implementation,
cache, client, deployment, observability, security, or cleanup changes. A phase
may sequence multiple units but must not hide their individual actions,
benefits, side effects, evidence, status, or safe-stop boundaries.

### 3. Prefer Minimum Necessary Construction

Plan for the required behavior, not the largest complete-looking architecture.
Use this preference order:

```text
delete or simplify existing logic
  -> change an existing path
  -> reuse an existing mechanism
  -> add narrow local logic
  -> add a new abstraction
  -> add a new dependency or stateful infrastructure
```

The farther a proposal moves down this list, the stronger its proof burden.
New interfaces, factories, providers, registries, configuration switches,
states, runtime branches, caches, queues, jobs, dependencies, schemas, or
frameworks must be justified by a current confirmed need or risk. A possible
future requirement is not sufficient evidence.

Preserve future decision space without implementing unconfirmed capabilities.
Do not build a plugin system merely to avoid a local conditional, or a generic
framework for one current implementation. Temporary compatibility or migration
logic must have retirement criteria and a cleanup unit.

Before accepting a construction-heavy unit, compare it with the smallest
credible delete/change/reuse alternative. Listing side effects does not justify
them; the unit's Benefit must outweigh its complexity and continuing cost.

### 4. Make Every Unit's Benefit Understandable

`Resulting Behavior` explains what changes technically. `Benefit` explains why
that change is useful to the wider project.

A valid Benefit names an affected audience or outcome, such as reduced incident
risk, safer delivery, lower support effort, improved user capability, clearer
failure diagnosis, lower cost, or enabling a later unit without breaking the
current path.

Do not use generic statements such as "improves quality", "adds value", or
"makes the system better". Do not repeat Resulting Behavior. Benefits may be
qualitative; add metrics and baselines only when measurable or decision-critical.

### 5. State Side Effects, Not Only Risks

A Side Effect is an expected consequence or continuing obligation even when the
change works correctly. A Risk is an uncertain adverse event. Rollback describes
recovery. Do not merge these concepts.

Every unit's Side Effects must cover two minimum dimensions:

- **Complexity:** net code and architecture delta, including added or removed
  files, concepts, abstractions, states, branches, dependencies, configuration,
  persistent structures, runtime paths, and temporary compatibility logic.
- **Reach / cost:** affected modules, callers, clients, data, build/test scope,
  CI latency, deployment coordination, CPU, memory, IO, storage, network,
  third-party spend, security/privacy exposure, on-call, support, documentation,
  ownership, cognitive load, and cleanup obligations when applicable.

Use a compact form such as:

```text
Complexity: +1 routing branch, temporary until W4; Reach/Cost: account API,
contract tests, and on-call route diagnosis are affected.
```

`None`, `minimal impact`, `low risk`, or `N/A` are invalid. When no material
side effect is expected, state why and name the unchanged dimensions.

### 6. Separate Plan Authoring From Execution Tracking

`Plan Authoring` is the default mode. Allowed plan statuses are `planned`,
`blocked-on-discovery`, and `deferred`. Do not claim `complete`, `landed`,
`verified`, or `proceed` without actual execution evidence.

Use `Execution Tracking` only for actual progress. Allowed execution statuses
are `not-started`, `in-progress`, `verified`, `blocked`, `failed`, and
`rolled-back`. Proceed or pause decisions belong to Execution Tracking.

### 7. Keep Artifact And Code Status Models Separate

Discovery and design artifacts use `planned`, `drafted`, `reviewed`, or
`verified`. Code-bearing implementation uses `planned`, `implemented`,
`integrated`, or `runtime-verified`.

Do not apply production-code states to inventories, designs, decision records,
or reviews. Interfaces, schemas, scaffolds, mocks, demos, and test-only wiring do
not prove a production path is integrated or runtime-verified.

### 8. Prefer Concise Structure Over Template Ceremony

Use the smallest document shape that preserves engineering clarity. Do not add
sections or duplicate risks, tests, logs, benefits, or side effects merely to
fill a template. Optional material belongs only when it changes a decision,
execution order, validation method, safety boundary, or risk treatment.

### 9. Preserve Engineering Safety

- Separate facts, assumptions, constraints, risks, and open questions.
- Do not invent architecture, scale, schedules, staffing, deadlines, or release
  commitments.
- Move high-risk and high-uncertainty validation earlier.
- Production work includes release, rollback/fallback, observability, and
  post-release validation.
- Data changes include idempotency, retry/resume, validation, and compensation.
- Security changes include permission boundaries, sensitive-data handling,
  abuse cases, audit logging, and review.
- Runtime-changing work makes success, failure, and failure reasons observable.

## Generation Workflow

### 1. Classify Scope And Risk

Read `references/plan-patterns.md` for task-specific additions.

| Depth | Use when | Typical shape |
|---|---|---|
| Lightweight | narrow, low-risk, easy rollback | 1-3 work units |
| Standard | several moving parts or controlled production risk | 2-5 phases with small units |
| Full | data, security, compatibility, cross-system, or hard rollback risk | Standard plus only relevant safety sections |

### 2. Define The Problem And Target

State current behavior, expected behavior, gap, affected surfaces, goals,
non-goals, assumptions, and open questions briefly. Missing context becomes a
bounded Discovery unit with an inspection location, method, evidence, unlocked
decision, Benefit, and Side Effects.

### 3. Choose The Least-Construction Technical Approach

Describe the target control/data flow or structural change at the level needed
to understand the units. State what existing logic is deleted, changed, or
reused before proposing new structures. For a new abstraction or infrastructure,
state the current concrete need and why a smaller alternative is insufficient.

### 4. Build Work Units

Use this as the primary execution representation:

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | ... | internal / API / data / cache / client / deployment / observability / cleanup / security | path, module, service, config, schema, job, or command | named function, class, endpoint, field, key, workflow, or rule | one explicit engineering action | immediate technical effect | wider project value | Complexity: ...; Reach/Cost: ... | exact evidence | ... | planned / blocked-on-discovery / deferred |
```

Rules:

- One row is one smallest closed-loop engineering unit.
- One row has one primary change axis and one primary action.
- Benefit cannot be blank, generic, or a copy of Resulting Behavior.
- Side Effects must cover Complexity and Reach/Cost; generic claims are invalid.
- Dependencies determine order; they do not justify coupling unrelated work.
- Split any row that cannot be verified or safely stopped independently.
- Reject speculative construction for possible future use without a current need.

### 5. Group Into Phases Only When Useful

Use phases only for sequencing, risk isolation, or release boundaries:

```markdown
### Phase N: <Outcome>

- Entry condition:
- Work units: W1, W2
- Phase-local evidence:
- Cross-unit side effects:
- Next-phase condition:
```

`Cross-unit side effects` records only cumulative or interacting effects not
already captured per unit. For a multi-unit phase, state them or explain why
there are none beyond the unit-level effects.

### 6. Add Only Relevant Supporting Sections

Add only applicable verification, formal benefit validation, release/rollback,
data migration, compatibility, security, observability, risks/dependencies,
alternatives/decisions, or open questions. Use compact structures from the
reference instead of repeating large per-phase templates.

## Reviewing Existing Plans

Lead with findings. Check for:

- abstract actions without concrete locations, objects, or operations
- speculative abstractions or infrastructure without a current proven need
- missing consideration of delete/change/reuse alternatives
- missing, generic, duplicated, or implementation-only Benefits
- missing or generic Side Effects, especially hidden code/state/path growth
- effects on other modules, validation scope, runtime cost, operations, support,
  ownership, and cleanup that are omitted
- oversized units, coupled axes, or broad phases hiding unreviewable work
- temporary logic without retirement criteria
- mixed planning/execution states or artifact/code statuses
- template bloat, missing verification/rollback, or unsupported project facts

Then provide a compact corrected outline or rewritten work-unit section.

## Output Quality Checklist

- [ ] Locations, target objects, and actions are concrete.
- [ ] Delete/change/reuse was considered before new construction.
- [ ] Every new abstraction, state, dependency, or runtime path has current evidence.
- [ ] Work is split into smallest closed-loop units with one primary axis/action.
- [ ] Every unit has a specific Benefit understandable to wider project members.
- [ ] Every unit states Complexity and Reach/Cost Side Effects.
- [ ] Benefit is proportionate to the complexity and continuing cost introduced.
- [ ] Temporary complexity has retirement criteria and a cleanup unit.
- [ ] Units are independently inspectable, verifiable, and safely stoppable.
- [ ] Phases expose cumulative cross-unit side effects when applicable.
- [ ] Planning/execution states and artifact/code statuses are not mixed.
- [ ] Structure is concise and relevant engineering safety is preserved.
