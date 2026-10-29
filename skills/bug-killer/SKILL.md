---
name: bug-killer
description: Investigate complex or recurring bugs with agile code-first reasoning, small repairs, proportionate validation, and lightweight evidence tracking.
---

# Bug Killer

Use this workflow for bugs that are complex, cross-layer, intermittent,
repeatedly unresolved, or consequential enough to benefit from persistent
investigation. For an obvious, local bug, use a lightweight debug loop unless
the user explicitly requests Bug Killer.

Work in short iterations: understand enough to take the next useful action,
make a focused change, check the result, and adjust. Scale documentation,
parallel investigation, and diagnostics to the problem; none is a ceremony
that must be completed before useful work can proceed.

## Principles

- Start with the report, available context, and static reasoning over the
  relevant code paths, state transitions, inputs, and recent changes. Identify
  concrete suspicious mechanisms and how each could produce the symptom.
- When the code provides a credible, specific candidate and the change is
  within the user's authorization, make the smallest focused repair and
  validate it promptly. A hypothesis need not be confirmed before repair;
  code proximity or intuition alone is not a sufficient mechanism.
- Do not require reproduction before investigation or repair. When a project
  requires code analysis before reproduction, follow that ordering. If
  reproduction is difficult, unavailable, or unproductive, use code analysis,
  existing logs, targeted checks, runtime evidence, or user feedback to advance.
- Keep hypotheses and confidence honest: a plausible code path or a patch alone
  does not prove the root cause or that the issue is fixed. Record supporting,
  contradictory, and missing evidence, and continue investigating when a repair
  is disproved or validation is inconclusive.
- Respect the user's and project's permissions, test restrictions, privacy and
  safety requirements. Avoid destructive experiments and speculative changes to
  data, permissions, or core product behavior. Obtain required authorization
  before the affected action; do not add a separate approval gate when repair
  is already authorized.
- Use independent investigation paths where useful and available, especially
  after a failed repair or when multiple mechanisms remain plausible. Do not
  delay a well-supported, low-risk repair just to complete parallel work.
- Mark a problem fixed only when relevant validation supports the original
  symptom no longer occurring. If verification is unavailable or not permitted,
  describe the change as unverified and state the remaining risk.

## Case Artifact

For complex, ongoing, or handoff-sensitive repository investigations, reuse or
create a project-root `/coe` case file when durable tracking adds value:

```text
/coe/YYYY-MM-DD-HH-mm-<short-bug-title>.md
```

Before creating or appending a case, determine repository visibility from the
hosting provider when available. Do not assume a local checkout is private.
For a public repository, check whether root `/coe/` is ignored and whether any
case files are tracked. If `/coe/` is not ignored, ask whether to add it to
`.gitignore`; never change `.gitignore` or Git tracking without confirmation.
If case files are already tracked, explain that ignore rules do not protect
tracked files and ask before untracking them while preserving local copies.
Resolve this choice before persisting new case evidence. If the user chooses to
keep cases tracked, minimize sensitive detail. If visibility is unknown, ask
whether the repository is public before persisting a case. Continue independent
code analysis while a privacy decision is pending; do not write case evidence
until it is resolved.

For a short investigation, keep only the necessary hypothesis, action, and
validation notes in the response; do not create a case just to satisfy a ritual.
When a case is useful, use `templates/case-template.md` proportionately and
leave unknown or irrelevant fields brief. Case files contain only `Problem`,
`Hypothesis`, and `Evidence` nodes. Keep existing observations; append
corrections instead of deleting or renumbering evidence.

- `Problem`: symptoms, expected and actual behavior, impact, trigger or known
  reproduction path, environment, fix criteria, and current conclusion.
- `Hypothesis`: a specific possible mechanism, its code-based rationale,
  predictions, relevant alternatives, and the next repair or diagnostic step.
- `Evidence`: a concrete code path, log, configuration, observation, repair
  validation, test result, or feedback, linked to the hypothesis it affects.

## Workflow

### 1. Orient And Trace Code

Gather the available symptom, expected behavior, environment, trigger, recent
changes, and relevant logs or traces. Inspect the relevant code and data flow
first; trace how an input or state transition can lead to the observed result.
If context is insufficient, obtain logs or ask focused questions while pursuing
independent analysis. Do not require a reproduction attempt when a candidate can
be found by static analysis, or when a higher-priority instruction forbids it.

### 2. Choose A Candidate And Act

Record the strongest candidate as an unconfirmed `Hypothesis`: identify the
specific code path, mechanism, supporting facts, assumptions, and what would
count against it. Consider meaningful alternatives, especially after prior failed
fixes. For a concrete code-backed candidate, choose a minimal change that
addresses the mechanism and a proportionate way to validate it; implement and
validate without waiting for reproduction or conclusive diagnostic proof when
permitted. Do not claim the candidate confirmed merely because it looks plausible.

When no candidate has a concrete mechanism, or the proposed change carries
significant irreversible risk, continue with the smallest permitted diagnostic
step. A reproduction, log, probe, configuration check, targeted experiment, or
operator feedback may help distinguish candidates; choose based on usefulness,
not a mandatory sequence. Respect any required authorization for tests and other
actions. Avoid repeated or elaborate reproduction attempts that are not adding
information.

### 3. Validate, Learn, And Iterate

Check the changed behavior against the original symptom and affected paths using
the strongest practical permitted evidence: original conditions when available,
a targeted regression check, runtime observation, or user feedback. Review the
code and surrounding invariants when execution is unavailable, but do not claim
that static review alone proves the symptom is gone. Record what was checked,
the result, limits, and the evidence linked to the hypothesis.

If the issue persists, revise or refute the hypothesis and investigate other
paths. Use independent code, log, runtime, or configuration evidence where it
helps; compare evidence quality rather than agent agreement. Keep diagnostic-only
instrumentation identifiable, and remove or retain it deliberately.

Set a hypothesis to `confirmed` only when evidence supports its mechanism and
separates meaningful alternatives; a repair may be implemented while it is still
`unverified`. Set `Problem P-001` to `fixed` only when relevant fix-validation
evidence supports resolution and the resolution basis identifies the hypothesis
and evidence. Otherwise report the repair as unverified or still open, including
what remains to be checked.

## Response Behavior

State the code-backed candidate, next action, and relevant uncertainty concisely.
After a change, explain what was changed, what validation actually ran, and any
remaining risk. Do not claim a fix from a code change or an unrelated check.

## Fixtures

Read `references/interaction-fixtures.md` when modifying or auditing this skill.
