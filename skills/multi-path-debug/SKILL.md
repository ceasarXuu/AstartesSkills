---
name: multi-path-debug
description: Use when a user reports a bug and the work should focus on confirming the root cause before any fix. The workflow asks targeted context questions, runs independent multi-agent root-cause research with user-approved external agents when available, weighs evidence over opinion, then asks the user to confirm before implementation begins.
---

# Multi-Path Debug

Use this skill when the user reports a bug, regression, runtime failure,
incorrect behavior, flaky test, broken workflow, or production symptom and the
next responsible step is root-cause confirmation rather than immediate repair.

The purpose is to split debugging into two explicit phases:

1. Root-cause investigation and user confirmation.
2. Fix implementation only after the user confirms the root-cause summary and
   authorizes repair.

Do not combine those phases. Never edit code, config, migrations, tests, or
runtime behavior while this skill is still in the root-cause phase unless the
user explicitly authorizes a narrow diagnostic-only change.

For concrete conversation fixtures, read
`references/interaction-fixtures.md` when modifying or auditing this skill.

## Non-Negotiable Rules

- Root-cause confirmation is the first deliverable.
- Ask targeted context questions before deep research when the report is thin.
- Keep the first question round to 1-3 high-value questions after a light code
  and symptom read.
- Run independent research paths once enough context exists.
- Discover available external agent paths, explain them, and ask the user which
  ones may participate before invoking them.
- Treat external agent use as optional. Internal investigation must still work
  without them.
- Evidence outweighs agent agreement. Logs, reproduction, code paths, tests,
  data state, environment facts, and falsified alternatives matter more than
  voting.
- Summarize the likely root cause, evidence, rejected alternatives, confidence,
  and proposed fix direction before changing behavior.
- Ask the user to confirm before starting repair.
- If confidence is low, say what evidence is missing instead of pretending the
  cause is known.

## Investigation Artifact

Maintain a compact project-root investigation log when the task touches a
repository:

```text
debug/multi-path/YYYY-MM-DD-HH-mm-<short-bug-title>.md
```

Create `debug/multi-path/` when missing. If a project already has a stronger
debug artifact convention, such as `/coe`, use that convention and include a
`Multi-path debug` section or node references there.

The artifact should record:

- original symptom and user context
- first-pass questions and answers
- research paths launched
- external agent authorization decision
- evidence found, with file paths, commands, log snippets, or reproduction
  notes
- competing hypotheses and why they were supported, refuted, or left open
- final root-cause summary shown to the user
- user confirmation status before any fix

## Workflow

### 1. Intake And Light Orientation

Read the user's bug report and inspect the smallest relevant code surface,
logs, tests, recent errors, or existing debug artifacts needed to avoid asking
generic questions.

Keep this orientation bounded. It should identify the likely area and the
highest-value missing facts, not become a full investigation before the first
user clarification.

Classify what is known:

- observed symptom
- expected behavior
- actual behavior
- trigger or reproduction path
- affected environment, version, branch, account, device, or data set
- recent change or regression window
- available logs, stack traces, screenshots, or test output
- impact and urgency

If key context is missing, ask 1-3 questions only. Prefer questions that
separate root-cause families, for example:

- exact reproduction step, input, or command
- expected vs actual behavior
- first known bad version, branch, deployment, device, account, or dataset
- full error text or log marker
- whether the symptom is deterministic or flaky

Do not ask a full bug questionnaire unless the user explicitly wants that.

### 2. Build The Root-Cause Research Packet

Once enough context exists, create a neutral research packet for all
investigation paths. Include:

- bug objective
- confirmed facts
- unknowns that still matter
- relevant files, logs, commands, tests, screenshots, traces, or runtime surfaces
- constraints, such as no code changes before root-cause confirmation
- hypotheses to test or falsify
- evidence standards for a confirmed cause

Do not include persuasive conclusions. The packet should help each path inspect
the target independently.

### 3. Discover And Authorize External Agents

Discover available local or configured external agent paths before asking the
user for authorization. Check current runtime tools, installed skills, local CLI
commands, and project conventions. Common candidates include:

