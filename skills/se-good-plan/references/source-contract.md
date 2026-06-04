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
11. Risks, Dependencies, And Mitigations
12. Testing And Validation Strategy
13. Release, Rollback, And Fallback Strategy
14. Observability And Success Metrics
15. Open Questions
16. Change Log
17. Plan Quality Checklist

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

## Phase Contract

Every Standard or Full phase must include:

1. Objective
2. Entry Criteria
3. Entry Criteria Checks
4. Design Approach
5. Implementation Tasks
6. Deliverables
7. Testing And Validation
8. Exit Criteria
9. Review Plan
10. Risks And Fallback
11. Gate To Next Phase

## High-Risk Contract

Production-impacting work must include release, rollback, fallback or
degradation, observability, and post-release validation.

Data changes must include migration, idempotency, retry or resume behavior,
validation, and rollback or compensation.

Security-sensitive work must include permission boundaries, sensitive-data
handling, abuse cases, audit logging, and security review.

## Existing Plan Review Contract

When reviewing an existing plan, the skill must lead with findings and check
for missing problem definition, measurable goals, non-goals, phase gates,
rollback, observability, data safeguards, security review, and unsupported
project facts.
