---
name: coe-debug
description: Use this skill when debugging complex, multi-factor, or long-running bugs. It maintains a project-root /coe Markdown case file per bug case using a strict Chain-of-Evidence model with only Problem, Hypothesis, and Evidence nodes.
---

# COE Debug

Use this skill when debugging a bug that may involve multiple layers, multiple causes, intermittent symptoms, long context, repeated failed attempts, or any risk of circular reasoning.

The purpose is to treat debugging like a case investigation: maintain a persistent evidence chain, separate hypotheses from facts, and avoid losing state when the conversation or code context becomes long.

## Core Model

Every debug case is represented by one Markdown file under the project root:

```text
/coe/YYYY-MM-DD-HH-mm short-bug-title.md
```

Example:

```text
/coe/2026-05-01-13-31 terminal-startup-lag.md
```

Each case file contains exactly three node types:

1. `Problem` - the unique root node of the case.
2. `Hypothesis` - a falsifiable explanation of the problem or a sub-cause.
3. `Evidence` - an actual observation, experiment result, log, code finding, config fact, or user confirmation used to support or refute a hypothesis.

A case file must contain exactly one `Problem` node. It may contain zero or more `Hypothesis` nodes and zero or more `Evidence` nodes.

No other node type is allowed in case files. Do not create separate sections such as `Logs`, `Tasks`, `Actions`, `Timeline`, `Plan`, `Summary`, `Conclusion`, or `Notes`. Put that information into fields inside one of the three allowed node types.

## Allowed States

### Problem States

Only these values are valid:

- `open` - unresolved and still active.
- `fixed` - solved and validated by evidence.
- `closed` - no longer being pursued.

A `Problem` node may be set to `fixed` only when at least one relevant `Hypothesis` has state `confirmed`, and there is validation evidence showing that the bug is actually resolved.

A code change, config change, or plausible explanation alone is not enough to mark the problem as `fixed`.

### Hypothesis States

Only these values are valid:

- `unverified` - proposed but not yet tested.
- `confirmed` - supported by concrete evidence and explains the relevant symptom or sub-cause.
- `refuted` - contradicted by concrete evidence.
- `blocked` - cannot currently be tested because required information, access, environment, reproduction, or dependency is missing.
- `closed` - intentionally no longer pursued, usually because it is superseded, irrelevant, or not worth further investigation.

Evidence nodes have no state. They are factual records.

## Case Split And Merge Rule

When the user reports multiple bugs at the same time:

- Use one case file if the symptoms are highly correlated: same trigger, same execution path, same regression window, same error surface, same stack trace, same environment, or likely shared root cause.
- Create separate case files if the symptoms appear independent.
- If uncertain, start with one case only when there is a concrete suspected relation. Otherwise create separate cases.
- Do not put multiple unrelated root problems into one case file. One case file means one `Problem` node.

If a later investigation proves that two cases share a root cause, keep both files but cross-reference the other case in a field inside the `Problem` node. Do not add a fourth node type.

## Case Document Format

A valid case document uses this structure exactly:

