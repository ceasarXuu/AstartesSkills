---
name: se-good-plan
description: Use when the user asks for a software engineering plan, implementation plan, refactor plan, migration plan, rollout plan, bug-fix plan, performance optimization plan, security change plan, DevOps / CI/CD plan, technical execution plan, or review of an existing engineering plan. Produces concise, executable plans built from concrete engineering actions and small independently checkable work units whose benefits are understandable to the wider project team.
---

# SE Good Plan

## Purpose

Use this skill to write or review software engineering plans that engineers can
execute directly and wider project members can understand. Plans must make the
intended change concrete, split work into small closed-loop engineering units,
and explain the benefit of each unit without turning the document into a large
ceremonial template.

A good plan answers:

- What exact engineering problem is being solved?
- Where will the change happen?
- Which concrete object will be changed?
- What exact action will be performed?
- What behavior will result?
- What project, user, team, reliability, cost, delivery, or operational benefit
  does this unit provide?
- How will the unit be verified and safely stopped or reverted?

## Use This Skill When

- The user asks for an implementation, refactor, migration, rollout, bug-fix,
  performance, security, DevOps, CI/CD, release, or other engineering plan.
- The user asks to split engineering work into phases or executable steps.
- The user asks to make an existing plan more concrete, concise, reviewable, or
  ready for execution.
- The user asks whether an engineering plan is too vague, too large, too
  coupled, or unsafe to execute.

Do not use this skill for pure product requirement clarification unless the
request is to convert requirements into engineering execution. Do not over-plan
tiny, low-risk edits.

## Core Rules

### 1. Plans Must Be Executable

A plan is not executable when it only says things such as "add an abstraction",
"refactor the module", "optimize caching", "improve error handling", or
"complete integration".

For every work unit, state when applicable:

- **Change location:** module, file, component, service, configuration, schema,
  API, job, pipeline stage, command, or deployment surface.
- **Target object:** function, class, interface, table, field, key, endpoint,
  handler, worker, workflow, rule, or other named engineering object.
- **Concrete action:** add, change, remove, replace, move, split, route, migrate,
  wire, validate, rename, or another explicit operation.
- **Resulting behavior:** the immediate technical behavior or invariant after
  the change.
- **Benefit:** why this unit matters to the project, users, delivery process,
  reliability, maintainability, cost, risk, support, or operations, written so
  project members outside the implementation area can understand it.
- **Verification:** the test, command, review, artifact, log, trace, or metric
  that proves the action worked.

Do not use abstract verbs as substitutes for an engineering design. If a
location or object is unknown, mark it `Unknown` and add a concrete Discovery
work unit instead of pretending the plan is implementation-ready.

### 2. Use The Smallest Closed-Loop Engineering Unit

Decompose work into the smallest coherent unit that is independently:

- executable
- inspectable
- reviewable and auditable
- verifiable
- reversible, disableable, or safely stoppable

Each unit should have one primary engineering objective or invariant, one
primary change axis, one primary action, and one explicit benefit. Follow
small-step delivery: execute one small, checkable piece, verify it, then move to
the next piece.

Split a unit when it couples independent axes such as:

- public API behavior
- persistent schema or data migration
- internal implementation
- cache or consistency behavior
- client integration
- deployment or traffic routing
- old-path cleanup

A phase may group multiple work units for sequencing, but the phase must not
hide a large undifferentiated change. Every unit inside the phase still needs
its own concrete action, benefit, verification, status, and safe-stop boundary.

### 3. Make Every Unit's Benefit Understandable

`Resulting Behavior` and `Benefit` are different:

- `Resulting Behavior` explains what changes technically.
- `Benefit` explains why that technical change is useful to the wider project.

A valid benefit names the affected audience or project outcome and is specific
enough to distinguish the unit from neighboring units. Suitable benefit types
include:

- reduced incident or compatibility risk
- faster or safer delivery
- lower operational or support effort
- improved user capability or experience
- clearer ownership or failure diagnosis
- reduced maintenance or infrastructure cost
- enabling a later unit without breaking the current path

Do not use generic statements such as "improves quality", "adds value", or
"makes the system better". Do not merely repeat the resulting behavior.
Benefits may be qualitative. Add formal metrics, baselines, targets, and
observation windows only when the benefit is measurable or decision-critical.

### 4. Separate Plan Authoring From Execution Tracking

`Plan Authoring` is the default mode. It defines future work and required
evidence. It must not claim that work has already completed.

Allowed plan statuses:

- `planned`
- `blocked-on-discovery`
- `deferred`

In Plan Authoring mode, do not use `complete`, `landed`, `verified`, `proceed`,
or similar execution claims unless real execution evidence was supplied by the
user or verified through tools.

Use `Execution Tracking` mode only when reviewing actual implementation
progress. Allowed execution statuses are:

- `not-started`
- `in-progress`
- `verified`
- `blocked`
- `failed`
- `rolled-back`

A proceed or pause decision belongs to Execution Tracking, not to an initial
plan draft.

### 5. Keep Artifact And Code Status Models Separate

Discovery and design artifacts are not production code. Use artifact statuses:

- `planned`
- `drafted`
- `reviewed`
- `verified`

Use code implementation statuses only for code-bearing work:

- `planned`
- `implemented`
- `integrated`
- `runtime-verified`

Do not mark an inventory, design document, decision record, or review artifact
as `landed`, `integrated`, or `runtime-verified`. Do not mark code complete
because an interface, schema, scaffold, mock, fake-data path, demo, or test-only
wiring exists without a real production integration path.

### 6. Prefer Concise Structure Over Template Ceremony

Use the smallest document shape that preserves engineering clarity. Do not add
sections or tables merely to fill a template. Avoid repeating the same risks,
tests, logs, or status information globally and again inside every phase.

