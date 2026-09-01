---
name: bug-killer
description: Use when debugging medium or large bugs, regressions, flaky failures, production symptoms, repeated failed fixes, or user-explicit requests where the agent must combine persistent /coe case tracking, independent multi-path root-cause investigation, and a hard diagnostic evidence gate before repair design or implementation.
---

# Bug Killer

Bug Killer is a heavy debugging process. Use it only when a bug is large enough
that lightweight debugging is likely to become self-deceptive or wasteful. It is
especially important for multi-layer bugs, intermittent symptoms, production
incidents, repeated failed fixes, unclear ownership, or any case where the first
plausible cause may be wrong.

Bug Killer fuses three ideas:

1. Chain-of-evidence case files keep one durable source of truth.
2. Multi-path investigation produces independent root-cause candidates.
3. Candidate causes must be proven by diagnostic logs, probes, experiments,
   tests, runtime observations, or user feedback before repair design begins.

## Activation Gate

Do not use this skill for every bug. Run a lightweight debug path instead when
the symptom is deterministic, local to one obvious file, backed by a clear stack
trace or failing test, and repair can be validated directly.

Use Bug Killer when any of these conditions is true:

- the user explicitly asks for `bug-killer`, heavy debug, evidence-gated debug,
  `/coe`, multi-path root-cause analysis, or repair only after proof,
- the suspected impact crosses two or more modules, services, platforms, data
  flows, devices, accounts, or ownership boundaries,
- at least two repair attempts, hotfixes, or user-feedback cycles have failed to
  resolve the same symptom,
- the bug affects production, customer-visible workflows, data correctness,
  security, permissions, billing, deployment, release, or operational recovery,
- the symptom is intermittent, flaky, timing-sensitive, environment-specific, or
  cannot be reproduced locally,
- the bug is deterministic but hidden in a deep state machine, data mutation
  path, cache lifecycle, concurrency path, or history-dependent flow,
- there are two or more plausible root-cause families after light orientation,
- the likely fix could create broad regressions or requires diagnostic
  instrumentation before it can be trusted.

If the activation gate is not met, state that Bug Killer is probably too heavy,
use a smaller debug loop, and escalate into Bug Killer only if the bug broadens,
repeats, resists repair, or the user explicitly requests it.

## Non-Negotiable Rules

- Check the activation gate before creating a new `/coe` case. If the user
  explicitly requested Bug Killer, the gate is satisfied.
- Maintain a project-root `/coe` case file as the investigation source of
  truth whenever the task touches a repository.
- Before creating or appending `/coe` in a public repository, resolve the CoE
  privacy gate below. Never silently change `.gitignore` or Git tracking.
- Case files may contain only `Problem`, `Hypothesis`, and `Evidence` nodes.
- Root-cause candidates are hypotheses, not repair plans.
- Repair design is forbidden until the candidate root cause passes the
  diagnostic evidence gate.
- The diagnostic evidence gate requires a planned signal and actual evidence:
  log, probe, reproduction, test, telemetry, runtime state, config fact, or
  user-feedback loop that supports the causal mechanism.
- If instrumentation is needed, make a diagnostic-only change first. Do not
  mix diagnostic instrumentation with the repair.
- Compare findings by evidence quality, not by majority vote or agent agreement.
- If confidence is low, ask for the next diagnostic experiment instead of
  asking to fix.
- Ask the user to confirm before starting repair implementation unless the user
  has already explicitly authorized repair after evidence-backed confirmation.
- Mark the problem fixed only after fix-validation evidence shows the original
  symptom no longer occurs.

## Case Artifact

Create or update one Markdown file under the project root:

```text
/coe/YYYY-MM-DD-HH-mm-<short-bug-title>.md
```

Before creating a new case or appending evidence, determine repository visibility
from the hosting provider when available. Do not assume a local checkout is
private.

For a public repository:

- check whether root `/coe/` is ignored and whether any `/coe` files are already
  tracked,
- if `/coe/` is not ignored, ask the user whether to add `/coe/` to the project's
  `.gitignore` so case files stay local; do not edit `.gitignore` without user
  confirmation,
- if any `/coe` files are already tracked, explain that `.gitignore` does not
  stop tracked files from being committed and ask whether to remove them from
  the Git index while preserving local copies; do not untrack them without user
  confirmation,
- resolve this privacy choice before writing new diagnostic evidence. If the
  user explicitly chooses to keep CoE tracked, minimize unnecessary sensitive
  debug detail and continue with that choice.