```markdown
# Problem P-001: <short problem title>
- Status: open
- Created: <YYYY-MM-DD HH:mm>
- Updated: <YYYY-MM-DD HH:mm>
- Objective: <the single goal this case must solve>
- Symptoms:
  - <observed symptom>
- Expected behavior:
  - <what the system should do>
- Actual behavior:
  - <what the system does now>
- Impact:
  - <affected feature, user, environment, version, or workflow>
- Reproduction:
  - <steps, input, preconditions; write "unknown" if unknown>
- Environment:
  - <OS, runtime, version, config, branch, commit; write "unknown" if unknown>
- Known facts:
  - <facts confirmed by evidence nodes; write "none" if empty>
- Ruled out:
  - <directions ruled out by refuted hypotheses; write "none" if empty>
- Fix criteria:
  - <evidence required before this problem can become fixed>
- Current conclusion: <the most defensible case judgment; do not exceed evidence>
- Related hypotheses:
  - H-001
- Resolution basis:
  - <only when fixed: H-xxx + E-xxx; otherwise write "not satisfied">
- Close reason:
  - <only when closed; otherwise write "not closed">

## Hypothesis H-001: <short falsifiable claim title>
- Status: unverified
- Parent: P-001
- Claim: <a concrete judgment that can be confirmed or refuted>
- Layer: root-cause | sub-cause | fix-validation | regression-window | environment | interaction
- Factor relation: single | all_of | any_of | part_of | unknown
- Depends on:
  - <H-xxx; write "none" if empty>
- Rationale:
  - <reason from the problem report, existing evidence, code structure, or experience; this is reasoning, not evidence>
- Falsifiable predictions:
  - If true: <what should be observed>
  - If false: <what should not be observed, or what opposite result should appear>
- Verification plan:
  - <next smallest action; prefer experiments that separate competing hypotheses>
- Related evidence:
  - <E-xxx; write "none" if empty>
- Conclusion: <why the status is unverified, confirmed, refuted, blocked, or closed>
- Next step: <continue testing, create child hypothesis, implement fix, wait for input, or stop>
- Blocker:
  - <only when blocked; otherwise write "none">
- Close reason:
  - <only when closed; otherwise write "not closed">

## Evidence E-001: <short evidence title>
- Related hypotheses:
  - H-001
- Direction: supports | refutes | neutral
- Type: observation | log | experiment | code-location | config | environment | user-feedback | fix-validation
- Source: <command, file path, code location, screenshot description, or user feedback source>
- Raw content:
  ```text
  <key output, error text, code snippet, config, or reproduction result; preserve raw wording>
  ```
- Interpretation: <how this evidence affects related hypotheses; stay narrower than the raw content>
- Time: <YYYY-MM-DD HH:mm>
```

## Heading Rule

Inside case documents, headings must match one of these forms only:

```text
# Problem P-001: ...
## Hypothesis H-001: ...
## Evidence E-001: ...
```

No other Markdown heading is valid in a case file.

## ID Rule

- The problem node is always `P-001`.
- Hypothesis IDs are `H-001`, `H-002`, `H-003`, and so on.
- Evidence IDs are `E-001`, `E-002`, `E-003`, and so on.
- IDs are never reused.
- Do not renumber existing nodes.

## Workflow

### 1. Locate Or Create The Case

Before debugging, inspect `/coe` in the project root.

- If a relevant `open` case already exists, update that file.
- If no relevant case exists, create a new Markdown file under `/coe` using the required timestamped filename.
- If `/coe` does not exist, create it.

The case document is the source of truth. Do not rely on conversation memory when a case file exists.

### 2. Normalize The Problem

Create or update the single `Problem` node.

The `Objective` field must be singular. If the user gave a broad complaint, rewrite it as one concrete debug target. Preserve the user's original symptoms under `Symptoms`.

Do not mark the problem as `fixed` at creation time.

### 3. Generate Hypotheses

Create hypotheses as falsifiable statements.

A good hypothesis has these properties:

- It explains at least one observed symptom.
- It predicts a concrete observation.
- It can be tested with a small action.
- It can be contradicted by evidence.

Bad hypotheses are vague labels such as "environment issue", "code bug", or "dependency problem". Rewrite them into testable statements.

For multi-layer issues, use `Parent` and `Depends on` fields instead of creating new node types.

Example:

```text
H-001: terminal lag originates during shell startup
H-002: zsh plugin initialization blocks shell startup; parent H-001
H-003: nvm auto-loading causes zsh plugin initialization to block; parent H-002
```

### 4. Choose The Next Evidence Target

At any point, choose one active hypothesis as the current investigation target.

Prefer the hypothesis whose test is:

1. Most discriminating between competing hypotheses.
2. Cheapest to run.
3. Least destructive.
4. Most likely to unblock downstream hypotheses.

Before repeating a command, experiment, code search, or patch, check whether an equivalent evidence node already exists. Do not repeat the same loop unless something material changed.

