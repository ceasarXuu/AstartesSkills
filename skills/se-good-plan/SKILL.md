---
name: se-good-plan
description: Use when the user asks for a software engineering plan, implementation plan, refactor plan, migration plan, rollout plan, bug-fix plan, performance optimization plan, security change plan, DevOps / CI/CD plan, technical execution plan, or review of an existing engineering plan. Produces phased, executable, verifiable, reviewable, rollback-aware plans for software engineering work.
---

# SE Good Plan

## Purpose

Use this skill to write or review software engineering plans that are practical
for engineers, reviewable by technical leads, and understandable to
stakeholders.

A good plan is not a generic TODO list or a high-level roadmap. It must explain
what to do, why it should be done that way, how to prove it worked, what can go
wrong, and how to recover.

## Use This Skill When

- The user asks for an engineering plan, implementation plan, rollout plan,
  migration plan, refactor plan, bug-fix plan, or technical execution plan.
- The user asks for a performance optimization, security change, DevOps, CI/CD,
  data migration, architecture migration, or release plan.
- The user asks to split software work into phases.
- The user asks to make a plan more executable, reviewable, or engineering-grade.
- The user asks whether an existing software engineering plan is complete,
  risky, or ready for review.

Do not use this skill for pure product requirement clarification unless the
request is to convert requirements into engineering execution. Do not over-plan
tiny, low-risk edits.

## Core Rules

- Start from the problem definition, not from implementation steps.
- Separate facts, assumptions, constraints, risks, and open questions.
- Do not invent project-specific facts such as architecture, databases,
  services, traffic, deployment model, or business rules.
- Do not invent schedules, staffing, resource commitments, deadlines, launch
  dates, or maintenance windows. If they are not provided, keep them unknown or
  list them as assumptions to confirm.
- If context is missing, keep moving by adding a Discovery phase, assumptions,
  and Open Questions instead of pretending certainty.
- Choose plan depth from task complexity and risk.
- Break medium and high-risk work into progressive phases.
- Each phase must include entry criteria, checks, tasks, deliverables,
  validation, exit criteria, review plan, risks, fallback, and next-phase gate.
- Move high-risk and high-uncertainty validation earlier.
- Production-impacting work must include release, rollback, fallback or
  degradation, observability, and post-release validation.
- Data changes must include migration, idempotency, retry or resume behavior,
  validation, and rollback or compensation.
- Security-sensitive work must include permission boundaries, sensitive-data
  handling, abuse cases, audit logging, and security review.
- Use measurable acceptance criteria. Avoid vague promises like "optimize",
  "improve", "support", "handle", or "complete" unless they are made specific.

## Generation Workflow

### 1. Classify The Task

Classify the request before writing the plan:

- feature development
- bug fix
- refactor
- migration
- data migration
- architecture change
- performance optimization
- security change
- DevOps / CI/CD
- release / rollout
- other software engineering work

For task-specific requirements and phase patterns, read
`references/plan-patterns.md` when the task maps to one of those types.

### 2. Assess Complexity And Risk

Use this scale:

| Level | Typical signals |
| --- | --- |
| Low | single module, no production data, easy rollback, limited user impact |
| Medium | multiple modules, API/config/deployment changes, controlled production risk |
| High | multiple services, data migration, core workflows, difficult rollback |
| Critical | core business path, irreversible data, security/auth/payment/finance, many teams |

Use this proportionality guide unless the request provides stronger constraints:

| Complexity | Plan depth | Typical phase count |
| --- | --- | ---: |
| Low | Lightweight | 2-3 |
| Medium | Standard | 4-5 |
| High | Full | 6-8 |
| Critical | Full with stronger review gates | 7-10 |

Force a `Full Plan` when any of these are true:

- production data migration
- authentication, authorization, permission, or sensitive-data boundary change
- payment, billing, accounting, order, asset, or core business workflow change
- core API compatibility risk
- large user-visible rollout
- irreversible or hard-to-rollback change
- cross-system architecture migration
- high availability, disaster recovery, or high-concurrency requirement
- external dependency replacement

### 3. Choose Output Depth

Use `Lightweight Plan` for low-risk, narrow work. Include:

- Background
- Goals
- Non-goals
- Implementation steps
- Acceptance criteria
- Test plan
- Risks and rollback

Use `Standard Plan` for ordinary engineering work with multiple moving parts.
Include:

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

Use `Full Plan` for high-risk, production-impacting, data-impacting,
security-impacting, or architecture-impacting work. Add:

- Complexity And Risk Assessment
- Alternatives And Tradeoffs
- Phase Gate Overview
- Data Migration Strategy
- API / Compatibility Strategy
- Security And Permission Review
- Post-release Verification And Cleanup
- Decision Log

All Standard and Full plans must include this metadata contract unless the user
requests a shorter inline answer:

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

Use this dependency table in Standard and Full plans when any dependency exists
or must be discovered:

```markdown
| Dependency | Type | Current Status | Blocking Risk | Handling Plan |
|---|---|---|---|---|
| ... | system / person / data / environment / third-party | Ready / Pending / Unknown | ... | ... |
```

If the dependency state is unknown, do not omit it. Mark it `Unknown` and tie it
to a phase gate or open question.

### 4. Extract Context Honestly

Before writing the plan, identify what the user already provided:

- project or system
- current problem
- target outcome
- non-goals or constraints
- current system state
- affected modules, APIs, data, dependencies, environments, or users
- production impact
- deadline, rollout, compliance, or review requirements

If important information is missing, list it under `Open Questions`. If a
temporary assumption helps planning, put it in an assumptions table:

```markdown
| Assumption | Verification Method | If Assumption Fails |
|---|---|---|
| ... | ... | ... |
```

If missing context blocks detailed planning, make `Phase 0: Discovery` the
first phase and define exactly what evidence must be collected.

### 5. Define The Problem And Goals

The problem definition must distinguish:

- current behavior
- expected behavior
- gap
- affected users, modules, data, APIs, and deployment surfaces

Goals must be testable. Non-goals must control scope. If a phrase is vague,
rewrite it with a metric, scenario, artifact, or acceptance criterion.

### 6. Build The Phased Plan

For every Standard or Full Plan, each phase must use this schema:

```markdown
### Phase <N>: <Name>

#### Objective
#### Entry Criteria
#### Entry Criteria Checks
| Entry Criterion | Check Method | Evidence / Output | Owner |
|---|---|---|---|
#### Design Approach
#### Implementation Tasks
#### Deliverables
#### Testing And Validation
| Validation Item | Method | Passing Standard |
|---|---|---|
#### Exit Criteria
#### Review Plan
#### Risks And Fallback
| Risk | Impact | Trigger Signal | Mitigation | Fallback |
|---|---|---|---|---|
#### Gate To Next Phase
```

Common phases are Discovery, Design, Foundation, Implementation, Integration,
Validation, Release, and Post-release Cleanup. Merge phases for simple work,
but do not skip Discovery, Validation, Release, or Rollback for high-risk work.

### 7. Add Review And Evidence Gates

Every phase gate must state what evidence proves the phase can close:

- required tests and exact pass criteria
- required code, design, security, release, or data review
- unresolved P0/P1 issues
- risk mitigations and fallback readiness
- artifacts to archive, such as scripts, dashboards, runbooks, or review notes

For production-impacting work, also require rollback rehearsal or rollback
verification, monitoring and alerting, feature flag readiness when applicable,
and post-release observation windows.

### 8. Review Existing Plans

When reviewing an existing plan, lead with findings:

- missing or weak problem definition
- goals that cannot be measured
- missing non-goals or scope controls
- phases without gates or evidence
- risks without triggers or fallback
- production changes without rollout, rollback, or observability
- data changes without idempotency, validation, or compensation
- security changes without permission, audit, or abuse-case review
- invented or unsupported project facts

Then provide a compact corrected outline or rewritten plan section if useful.

## Output Quality Checklist

Before final output, verify:

- [ ] Background and problem definition are clear.
- [ ] Goals are measurable and non-goals control scope.
- [ ] Facts, assumptions, constraints, risks, and open questions are separated.
- [ ] Complexity and plan depth are justified.
- [ ] Work is divided into progressive phases.
- [ ] Each phase has entry criteria, checks, tasks, deliverables, validation,
      exit criteria, review plan, risks, fallback, and next gate.
- [ ] High-risk unknowns are investigated early.
- [ ] Risks include trigger signals and mitigations.
- [ ] Tests and validation have passing standards.
- [ ] Production impact includes release, rollback, fallback, observability,
      and post-release validation.
- [ ] Data impact includes migration, idempotency, retry/resume, validation,
      and compensation or rollback.
- [ ] Security impact includes permission boundaries, sensitive-data handling,
      abuse cases, audit logging, and security review.
- [ ] The plan does not invent repository or system facts.