If repository visibility cannot be determined, ask whether the repository is
public before persisting a new CoE case.

If no repository is available, keep the same logical structure in the response
and create the file once a writable project exists.

Use `templates/case-template.md` for new files. The case file is append-friendly:
do not delete evidence or renumber IDs. If an interpretation changes, add new
evidence or update the related hypothesis conclusion.

## Node Model

`Problem`
: The single root issue being solved. It records symptoms, expected behavior,
  actual behavior, impact, reproduction, environment, known facts, ruled-out
  directions, fix criteria, and the current conclusion.

`Hypothesis`
: A falsifiable claim about the root cause, sub-cause, regression window,
  environment, interaction, diagnostic path, or fix validation. Each hypothesis
  must name its predictions and diagnostic evidence plan.

`Evidence`
: A concrete observation tied to a predeclared prediction or diagnostic-plan
  clause. Evidence can be a command result, log line, stack trace, reproduction
  result, failed reproduction, code path, config value, runtime state,
  diagnostic probe output, user feedback, external reviewer finding, or
  fix-validation result.

## Workflow

### 1. Locate Or Create The Case

Check the activation gate. If it is not met, explain why this heavy process is
not justified and use a lightweight debug path unless the user explicitly
requests Bug Killer.

Before creating a new `/coe` case or appending evidence, apply the public-repo
privacy gate from `Case Artifact`.

If the activation gate is met, inspect `/coe`. Reuse a relevant open case;
otherwise create a new timestamped case file.

Normalize the user report into one `Problem P-001`. If the report includes
multiple unrelated bugs, split them into separate case files.

### 2. Intake And Light Orientation

Gather only enough context to avoid generic questions:

- observed symptom
- expected behavior
- actual behavior
- trigger or reproduction path
- affected environment, version, branch, account, device, or dataset
- recent change or regression window
- available logs, stack traces, screenshots, tests, or traces
- impact and urgency

If the report is thin, ask 1-3 targeted questions that separate root-cause
families. Do not ask a long generic bug questionnaire.

### 3. Build A Neutral Research Packet

Before running independent paths, write a neutral packet in the current response
or in existing case fields only. Include confirmed facts, important unknowns,
relevant files, logs, commands, constraints, candidate hypotheses, and evidence
standards.

Do not include persuasive conclusions. The packet exists to keep each path from
inheriting the main agent's bias.

Do not add a `Research Packet`, `Plan`, `Notes`, or any other free-form heading
to a `/coe` case file. If packet details must persist in the case, distribute
them through allowed fields: `Problem.Known facts`, `Hypothesis.Rationale`,
`Hypothesis.Diagnostic evidence plan`, and concrete `Evidence` nodes.

### 4. Run Independent Research Paths

Use at least two distinct paths for non-trivial bugs when available:

- main-agent code, log, test, and reproduction investigation
- fresh internal subagents when the runtime and task rules allow them
- user-approved external agents when explicitly authorized
- targeted experiments, probes, traces, or diagnostic log plans
- user or operator feedback loops for state that only exists in the real system

If subagents or external agents are unavailable, still keep path separation.
Use at least two materially different local evidence paths, such as code-path
trace plus reproduction, targeted test plus diagnostic log, runtime state plus
config check, or operator feedback plus trace evidence. Do not count two shallow
reads of the same file or log as independent paths.

Each path should answer:

- most likely cause and location
- mechanism that explains the symptom
- evidence already found
- evidence that would refute the claim
- alternatives considered
- next diagnostic step if confidence is insufficient

### 5. Generate Falsifiable Hypotheses

Represent each candidate as a `Hypothesis` node. A useful hypothesis:

- explains the observed symptom,
- predicts what should be observed if true,
- predicts what should not be observed if false,
- can be tested with the smallest safe action,
- identifies the diagnostic signal needed before repair design.

Reject vague labels such as "race condition", "environment issue", or
"frontend bug" unless they are rewritten into a specific testable mechanism.

### 6. Candidate Root-Cause Evidence Gate

Before proposing a repair design, choose the active candidate root cause and
write its diagnostic evidence plan.

The plan must name:

- the predeclared prediction or evidence-plan clause being tested,
- the signal to capture,
- how it will be captured,
- why the signal distinguishes this hypothesis from meaningful alternatives,
- what result would support the hypothesis,
- what result would refute or downgrade it,
- stable event names, markers, and correlation IDs when logs, traces, telemetry,
  or user feedback are used,
