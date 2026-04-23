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
  - not satisfied
- Close reason:
  - not closed

## Hypothesis H-001: <short falsifiable claim title>
- Status: unverified
- Parent: P-001
- Claim: <a concrete judgment that can be confirmed or refuted>
- Layer: root-cause | sub-cause | fix-validation | regression-window | environment | interaction
- Factor relation: single | all_of | any_of | part_of | unknown
- Depends on:
  - none
- Rationale:
  - <reason from the problem report, existing evidence, code structure, or experience; this is reasoning, not evidence>
- Falsifiable predictions:
  - If true: <what should be observed>
  - If false: <what should not be observed, or what opposite result should appear>
- Verification plan:
  - <next smallest action; prefer experiments that separate competing hypotheses>
- Related evidence:
  - E-001
- Conclusion: unverified
- Next step: <continue testing, create child hypothesis, implement fix, wait for input, or stop>
- Blocker:
  - none
- Close reason:
  - not closed

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
