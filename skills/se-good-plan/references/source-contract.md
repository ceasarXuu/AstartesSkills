# SE Good Plan Source Contract

This normalized contract is derived from the attached design document:
`Software Engineering Plan Writing Skill Design`, created 2026-06-04, v0.1.

The sanity script uses this file as checked-in traceability for requirements
that must not disappear from the installable skill package.

## Trigger Contract

The skill must trigger for:

- software engineering plan
- implementation plan
- refactor plan
- migration plan
- rollout plan
- bug-fix plan
- performance optimization plan
- security change plan
- DevOps / CI/CD plan
- technical execution plan
- review of an existing engineering plan

## Context Honesty Contract

The skill must not invent:

- codebase architecture
- databases or services
- business rules
- traffic or data scale
- schedules
- staffing
- resource commitments
- deadlines
- launch dates
- maintenance windows

Missing context must be represented as assumptions, open questions, or
`Phase 0: Discovery`.

## Plan Depth Contract

The skill must support:

| Complexity | Plan depth | Typical phase count |
| --- | --- | ---: |
| Low | Lightweight | 2-3 |
| Medium | Standard | 4-5 |
| High | Full | 6-8 |
| Critical | Full with stronger review gates | 7-10 |

## Standard Plan Required Sections

1. Metadata
2. Background
3. Problem Definition
4. Goals
5. Non-goals
6. Constraints And Assumptions
7. Current State
8. Plan Summary
9. Overall Technical Design
10. Phased Execution Plan
11. Implementation Completeness Matrix
12. Risks, Dependencies, And Mitigations
13. Testing And Validation Strategy
14. Release, Rollback, And Fallback Strategy
15. Observability And Success Metrics
16. Open Questions
17. Change Log
18. Plan Quality Checklist

## Full Plan Required Additions

- Complexity And Risk Assessment
- Alternatives And Tradeoffs
- Phase Gate Overview
- Data Migration Strategy
- API / Compatibility Strategy
- Security And Permission Review
- Post-release Verification And Cleanup
- Decision Log

## Metadata Contract

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

## Dependency Contract

```markdown
| Dependency | Type | Current Status | Blocking Risk | Handling Plan |
|---|---|---|---|---|
| ... | system / person / data / environment / third-party | Ready / Pending / Unknown | ... | ... |
```

## Implementation Completeness Contract

Plans that expect code changes must trace each planned item to production code,
an integration entry, test evidence, runtime or log evidence, mock or stub
exposure, and status.

`landed` is the only complete status. `planned`, `partial`, `stub-only`, and
`mock-only` cannot satisfy an exit gate unless the user explicitly accepts the
remaining risk and the follow-up location is recorded.

## Benefit Validation Contract

Plans must state expected benefits, not only implementation deliverables.

Acceptance must include:

- correctness validation: tests that prove the change works without regressions,
  data loss, compatibility failures, or security failures
- benefit validation: tests or measurements that prove the target outcome
  improved, such as speed, accuracy, reliability, cost, conversion, or
  operational-toil improvement

Benefit validation must state metric, baseline, target, measurement method, data
source, observation window, and pass/fail threshold when relevant. Unknown
baselines or targets must be marked `Unknown` and discovered early; they must not
be invented.

## Logging Design Contract

Plans that change runtime behavior, release flow, data movement, jobs, APIs,
user workflows, or operator procedures must include a logging design for the
affected change chain.

The logging design must state:

- change links covered from trigger to side effect
- key states emitted by each link
- success signals for each important state transition
- failure signals for each important state transition
- structured failure reason fields such as `error_code`, `reason`,
  `exception`, or `validation_error`
- correlation or trace fields such as `request_id`, `job_id`, `trace_id`,
  `release_id`, `batch_id`, or `entity_id`
- log levels and consumers for rollout, debugging, audit, support, dashboards,
  alerts, or runbooks

Validation must prove the planned logs, traces, metrics, or audit events can
show whether the change succeeded, failed, became ambiguous, and why.

If a state cannot be logged safely, the plan must explain the privacy, security,
cost, or cardinality reason and define an alternate metric, trace, or audit
event.

## Phase Contract

Every Standard or Full phase must be independently verifiable. A phase gate
cannot rely on implementation, rollout, metrics, cleanup, or review evidence
that only appears in a later phase.

Each phase gate must state:

- evidence available before the next phase starts
- whether the phase is 100% complete
- whether any dependency is inverted or future-dependent
- whether residual risk exists
- whether the user explicitly approved proceeding with residual risk
- the final decision: `proceed` or `pause`

If a phase is incomplete, blocked, ambiguous, or depends on future evidence,
the plan must pause unless the user explicitly approves proceeding and the
residual risk is recorded.

Every Standard or Full phase must include:

1. Objective
2. Entry Criteria
3. Entry Criteria Checks
4. Design Approach
5. Implementation Tasks
6. Deliverables
7. Implementation Completeness Evidence
8. Logging And Observability Design
9. Testing And Validation
10. Exit Criteria
11. Review Plan
12. Risks And Fallback
13. Gate To Next Phase

## High-Risk Contract

Production-impacting work must include release, rollback, fallback or
degradation, observability, logging design, and post-release validation.

Data changes must include migration, idempotency, retry or resume behavior,
validation, and rollback or compensation.

Security-sensitive work must include permission boundaries, sensitive-data
handling, abuse cases, audit logging, and security review.

## Existing Plan Review Contract

When reviewing an existing plan, the skill must lead with findings and check
for missing problem definition, measurable goals, non-goals, phase gates,
rollback, observability, data safeguards, security review, and unsupported
project facts.
