# se-good-plan Logging Design Update

- Date: 2026-06-25
- Skill id: `se-good-plan`
- Version: `1.3.0`
- Status: Implemented
- AI Agent reasoning level: medium

## Goal

Plans should not only say which tests will pass. They should also define how
operators and maintainers can observe the affected change chain while the plan
is executed and after it ships.

This update makes logging design a first-class plan requirement. A plan must
show the critical states in the changed flow and how logs, traces, metrics, or
audit events reveal success, failure, ambiguity, and failure reasons.

## Contract Changes

- Runtime, release, data, job, API, user-workflow, and operator-procedure
  changes must include a chain-state logging design.
- Logging design must cover key states, success signals, failure signals,
  structured failure reason fields, correlation or trace fields, log levels, and
  consumers.
- Phase schemas now include `Logging And Observability Design`.
- Validation gates must prove the planned telemetry can show success, failure,
  ambiguity, and failure reason.
- Sensitive data, high-cardinality, sampling, retention, dashboard, alert, and
  runbook guardrails are explicitly documented.

## Validation Assets

- `scripts/se-good-plan-observability-sanity.sh`
- `tests/se-good-plan/fixtures/logging-design-plan.md`
- Updated `tests/se-good-plan/fixtures/performance-plan.md`
- Updated `tests/se-good-plan/fixtures/devops-cicd-plan.md`
- Updated `tests/se-good-plan/exemplars/full-plan-shape.md`

`scripts/se-good-plan-sanity.sh` invokes the observability sanity script so the
normal skill smoke test and repository validation cover this requirement.