- whether instrumentation is diagnostic-only and how it will be removed,
  retained, or converted into permanent observability.

Valid evidence-gathering methods include:

- structured diagnostic logs with stable event names and relevant IDs,
- temporary probes or assertions,
- failing or focused tests,
- reproduction scripts,
- runtime state snapshots,
- trace markers,
- metrics or telemetry,
- config and environment checks,
- user-feedback prompts or operator confirmation,
- controlled rollback or feature-flag experiments when safe.

If the diagnostic evidence plan cannot be executed safely, mark the hypothesis
`blocked` and state the unblock condition. Do not start repair design.

### 7. Record Evidence Before Changing Status

After each meaningful observation, add an `Evidence` node before changing a
hypothesis status. The evidence must identify the exact falsifiable prediction
or diagnostic evidence-plan clause it matched, supported, refuted, or left
neutral. This prevents hindsight-fitting existing logs or user feedback into a
cause narrative.

Set a hypothesis to:

- `confirmed` only when evidence supports the mechanism and separates it from
  meaningful alternatives,
- `refuted` when evidence contradicts a required prediction,
- `blocked` when the next diagnostic step cannot run,
- `closed` when the branch is intentionally abandoned or superseded.

Do not treat code proximity, agent agreement, or a plausible fix idea as proof.

### 8. Synthesize By Evidence Weight

Compare paths by evidence quality:

- direct reproduction or failing test,
- log, trace, or runtime state tied to the symptom and to a predeclared
  prediction,
- code path showing how the wrong state is produced,
- data, config, or environment fact that changes the result,
- regression-window proof,
- falsified alternatives.

If two causes remain plausible, do not average them into a confident answer.
Name the next diagnostic experiment that separates them.

### 9. Repair Design Gate

Only after a hypothesis is `confirmed`, present a repair-ready summary:

```markdown
Root cause summary:
- Cause: <specific mechanism and location>
- Diagnostic evidence: <2-5 evidence IDs or concrete facts>
- Ruled out: <main alternatives and why>
- Confidence: high | medium
- Repair design direction: <brief approach, not a patch yet>
- Observability impact: <logs/probes to remove, retain, or add permanently>
- Remaining risk: <none or specific gap>

Please confirm whether I should start the fix.
```

For low confidence, use this instead:

```markdown
Root cause status:
- Current hypothesis: <specific but unconfirmed mechanism and location>
- Evidence so far: <2-5 evidence IDs or concrete facts>
- Missing proof: <diagnostic signal still needed>
- Next diagnostic experiment: <smallest safe action>
- Repair status: not ready; repair design is blocked by the evidence gate.

Should I continue investigation with this diagnostic experiment?
```

### 10. Implement And Validate The Fix

After repair is authorized, keep the fix tied to the confirmed hypothesis. Do
not add silent fallbacks or special cases that hide the symptom without
addressing the confirmed mechanism unless they are explicit product
requirements.

Run targeted smoke and regression checks. Add `Evidence` of type
`fix-validation` showing the original symptom no longer occurs under the stated
reproduction conditions.

Set `Problem P-001` to `fixed` only when:

1. a relevant hypothesis is `confirmed`,
2. the repair is tied to that hypothesis,
3. fix-validation evidence exists,
4. `Resolution basis` lists the hypothesis and evidence IDs.

## Response Behavior

While using this skill:

- name the active case file,
- name the active hypothesis,
- state the next evidence target before running a command or changing code,
- distinguish diagnostic-only changes from repair changes,
- summarize new evidence, hypothesis status changes, and the next gate,
- do not dump the full case unless asked.

## Anti-Patterns

- Fixing the first suspicious file before the diagnostic evidence gate.
- Designing the repair immediately after a candidate cause appears.
- Treating logs as evidence when no prediction was defined before reading them.
- Treating external agents, subagents, or reviewer agreement as proof.
- Combining diagnostic instrumentation and repair in one unclear patch.
- Publishing new `/coe` evidence from a public repository before resolving its
  privacy choice, or assuming `.gitignore` protects CoE files already tracked.
- Adding silent fallback behavior that masks the symptom.
- Marking the problem fixed because code changed rather than because
  fix-validation evidence exists.

## Fixtures

Read `references/interaction-fixtures.md` when modifying or auditing this skill.
