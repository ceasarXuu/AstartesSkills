# Example Critical API Migration Full Plan

- Created: 2026-06-04
- Updated: 2026-06-04
- Version: v0.1
- Status: Draft
- Owner / Responsible: Unknown
- Related Systems: Unknown
- Related Links: Unknown
- Risk Level: Critical
- Plan Type: Full

## Background

The current API migration request affects a critical path, so the plan must be
phased and review-gated.

## Problem Definition

### Current Behavior

- Unknown until Discovery.

### Expected Behavior

- Unknown until Discovery.

### Gap

- Unknown until Discovery.

## Goals

- [ ] Establish current-state evidence before implementation.

## Non-goals

- This plan does not invent launch dates, staffing, or system facts.

## Constraints And Assumptions

| Assumption | Verification Method | If Assumption Fails |
|---|---|---|
| The API is production-facing. | Confirm routing and traffic. | Downgrade risk if false. |

## Current State

- Unknown until Discovery.

## Complexity And Risk Assessment

| Dimension | Level | Evidence |
|---|---|---|
| API compatibility | Critical | User stated API migration. |

## Plan Summary

| Item | Content |
|---|---|
| Plan Type | Full |
| Risk Level | Critical |

## Overall Technical Design

- Define target API behavior only after Discovery.

## Alternatives And Tradeoffs

| Alternative | Pros | Cons | Decision |
|---|---|---|---|
| Compatibility layer | Safer rollout | More temporary code | Pending |

## Phased Execution Plan

### Phase 0: Discovery

#### Objective

- Collect current architecture, API, traffic, owner, and rollback evidence.

#### Entry Criteria

- [ ] Request accepted for planning.

#### Entry Criteria Checks

| Entry Criterion | Check Method | Evidence / Output | Owner |
|---|---|---|---|
| Repository access exists | Inspect repo | Module map | Unknown |

#### Design Approach

- No implementation until current behavior is documented.

#### Implementation Tasks

- [ ] Map current API callers.

#### Deliverables

- API inventory.

#### Testing And Validation

| Validation Item | Method | Passing Standard |
|---|---|---|
| Caller inventory | Static and log review | All known callers listed |

#### Exit Criteria

- [ ] Current API behavior is documented.

#### Review Plan

- Design review before Phase 1.

#### Risks And Fallback

| Risk | Impact | Trigger Signal | Mitigation | Fallback |
|---|---|---|---|---|
| Unknown caller | API breakage | New caller in logs | Extend inventory | Pause migration |

#### Gate To Next Phase

- [ ] Discovery evidence is reviewed.

## Phase Gate Overview

| Phase | Gate |
|---|---|
| Phase 0 | Discovery evidence reviewed |

## Dependencies

| Dependency | Type | Current Status | Blocking Risk | Handling Plan |
|---|---|---|---|---|
| API owner | person | Unknown | Approval blocked | Confirm in Phase 0 |

## Risks, Dependencies, And Mitigations

| Risk | Probability | Impact | Trigger Signal | Mitigation | Fallback |
|---|---:|---:|---|---|---|
| API incompatibility | Medium | High | Contract test failure | Compatibility layer | Keep old endpoint |

## Data Migration Strategy

- Not applicable unless Discovery finds data movement.

## API / Compatibility Strategy

- Preserve old API until compatibility tests and canary pass.

## Testing And Validation Strategy

| Test Type | Scope | Execution Method | Passing Standard |
|---|---|---|---|
| Contract | API clients | Automated contract tests | No breaking changes |

## Security And Permission Review

- Confirm auth and authorization behavior before launch.

## Release, Rollback, And Fallback Strategy

### Release Strategy

- Canary behind a feature flag if available.

### Rollback Strategy

- Route traffic back to old API.

### Fallback / Degradation Strategy

- Keep old endpoint available.

## Observability And Success Metrics

| Metric | Current Baseline | Target | Alert Threshold | Observation Window |
|---|---:|---:|---:|---|
| Error rate | Unknown | Not above baseline | Baseline + threshold | 24h |

## Post-release Verification And Cleanup

- Remove old API only after observation and caller migration evidence.

## Open Questions

| Question | Impact | Needs Confirmation From | Blocking Phase | Handling |
|---|---|---|---|---|
| Who owns rollout approval? | Release gate | Stakeholder | Phase 0 | Confirm owner |

## Decision Log

| Time | Decision | Reason | Alternatives | Impact |
|---|---|---|---|---|
| 2026-06-04 | Draft only | Missing context | Direct implementation | Safer planning |

## Change Log

| Version | Time | Change | Author |
|---|---|---|---|
| v0.1 | 2026-06-04 | Initial exemplar | se-good-plan |

## Plan Quality Checklist

- [ ] No invented schedule, staffing, or launch date.
- [ ] Phase gates include evidence.