### 5. Record Evidence Before Changing Conclusions

After each meaningful observation or experiment, add an `Evidence` node before changing hypothesis status.

Evidence must be concrete. It can be:

- command output,
- log text,
- stack trace,
- code location,
- config value,
- reproduction result,
- failed reproduction result,
- user confirmation,
- timing measurement,
- dependency or version fact,
- validation result after a fix.

Do not record pure speculation as evidence. Put speculation in `Hypothesis.Rationale` or `Hypothesis.Conclusion`.

### 6. Update Hypothesis Status

A hypothesis may change state only after evidence is recorded.

- Set to `confirmed` when evidence supports the hypothesis and the hypothesis explains the relevant symptom or sub-cause.
- Set to `refuted` when evidence contradicts a required prediction.
- Set to `blocked` when the next verification step cannot proceed; record `Blocker` and the exact unblock condition.
- Set to `closed` when it is intentionally abandoned, superseded, or irrelevant; record `Close reason`.

Do not treat absence of evidence as disproof unless the hypothesis explicitly predicted that evidence should appear under the tested conditions.

### 7. Apply Fixes Only After Enough Evidence

Prefer targeted fixes attached to confirmed or strongly supported hypotheses.

If a patch is exploratory, record that as evidence or as a hypothesis validation step. Do not present an exploratory patch as a confirmed fix until validation evidence exists.

### 8. Mark The Problem Fixed Only After Validation

The `Problem` status may become `fixed` only when all are true:

1. At least one relevant hypothesis is `confirmed`.
2. The implemented change or discovered correction is tied to that hypothesis.
3. An `Evidence` node of type `fix-validation` shows the original symptom no longer occurs under the stated reproduction conditions.
4. The `Resolution basis` field lists the confirming hypothesis and validation evidence.

If the validation only covers part of the symptom, do not mark the problem `fixed`. Add a new hypothesis for the remaining symptom or split the case if it is independent.

### 9. Close Without Fixing Only When Appropriate

Set the `Problem` status to `closed` only when the case is intentionally stopped, for example:

- user no longer wants to pursue it,
- bug is out of scope,
- required information cannot be obtained,
- reproduction is impossible and no productive path remains,
- the issue is accepted as a known limitation.

Record the reason in `Close reason`.

## Response Behavior While Using This Skill

When interacting with the user during a debugging case:

- Name the active case file when it is created or selected.
- State the active hypothesis being tested.
- State what evidence the next action is expected to produce.
- After a debug step, summarize only:
  - new evidence added,
  - hypothesis status changes,
  - problem status,
  - next hypothesis or blocker.

Do not dump the entire case file unless the user asks.

## Loop Prevention Rules

To avoid circular debugging:

- Never rerun the same check without explaining what changed.
- Never create a new hypothesis that is semantically identical to an existing active, refuted, or closed hypothesis.
- Never mark a hypothesis `confirmed` because it is plausible; require evidence.
- Never mark a problem `fixed` because a patch was applied; require validation evidence.
- When stuck, inspect the case file and choose between:
  - adding a discriminating hypothesis,
  - splitting the case,
  - marking a hypothesis `blocked`,
  - closing a dead branch.

## Case Document Maintenance Rules

- The case file is append-friendly and evidence-preserving.
- Do not delete evidence nodes. If an earlier interpretation was wrong, add a new evidence node or update the hypothesis conclusion to explain the correction.
- Do not delete hypotheses. Mark them `refuted`, `closed`, or `blocked` as appropriate.
- Keep `Problem.Known facts`, `Problem.Ruled out`, `Problem.Current conclusion`, and `Problem.Updated` synchronized after meaningful evidence.
- Keep raw evidence short but sufficient. Include exact file paths, line numbers, commands, and key outputs where possible.
- Use absolute or project-relative file paths consistently.

## Minimal Case Template

Use the file in `templates/case-template.md` or copy the skeleton from the Case Document Format section into a new case file.
