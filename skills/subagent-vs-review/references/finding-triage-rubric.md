# Finding Triage Rubric

The main agent must respond to every reviewer finding. Use one of three
decisions: `accept`, `reject`, or `defer`.

Adversarial findings are counterexamples against the artifact, not criticism of
the author. Triage must handle the counterexample: prove it impossible, fix it,
or explicitly accept/defer the risk.

Triage does not itself authorize another repair or review round. After triage,
the review governor decides whether the workflow may continue.

## Evidence Authority

Record one authority level for every blocking or scope-expanding finding:

`E0`
: Explicit user instruction or user confirmation. Authoritative for product
  goal, scope, tradeoffs, and risk acceptance.

`E1`
: PRD, issue, plan, ADR, repository policy, or project documentation.
  Authoritative for documented project intent and constraints.

`E2`
: Direct runtime behavior, reproducible test, logs, production path, or observed
  failure. Authoritative for actual system behavior.

`E3`
: Official documentation, standard, protocol, or authoritative external source.
  Authoritative for external facts and platform constraints.

`E4`
: Reviewer or main-agent reasoning, generated code, generated tests, inferred
  best practice, or analogy. This is a hypothesis, not independent external
  evidence.

Use the strongest relevant evidence. E4 may justify a bounded verification
step, but E4 alone must not authorize scope expansion.

## Severity

`blocking`
: The task cannot honestly be considered complete. The issue breaks the frozen
  product goal, invalidates the design, creates unacceptable architecture,
  security, data, release, or operational risk, leaves critical validation
  missing, or counts protocol-only, scaffold-only, mock-only, fake-data-only,
  demo-only, or test-only wiring as completed implementation.
  A reproducible failure scenario, broken assumption, or untested high-impact
  failure path can be blocking even when the happy path works.

`major`
: The issue is likely to cause regressions, maintenance cost, poor diagnostics,
  or future rework, but the current task may still proceed if the risk is
  explicitly managed.

`target-benefit warning`
: The issue challenges whether the stated benefit was achieved, such as speed,
  accuracy, cost, reliability, throughput, quality, conversion, usability, or
  operational improvement. Missing baseline, missing target, weak measurement,
  neutral outcome, or regressed outcome is a non-blocking warning because
  benefit tradeoffs require user decision-making and solution design. Do not
  mark a benefit-realization finding as blocking unless the same evidence
  independently proves a correctness, security, data, reliability, or
  operational failure.

`minor`
: The issue is useful cleanup, clarity, or polish that does not change whether
  the current task is viable.

## Closure-Round Blocking Admissibility

A closure-round finding may remain `blocking` only when its closure relation is:

`original-blocker-open`
: The accepted blocker is still reproducible or its required proof is still
  missing.

`fix-regression`
: The accepted fix directly introduced a new failure that breaks the same frozen
  objective.

`direct-adjacent-objective-failure`
: The fix exposes an immediate causal failure that directly prevents the same
  frozen objective from being satisfied.

The following are not automatic closure blockers:

- unrelated existing defects
- general architecture consistency
- future extensibility
- optional cleanup
- broad observability, testing, or infrastructure programs
- generic best-practice improvements
- changes that require rewriting the frozen objective or non-goals

Classify these as `major`, `minor`, `target-benefit warning`, or
`future-review candidate` unless E0 user authority or E1 project authority
explicitly places them in the current task.

## Decisions

`accept`
: The finding is valid. Record the broken assumption, evidence authority,
  relationship to the frozen objective, smallest corrective action, scope
  effect, side effects, rollback checkpoint, and proof required. Acceptance does
  not authorize implementation until the review governor permits it.

`reject`
: The finding is not valid for this task. Cite concrete evidence: code location,
  test result, log, runtime behavior, product constraint, official source, or
  explicit user instruction. A rejection must defeat the failure scenario, not
  merely restate the main agent's intent.

`defer`
: The finding is valid but outside the current scope. State why it is not
  handled now and where it should be tracked. Blocking findings should not be
  deferred unless the user explicitly accepts the risk.

## Scope-Expansion Rule

An accepted response is scope-expanding when it introduces any of:

- a new top-level module
- a new external dependency
- a public API change
- a persistent data or schema change
- a new cross-module abstraction
- changes outside frozen target locations
- a broad testing, logging, infrastructure, migration, or consistency program

A scope-expanding response requires relevant E0 or E1 authority, or an E2/E3
fact that makes the change unavoidable within the frozen objective. E4 reasoning
alone is insufficient. When authority is missing, stop with
`evidence-insufficient` or `user-decision-required`.

## Closure Rules

- Default automatic review budget is two completed rounds: initial and focused
  closure.
- Accepted blocking findings may receive the one focused closure review only
  after the review governor authorizes it.
- Rejected blocking findings require especially strong evidence.
- Deferred major findings should include a clear owner, future location, or
  follow-up path.
- A report with untriaged findings is not closed.
- A closure review must not reopen unrelated baseline risks as new blockers.
- If blockers remain after Round 2, the workflow is not allowed to start Round 3
  automatically.
- Repeated failure classes, non-decreasing blocker counts, or net blocker growth
  require a convergence reflection and rollback evaluation.
- A third or later round requires explicit user approval recorded before that
  round begins.
- A final user response must not claim completion while closure status is
  blocked.
