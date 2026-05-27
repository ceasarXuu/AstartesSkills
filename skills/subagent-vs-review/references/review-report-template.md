# Review Report Template

Use this structure for every subagent-vs-review report. A report may contain
multiple rounds for the same task.

```markdown
# Subagent VS Review: <topic>

- Created: <ISO 8601 local time>
- Updated: <ISO 8601 local time>
- Task: <user or product goal>
- Report path: `vs_review/YYYY-MM-DD-<topic>-review.md`
- Review mode: fresh internal subagents
- Source session policy: no inherited main-agent context
- Status: open | passed | blocked | accepted-risk

## Round 1: <short round purpose>

### Review Input

#### Objective
<The user or product goal.>

#### Review Target
<Design, implementation, test plan, release process, document, skill, or workflow.>

#### Target Locations
- `<path or command>`
- `<path or command>`

#### Change Introduction
<Neutral description of the proposed or implemented direction.>

#### Risk Focus
- <assumption, boundary, or failure mode to challenge>

#### Verification Status
- <tests, smoke checks, logs, runtime validation, or known gaps>

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| <reviewer> | <why selected> | <risk area> |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| <reviewer> | <subagent tool/runtime> | <id or equivalent trace handle> | <tool call, notification, transcript, or unavailable> | no | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Outputs

#### <reviewer-name>

##### Summary
<Short summary.>

##### Blocking Findings
- <finding, or "none">

##### Non-blocking Risks
- <risk, or "none">

##### Required Fixes
- <fix, or "none">

##### Missing Tests
- <test gap, or "none">

##### Missing Logs / Observability
- <observability gap, or "none">

##### Evidence
- `<path>:<line>` - <evidence>

### Main Agent Response

| Reviewer | Finding | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|
| <reviewer> | <finding> | blocking | accept / reject / defer | <evidence> | <action> | <follow-up> |

### Closure Status

- Blocking findings found: yes / no
- Accepted blocking findings fixed: yes / no / n/a
- Blocking re-review completed: yes / no / n/a
- Blocking re-review passed: yes / no / n/a
- Blocking re-review round links:
  - <Round N or n/a>
- Blocking re-review launch records:
  - <Reviewer Launch Records row or n/a>
- Rejected findings backed by evidence: yes / no / n/a
- Deferred findings documented: yes / no / n/a
- Allowed to proceed: yes / no

## Final Conclusion

<Whether the task may proceed, requires more work, is blocked, or is accepted
by explicit user risk acceptance.>
```

## Report Rules

- Record the review input before or at the time reviewers are spawned.
- Record reviewer launch records before adding reviewer outputs.
- Append reviewer outputs without rewriting them into a softer summary.
- Add main-agent response only after reading the reviewer outputs.
- If a new round is needed, append `## Round 2`, `## Round 3`, and so on.
- Each accepted blocking finding must link to a follow-up round and launch
  record before the report can be marked `passed`.
- Keep the report in `/vs_review/` and commit it with the related work.
