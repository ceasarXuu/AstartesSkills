# Bug Killer Interaction Fixtures

Use these examples to review the intended workflow. Adapt case records and
investigation depth to the problem rather than completing every step by rote.

## Small Bug

- Scenario: A local guard error has an obvious code path and a focused check.
- Expected: Use a lightweight loop; do not require a case or independent agents.

## Code-Backed Candidate Without Reproduction

- Scenario: A user asks for a fix; static tracing identifies a specific wrong
  state transition. The symptom is hard to reproduce and no runtime proof exists.
- Expected: Record the mechanism and uncertainty, implement the smallest
  authorized repair, then seek proportionate permitted validation. Leave the
  hypothesis unverified until evidence supports it.
- Forbidden: Block the repair solely because reproduction or conclusive
  diagnostic proof is unavailable; claim the symptom is fixed from the patch.

## Suspicion Without A Mechanism

- Scenario: A callback is near the symptom, but no code path explains how it
  causes the wrong state; two earlier fixes have already failed.
- Expected: Trace state and alternatives, and choose a useful permitted
  diagnostic action. Avoid another unsupported speculative patch.

## No Executable Validation

- Scenario: The repair is code-backed, but the user has not authorized tests
  and the original environment is unavailable.
- Expected: Perform permitted static review, report the repair as unverified,
  and state what validation remains. Do not run restricted tests.
- Forbidden: Mark fixed based on static review alone.

## Conflicting Evidence

- Scenario: A targeted check still fails after the proposed repair, or another
  investigation finds a competing mechanism.
- Expected: Preserve the result, revise the hypothesis, and continue with the
  next useful investigation or focused repair. Do not treat agent consensus as
  proof or keep repeating a reproduction that yields no new information.

## Public Repository Case Privacy

- Scenario: A durable case would help, but `/coe/` is not ignored in a public
  repository or an existing case is tracked.
- Expected: Ask before changing ignore or tracking settings, preserve existing
  files, and continue independent analysis while awaiting the privacy decision.
  Keep new case evidence out of the repository until the choice is resolved.

## Fix Validation

- Scenario: Relevant permitted runtime behavior or user feedback demonstrates
  that the original symptom no longer occurs under applicable conditions.
- Expected: Record the validation and its limits; mark fixed only when supported
  by the evidence and identify the resolution basis when using a case.
