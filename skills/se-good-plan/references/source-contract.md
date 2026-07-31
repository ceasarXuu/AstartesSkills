# SE Good Plan Source Contract

This file defines the behavior that must remain stable across future edits to
`se-good-plan`.

## Trigger Contract

The skill must trigger for software engineering implementation, refactor,
migration, rollout, bug-fix, performance, security, DevOps / CI/CD, release,
technical execution, plan decomposition, and existing-plan review requests.

## Context Honesty Contract

The skill must not invent architecture, services, databases, traffic, data
scale, business rules, schedules, staffing, deadlines, release dates, or
maintenance windows. Missing information must be represented as an assumption,
open question, or concrete Discovery work unit.

## Executable Specificity Contract

An implementation plan must identify for every work unit:

- a concrete change location
- a named target object
- one explicit engineering action
- the resulting behavior or invariant
- a specific benefit understandable to wider project members
- exact verification evidence

Abstract statements such as "refactor the module", "add an abstraction",
"optimize caching", "improve error handling", or "complete integration" do not
satisfy this contract by themselves.

If the location or target object is unknown, the plan must use
`blocked-on-discovery` and define the inspection location, command or method,
expected evidence, decision that evidence unlocks, and benefit of resolving the
unknown.

## Smallest Closed-Loop Engineering Unit Contract

Plans must decompose work into the smallest coherent units that are
independently executable, inspectable, auditable, verifiable, and reversible or
safely stoppable.

Each work unit must have:

- one primary objective or invariant
- one primary change axis
- one primary engineering action
- one explicit benefit
- a bounded change surface
- explicit dependencies
- independent verification
- an independent rollback, disable, or safe-stop boundary

A unit must be split when it combines independent API, data, internal
implementation, cache, client, deployment, observability, security, or cleanup
changes. A phase may sequence multiple units, but it cannot hide their
individual actions, benefits, evidence, status, or rollback boundaries.

## Benefit Communication Contract

Every work unit must contain a `Benefit` field.

The Benefit must:

- explain why the unit matters beyond its implementation details
- connect the technical change to a project, user, team, delivery, reliability,
  maintainability, cost, support, risk, or operational outcome
- be understandable to project members outside the implementation area
- be specific enough to distinguish the unit from neighboring units
- not merely repeat `Resulting Behavior`

Generic statements such as "improves quality", "adds value", "helps the
project", or "makes the system better" are invalid.

A Benefit may be qualitative. Formal benefit validation with a metric,
baseline, target, data source, and observation window is required only when the
benefit is measurable, disputed, or material to a decision or release gate.

## Plan And Execution State Contract

`Plan Authoring` is the default mode.

Allowed planning statuses:

- `planned`
- `blocked-on-discovery`
- `deferred`

A plan draft must not claim `complete`, `landed`, `verified`, `proceed`, or any
other execution result without actual evidence supplied by the user or verified
through tools.

`Execution Tracking` may use:

- `not-started`
- `in-progress`
- `verified`
- `blocked`
- `failed`
- `rolled-back`

Proceed or pause decisions belong to Execution Tracking.

## Artifact And Code Status Contract

Discovery and design artifacts use:

- `planned`
- `drafted`
- `reviewed`
- `verified`

Code-bearing implementation uses:

- `planned`
- `implemented`
- `integrated`
- `runtime-verified`

Discovery inventories, design documents, decision records, and review artifacts
must not use production-code states. Protocols, schemas, scaffolds, mocks, fake
data, demos, and test-only wiring do not prove a production implementation is
integrated or runtime-verified.

## Proportional Output Contract

The skill must prefer the smallest document shape that preserves clarity.

- Lightweight: problem, target, 1-3 work units, verification, and rollback.
- Standard: concise context, technical approach, phased work units,
  verification, and relevant release or risk sections.
- Full: Standard plus only the data, compatibility, security, release,
  observability, alternatives, or decision sections required by the risk.

The skill must not require a fixed 18-section document or a large repeated
subsection template for every phase. Optional sections are included only when
they affect execution, validation, safety, or a decision.

## Work Unit Contract

The primary implementation representation is:

```markdown
| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|
```

A valid row has one primary change axis, one primary action, and one specific
Benefit. Dependencies set order but do not justify coupling unrelated changes
into one row.

## Phase Contract

Phases are optional sequencing and risk-isolation containers. A phase must name
its entry condition, included work units, phase-local evidence, and the
condition for starting the next phase.

In Plan Authoring mode these are future requirements, not completed evidence or
a proceed decision. If one phase can be verified only by a later phase, the
boundary must be changed or the work units must be split.

## Engineering Safety Contract

Production-impacting work includes release, rollback or fallback,
observability, and post-release validation.

Data changes include idempotency, retry or resume behavior, validation, and
rollback or compensation.

Security-sensitive work includes permission boundaries, sensitive-data
handling, abuse cases, audit logging, and security review.

Every work unit states its Benefit. Formal benefit validation is added when the
claim is measurable or material to a decision. Runtime-changing work makes
important success, failure, and failure-reason states observable.

## Existing Plan Review Contract

Review mode must lead with findings and check for vague actions, missing change
locations or objects, missing or generic benefits, oversized work units,
coupled change axes, hidden work inside broad phases, mixed planning and
execution states, mixed artifact and code statuses, template bloat, missing
verification, missing rollback, and unsupported project facts.

## Behavioral Validation Contract

Repository tests must validate representative plan outputs, not only the
presence of contract keywords. The quality validator must reject at least:

- vague actions without concrete engineering mechanics
- multiple primary change axes or actions in one unit
- missing, thin, generic, or behavior-duplicating benefits
- execution-complete states in a Plan Authoring document
- production-code states applied to discovery or design artifacts

It must also accept a concise plan composed of concrete, single-axis,
independently verifiable work units with specific benefits.