The plan should emphasize concrete engineering work. Optional material belongs
only when it changes a decision, execution order, validation method, release
safety, or risk treatment.

### 7. Preserve Engineering Safety

- Separate facts, assumptions, constraints, risks, and open questions.
- Do not invent architecture, services, databases, traffic, data scale,
  business rules, schedules, staffing, deadlines, launch dates, or maintenance
  windows.
- Move high-risk and high-uncertainty validation earlier.
- Production-impacting work must include release, rollback or fallback,
  observability, and post-release validation.
- Data changes must include idempotency, retry or resume behavior, validation,
  and rollback or compensation.
- Security-sensitive work must include permission boundaries, sensitive-data
  handling, abuse cases, audit logging, and security review.
- Every work unit must state its benefit. Add formal benefit validation when the
  claimed benefit is measurable or material to the decision.
- Runtime-changing work must make important success, failure, and failure-reason
  states observable.

## Generation Workflow

### 1. Classify Scope And Risk

Classify the work type and risk before choosing plan depth. Read
`references/plan-patterns.md` for task-specific additions.

| Depth | Use when | Typical shape |
|---|---|---|
| Lightweight | narrow, low-risk, easy rollback | 1-3 work units |
| Standard | several moving parts or controlled production risk | 2-5 phases, each with small work units |
| Full | data, security, compatibility, cross-system, or hard rollback risk | only the additional safety sections that apply |

Force Full depth for production data migration, auth or permission boundaries,
payment or asset paths, core API compatibility risk, irreversible change,
cross-system migration, or hard-to-rollback production change.

### 2. Define The Problem And Target

State briefly:

- current behavior
- expected behavior
- gap
- affected surfaces
- goals and non-goals
- material assumptions or open questions

If missing context blocks concrete planning, add a Discovery work unit with an
explicit location to inspect, command to run, evidence to collect, decision the
evidence will unlock, and benefit of removing that uncertainty.

### 3. Describe The Technical Approach

Explain the target control flow, data flow, compatibility approach, migration
mechanism, or structural change at the level needed to understand the work
units. Do not repeat the work-unit rows in prose.

### 4. Build Work Units

Use this table as the primary execution representation:

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|
| W1 | ... | internal / API / data / cache / client / deployment / observability / cleanup / security | path, module, service, config, schema, job, or command | named function, class, endpoint, field, key, workflow, or rule | one explicit engineering action | immediate technical effect or invariant | project, user, team, delivery, reliability, cost, support, or operational value | exact test, command, review, log, trace, metric, or artifact | ... | planned / blocked-on-discovery / deferred |
```

Rules:

- One row is one smallest closed-loop engineering unit.
- One row has one primary change axis and one primary action.
- Every row has a specific Benefit understandable outside the implementation
  area; it cannot be blank, generic, or a copy of Resulting Behavior.
- Dependencies determine order; they do not justify combining unrelated work.
- If a row cannot be verified or safely stopped independently, split it or
  explain the unavoidable coupling.
- A broad row such as "refactor backend and update API, cache, UI, deployment"
  is invalid even if the whole phase has an end-to-end test.

### 5. Group Into Phases Only When Useful

Use phases only to express sequencing, risk isolation, or release boundaries.
A compact phase needs only:

```markdown
### Phase N: <Outcome>

- Entry condition:
- Work units: W1, W2
- Phase-local evidence:
- Next-phase condition:
```

A phase is not required for every low-risk plan. Do not force Discovery,
Design, Foundation, Implementation, Integration, Validation, Release, and
Cleanup into separate headings when a smaller structure is clearer.

In Plan Authoring mode, phase evidence and next-phase conditions describe what
will be required. They are not marked complete or proceed.

### 6. Add Only Relevant Supporting Sections

Add these only when applicable:

- Verification strategy
- Formal benefit validation
- Release, rollback, and fallback
- Data migration and compensation
- API compatibility
- Security and permission review
- Observability and logging
- Risks and dependencies
- Alternatives and decisions
- Open questions

Use compact tables from `references/plan-patterns.md` rather than duplicating
large per-phase templates.

## Reviewing Existing Plans

Lead with findings. Check for:

- abstract actions without a concrete location, object, or operation
- missing, generic, implementation-only, or duplicated unit benefits
- work units that combine several independent change axes or actions
- phases that hide a large undifferentiated implementation block
- units that cannot be checked, audited, or stopped independently
- plan drafts that claim `complete`, `landed`, `verified`, or `proceed` without
  actual execution evidence
- discovery or design artifacts using production-code statuses
- excessive headings, repeated tables, and template filler that obscure the
  engineering work
- missing problem definition, scope control, verification, rollback,
  observability, data safeguards, security review, or supported project facts

Then provide a compact corrected outline or rewritten work-unit section.

## Output Quality Checklist

Before final output, verify:

- [ ] The plan states concrete change locations, target objects, and actions.
- [ ] Abstract verbs are expanded into engineering mechanics.
- [ ] Work is split into smallest closed-loop engineering units.
- [ ] Each unit has one primary objective, change axis, and action.
- [ ] Each unit states a specific benefit understandable to wider project members.
- [ ] Resulting Behavior and Benefit are not duplicates.
- [ ] Each unit is independently inspectable, verifiable, and safely stoppable.
- [ ] Phases express sequencing rather than hiding oversized work.
- [ ] Plan Authoring and Execution Tracking states are not mixed.
- [ ] Artifact statuses and code statuses are not mixed.
- [ ] The structure is concise and contains no empty ceremonial sections.
- [ ] Relevant correctness, formal benefit validation, release, rollback,
      observability, data, and security requirements are present.
- [ ] The plan does not invent project facts, schedules, or commitments.
