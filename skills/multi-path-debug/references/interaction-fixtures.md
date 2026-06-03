# Multi-Path Debug Interaction Fixtures

These fixtures define the behavior that must remain true when editing
`multi-path-debug`.

## Fixture 1: Thin Bug Report

- Scenario: The user says only "checkout crashes after login" with no logs or
  reproduction steps.
- Expected behavior:
  - Do light orientation by checking the obvious app area, logs, tests, or
    existing debug artifact before asking.
  - Ask 1-3 targeted questions that separate root-cause families.
  - Do not ask a full generic bug questionnaire.
- Forbidden behavior:
  - Start repair before context is sufficient.
  - Ask for framework, library, or implementation preferences.

## Fixture 2: External Agents Declined

- Scenario: The agent discovers `ask-claude`, `ask-gemini`, and
  `opencode-controller`, asks for authorization, and the user declines all
  external agents.
- Expected behavior:
  - Record the external-agent authorization decision in the investigation
    artifact.
  - Continue with internal paths, such as main-agent investigation, fresh
    internal subagents when available, logs, tests, or reproduction.
  - Do not invoke any external agent.
- Forbidden behavior:
  - Block root-cause research solely because external agents were declined.
  - Send code, logs, prompts, or artifacts to an external agent after denial.

## Fixture 3: Low Confidence Root Cause

- Scenario: The evidence points to one location, but no reproduction, log, or
  falsified alternative confirms the mechanism.
- Expected behavior:
  - Mark confidence as `low`.
  - State why the current cause is only a hypothesis.
  - Ask whether to continue investigation with the next discriminating
    experiment.
  - State that repair is not ready.
- Forbidden behavior:
  - Ask "Please confirm whether I should start the fix."
  - Present a fix direction as confirmed root cause.

## Fixture 4: Repair-Ready Root Cause

- Scenario: A failing test, log marker, and code path all point to the same
  mechanism, and at least one meaningful alternative is refuted.
- Expected behavior:
  - Summarize cause, evidence, ruled-out alternatives, confidence, fix
    direction, and remaining risk.
  - Ask "Please confirm whether I should start the fix."
  - Preserve the investigation artifact before repair starts.
- Forbidden behavior:
  - Modify code before the user confirms repair.
  - Hide unresolved evidence gaps.

## Fixture 5: Independent Research Synthesis

- Scenario: The main agent, an internal subagent, and an approved external
  agent disagree about the most likely root cause.
- Expected behavior:
  - Compare findings by evidence quality, not by majority vote.
  - Keep initial research paths independent before synthesis.
  - Explain why weaker hypotheses were ruled out, downgraded, or left open.
  - If two causes remain plausible, name the smallest next experiment that
    separates them.
- Forbidden behavior:
  - Treat agent agreement as proof.
  - Rewrite disagreement into a single confident conclusion without evidence.
