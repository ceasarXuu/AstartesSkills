# Review Governor

The review governor is a deterministic control layer for `subagent-vs-review`.
It does not decide whether code is elegant. It decides whether the workflow is
allowed to continue, must stop, must evaluate rollback, or must return control
to the user.

## Inputs

Read these values from the current review report:

- automatic round budget
- completed rounds
- current round type
- frozen objective, acceptance criteria, and non-goals
- accepted blocker IDs
- unresolved blocker count by round
- repeated failure classes
- evidence authority for each blocking or scope-expanding claim
- newly touched files and modules
- new dependencies
- public API or persistent data changes
- new cross-module abstractions
- cumulative implementation and test growth
- claimed benefit and measured result
- side effects and regressions
- last known-good checkpoint
- explicit user approvals

## Automatic Round Budget

The default budget is:

```text
Round 1: initial adversarial review
Round 2: focused blocking-closure review, only when needed
```

A failed or lost reviewer attempt does not consume another round. A completed
reviewer result does.

Round 3 or later is prohibited unless the user explicitly approves that exact
additional round after receiving the convergence reflection. Prior permission
to perform the task, use the skill, or fix blockers is not approval for an
unbounded number of rounds.

## Closure Finding Admissibility

A blocking finding in a closure round is admissible only when its closure
relation is one of:

- `original-blocker-open`
- `fix-regression`
- `direct-adjacent-objective-failure`

`direct-adjacent-objective-failure` means the accepted fix exposes an immediate
causal failure that directly prevents the same frozen objective from being
satisfied. It does not include broader architecture improvement, unrelated old
defects, future extensibility, generic consistency, or optional cleanup.

Findings classified as `unrelated-existing-risk` must not trigger automatic
repair or another closure round. Record them as non-blocking risks or
future-review candidates unless E0 user authority or E1 project authority
explicitly places them in the current task.

## Evidence Gate

Use the evidence hierarchy defined in `SKILL.md`.

- E0-E3 can authorize a blocking response when relevant and sufficient.
- E4 can propose a hypothesis and a bounded verification step.
- E4 alone cannot authorize scope expansion.

Scope expansion includes:

- new top-level modules
- new external dependencies
- public API changes
- persistent data or schema changes
- new cross-module abstractions
- changes outside frozen target locations
- operational or deployment changes outside the original task
- broad test, logging, or infrastructure programs not required by E0-E3 evidence

If the only support is E4, return `stop-evidence-insufficient` or
`user-decision-required`.

## Scope Drift Gate

Return `stop-scope-drift` when any unapproved condition occurs:

- a new top-level module is touched
- a new dependency is added
- a public API or persistent data format changes
- a new cross-module abstraction is introduced
- work expands outside frozen target locations
- cumulative change grows substantially without measured objective benefit
- a closure fix becomes a broader refactor, platform, framework, or consistency
  program
- generic best practice begins overriding explicit user or project scope

A threshold is a warning, not automatic permission. The agent must explain the
change and obtain authority before continuing.

## Convergence Gate

The workflow is converging only when all applicable statements are true:

- unresolved blocker count decreases
- no failure class repeats across two completed rounds
- new closure blockers have an admissible causal relation
- fixes close more blockers than they introduce
- scope growth remains justified by the frozen objective
- measured benefit is not being outweighed by side effects
- the task model does not require reinterpretation

Return:

- `stop-non-convergent` when blockers do not decrease, a failure class repeats,
  or risk is moving rather than reducing
- `rollback-evaluation-required` when new defects or complexity are primarily
  caused by recent fixes
- `user-decision-required` when the goal, scope, tradeoff, or risk decision
  cannot be resolved from E0-E3 authority

## Decision Procedure

Apply in this order:

```text
1. If completed automatic rounds >= budget:
     user-decision-required

2. If current closure finding is unrelated:
     stop-scope-drift

3. If proposed scope expansion has only E4 support:
     stop-evidence-insufficient

4. If scope drift gate triggers:
     stop-scope-drift

5. If repeated failure class, non-decreasing blockers, or net blocker growth:
     rollback-evaluation-required or stop-non-convergent

6. If objective, acceptance criteria, non-goals, or tradeoffs need reinterpretation:
     user-decision-required

7. If no blocking finding remains:
     pass

8. If Round 1 has an accepted, evidenced, in-scope blocker:
     start-closure-round

9. Otherwise:
     continue-current-round
```

## Workflow Decisions

The governor must emit exactly one:

| Decision | Meaning |
|---|---|
| `continue-current-round` | finish bounded work already authorized in this round |
| `start-closure-round` | launch the one automatic focused closure review |
| `pass` | no unresolved admissible blocker remains |
| `stop-scope-drift` | proposed work exceeds frozen scope |
| `stop-evidence-insufficient` | evidence is too weak for the proposed action |
| `stop-non-convergent` | review and repair are not reducing risk |
| `rollback-evaluation-required` | recent changes may be amplifying the problem |
| `user-decision-required` | user authority is required before further work |

## Convergence Reflection

When the decision is a stop, rollback, or user decision, record:

- why the governor stopped
- completed rounds versus budget
- blocker counts by round
- repeated or newly introduced failure classes
- E0-E4 evidence inventory
- scope growth and side effects
- benefit achieved or not achieved
- last known-good checkpoint
- rollback cost and consequence
- bounded user choices

The main agent must not modify the artifact or start another reviewer before the
required user decision is recorded.