- `ask-claude` or a local Claude CLI path
- `ask-gemini` or a local Gemini CLI path
- `opencode-controller` or an Opencode session path
- other explicit project or runtime agent tools

Report only actionable candidates. For each candidate, state:

- name
- how it would be invoked
- what context it would receive
- whether it may read local code, logs, or generated artifacts
- what output artifact or transcript will be saved

Ask for one authorization decision before invoking external agents:

```text
I found these optional external research paths: <list>.
May I use <recommended subset> for independent root-cause analysis?
You can approve all, approve some, or decline external agents.
```

If the user declines or does not answer, continue with internal paths only. Do
not block root-cause research solely because external agents are unavailable.

### 4. Run Independent Research Paths

Use at least two distinct paths when the bug is non-trivial:

- main-agent direct investigation
- one or more fresh internal subagents when available
- approved external agents
- targeted command, log, test, reproduction, or trace experiments

Each path must receive the same root-cause research packet and should answer:

- most likely root-cause location
- mechanism that explains the symptom
- supporting evidence
- evidence that would refute the claim
- alternatives considered and why they are weaker
- recommended next diagnostic step if confidence is insufficient

Keep research paths independent. Do not send one agent another agent's
conclusion until after initial findings are collected.

### 5. Synthesize By Evidence Weight

Compare findings by evidence quality, not by majority vote.

Prefer conclusions backed by:

- direct reproduction or a failing test
- stack trace, log marker, or runtime state tied to the symptom
- code path showing how the wrong state or behavior is produced
- data/config/environment fact that changes the result
- regression-window evidence
- a falsified competing hypothesis

Downgrade conclusions that rely on:

- vague labels such as "race condition" or "environment issue"
- an untested assumption
- code proximity without symptom linkage
- a fix idea without cause evidence
- agent agreement without independent proof

If two causes are plausible, state the uncertainty and the smallest next
experiment needed to separate them.

### 6. Ask For Repair Confirmation

Before editing code or changing behavior, give the user a concise root-cause
summary.

For `high` confidence or strong `medium` confidence where the remaining risk is
explicit and acceptable to the requester, use a repair-ready summary:

```markdown
Root cause summary:
- Cause: <specific mechanism and location>
- Evidence: <2-5 bullets with files, logs, commands, or reproduction>
- Ruled out: <main alternatives and why>
- Confidence: high | medium | low
- Fix direction: <brief repair approach, not implementation details>
- Remaining risk: <none or specific gap>

Please confirm whether I should start the fix.
```

For `low` confidence, do not ask to start the fix. The cause is still a
hypothesis, so ask whether to continue investigation with the next
discriminating experiment:

```markdown
Root cause status:
- Current hypothesis: <specific but unconfirmed mechanism and location>
- Evidence so far: <2-5 bullets with files, logs, commands, or reproduction>
- Why confidence is low: <missing proof or unresolved competing hypothesis>
- Next discriminating experiment: <smallest action that separates causes>
- Repair status: not ready; more evidence is required before repair.

Should I continue investigation with this next experiment?
```

If the user confirms, leave this skill's root-cause phase and proceed with the
repo's normal implementation, testing, logging, and review rules. If the user
does not confirm, stop before repair and preserve the investigation artifact.

## Confidence Scale

- `high`: direct evidence explains the symptom and at least one meaningful
  alternative was refuted.
- `medium`: evidence strongly points to one mechanism, but reproduction,
  logging, or one competing hypothesis remains incomplete.
- `low`: the current conclusion is a hypothesis, not a confirmed root cause.
  More evidence is required before repair.

## Anti-Patterns

- Fixing the first suspicious file before confirming the bug mechanism.
- Asking the user a long generic questionnaire before reading obvious evidence.
- Treating external agents as authority instead of evidence producers.
- Running multiple agents with different or biased packets.
- Hiding disagreement between research paths.
- Reporting a fix plan as if it were a root-cause conclusion.
- Making code changes and then asking the user to approve the root cause.
- Using silent fallback behavior to mask a bug instead of proving the cause.
