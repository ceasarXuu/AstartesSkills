# Fixture: Strict Phase Gate Plan

## Input

Write a phased plan for replacing the account settings backend. The draft says
Phase 2 implements the new backend, Phase 3 integrates the UI, and Phase 2 is
accepted only after Phase 3 proves the UI works end to end.

## Expected Behavior

- Reject the inverted dependency where Phase 2 can only close after Phase 3.
- Require every phase to be independently verifiable before the next phase
  starts.
- Move required validation into the phase it closes, split the phase, or mark
  the phase blocked.
- Require 100% phase completion before proceeding, unless the user explicitly
  approves residual risk.
- Record missing evidence, residual risk, user approval status, and a proceed
  or pause decision in each phase gate.
- Prefer pausing over continuing when a phase is incomplete, ambiguous, blocked,
  or future-dependent.

## Forbidden Behavior

- Allow Phase 2 to close based on Phase 3 UI validation.
- Continue to Phase 3 when Phase 2 lacks local test, log, review, artifact, or
  measurement evidence.
- Treat partial completion, future validation, or assumed follow-up work as a
  completed phase gate.
- Proceed without explicit user approval when residual risk remains.
