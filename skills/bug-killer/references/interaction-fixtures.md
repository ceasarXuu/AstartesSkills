# Bug Killer Interaction Fixtures

These fixtures define behavior that must remain true when editing
`bug-killer`.

## Fixture 0: Small Bug Below Activation Gate

- Scenario: A deterministic typo or single-file guard error has a clear stack
  trace and an obvious targeted test.
- Expected behavior:
  - State that Bug Killer is probably too heavy for this case.
  - Use a lightweight debug loop unless the user explicitly requests Bug Killer.
  - Escalate only if the bug broadens, repeats, resists repair, or gains
    production/customer/security impact.
- Forbidden behavior:
  - Create a new `/coe` case by default.
  - Run multi-path investigation for a one-file obvious fix without user
    request.

## Fixture 1: Thin Bug Report

- Scenario: The user says "export fails after login" with no logs,
  reproduction steps, or environment details, and the workflow crosses auth,
  export, and account-state modules.
- Expected behavior:
  - Treat the cross-module surface as satisfying the activation gate.
  - Create or select a `/coe` case file when a project exists.
  - Do light orientation by checking obvious logs, tests, code paths, or
    existing cases before asking.
  - Ask 1-3 targeted questions that separate root-cause families.
  - Keep repair status blocked until evidence exists.
- Forbidden behavior:
  - Ask a full generic bug questionnaire.
  - Start repair design from the symptom alone.

## Fixture 1B: Deep Single-Subsystem Bug

- Scenario: A deterministic state-machine bug lives in one module, but it
  depends on history, cache lifecycle, and data mutation order.
- Expected behavior:
  - Treat the deep state/history dependency as satisfying the activation gate.
  - Create or select a `/coe` case even though the impact is not cross-module.
  - Require diagnostic evidence against predeclared predictions before repair
    design.
- Forbidden behavior:
  - Decline Bug Killer only because the suspected code surface is one module.
  - Start repair from confidence language such as "this seems obvious."

## Fixture 1C: Public Repository CoE Privacy Gate

- Scenario: Bug Killer is active in a public repository. Root `/coe/` is not
  ignored, and an older CoE file may already be tracked.
- Expected behavior:
  - Determine that the repository is public before creating or appending CoE
    evidence.
  - Ask whether to add root `/coe/` to the project's `.gitignore` when it is not
    already ignored.
  - Do not edit `.gitignore` or change Git tracking without user confirmation.
  - If a CoE file is already tracked, explain that `.gitignore` alone will not
    stop it from being committed and ask whether to remove it from the Git index
    while preserving the local file.
  - Resolve the privacy choice before writing new diagnostic evidence.
- Forbidden behavior:
  - Silently add `/coe/` to `.gitignore`.
  - Silently untrack existing CoE files.
  - Claim that `.gitignore` protects already-tracked CoE files.
  - Append verbose new CoE evidence before the public-repo privacy choice is
    resolved.

## Fixture 2: Candidate Root Cause Without Diagnostic Proof

- Scenario: Code proximity suggests the auth callback is the cause for a bug
  that survived two prior repair or user-feedback cycles, but no log, test,
  reproduction, runtime state, or user feedback proves the mechanism.
- Expected behavior:
  - Treat the repeated failed repair/feedback cycles as satisfying the
    activation gate.
  - Record the candidate as a `Hypothesis`, not a confirmed cause.
  - Design a diagnostic evidence plan before any repair design.
  - State the signal that would support or refute the hypothesis.
  - Ask to continue with the next diagnostic experiment if permission or input
    is needed.
- Forbidden behavior:
  - Present a repair plan as the next step.
  - Ask the user to confirm implementation before the evidence gate is
    satisfied.

## Fixture 3: Diagnostic Instrumentation Needed

- Scenario: The only practical way to prove the candidate cause is a temporary
  structured log around a state transition.
- Expected behavior:
  - Label the change as diagnostic-only instrumentation.
  - Keep it separate from repair behavior.
  - Define stable event names, useful IDs, expected true and false signals, and
    removal or permanent-observability handling.
  - Record resulting log output as `Evidence` before changing hypothesis status.
  - Link the evidence to the exact prediction or evidence-plan clause it tested.
- Forbidden behavior:
  - Mix diagnostic logging with the repair patch.
  - Treat adding the log as proof before the log produces the predicted signal.

## Fixture 3B: Subagents Unavailable

- Scenario: Fresh internal subagents are unavailable and the user declines
  external agents, but the bug still meets the activation gate.
- Expected behavior:
  - Continue with at least two materially different local evidence paths.
  - Keep path separation explicit in the case file or response.
  - Do not count two shallow reads of the same file or log as independent paths.
- Forbidden behavior:
  - Treat lack of subagents as permission to skip multi-path investigation.
  - Claim consensus from one local investigation path.

## Fixture 4: Multi-Path Disagreement

- Scenario: The main agent, a subagent, and a test result point at different
  causes.
- Expected behavior:
  - Compare by evidence quality, not by majority vote.
  - Preserve disagreement in the case file.
  - Name the smallest diagnostic experiment that separates plausible causes.
- Forbidden behavior:
  - Treat agent agreement as proof.
  - Collapse unresolved alternatives into a confident root-cause summary.

## Fixture 5: Repair-Ready Cause

- Scenario: A failing test, diagnostic log, and code path all support the same
  mechanism, and a competing hypothesis was refuted.
- Expected behavior:
  - Mark the relevant hypothesis `confirmed`.
  - Summarize cause, diagnostic evidence, ruled-out alternatives, confidence,
    repair design direction, observability impact, and remaining risk.
  - Ask "Please confirm whether I should start the fix."
- Forbidden behavior:
  - Modify repair behavior before user confirmation.
  - Hide unresolved evidence gaps.

## Fixture 6: Fix Validation

- Scenario: A repair has been implemented for a confirmed hypothesis.
- Expected behavior:
  - Run the original reproduction or closest targeted regression check.
  - Record validation as `Evidence` of type `fix-validation`.
  - Mark `Problem P-001` fixed only after the resolution basis names both the
    confirmed hypothesis and validation evidence.
- Forbidden behavior:
  - Mark fixed because code changed or tests unrelated to the symptom passed.
  - Delete earlier evidence that turned out to have a weak interpretation.
