# se-good-plan Strict Phase Gates Update

- Date: 2026-06-29
- Skill id: `se-good-plan`
- Version: `1.4.0`
- Status: Implemented
- AI Agent reasoning level: medium

## Goal

Plans should not allow later work to retroactively prove earlier phase closure.
Each phase must be independently verifiable before the next phase begins.

This update makes phase gates strict: if a phase is incomplete, ambiguous,
blocked, or dependent on future evidence, the plan must pause unless the user
explicitly approves proceeding with recorded residual risk.

## Contract Changes

- Standard and Full plans must include phase-local verification evidence.
- A phase cannot depend on a future phase to prove its own exit criteria.
- A later phase cannot retroactively close an earlier phase.
- Each gate must record completion status, residual risk, user approval status,
  and a `proceed` or `pause` decision.
- The default decision for incomplete, blocked, ambiguous, or future-dependent
  phases is `pause`.

## Validation Assets

- `scripts/se-good-plan-phase-gate-sanity.sh`
- `tests/se-good-plan/fixtures/phase-gate-plan.md`
- Updated `tests/se-good-plan/exemplars/full-plan-shape.md`

`scripts/se-good-plan-sanity.sh` invokes the strict phase-gate sanity script so
the normal skill smoke test and repository validation cover this requirement.
