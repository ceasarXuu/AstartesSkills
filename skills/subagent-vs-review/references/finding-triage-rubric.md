# Finding Triage Rubric

The main agent must respond to every reviewer finding. Use one of three
decisions: `accept`, `reject`, or `defer`.

Adversarial findings are counterexamples against the artifact, not criticism of
the author. Triage must handle the counterexample: prove it impossible, fix it,
or explicitly accept/defer the risk.

## Severity

`blocking`
: The task cannot honestly be considered complete. The issue breaks the product
  goal, invalidates the design, creates unacceptable architecture, security,
  data, release, or operational risk, leaves critical validation missing, or
  counts protocol-only, scaffold-only, mock-only, fake-data-only, demo-only, or
  test-only wiring as completed implementation.
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
  neutral outcome, or regressed outcome is a non-blocking warning because benefit
  tradeoffs require user decision-making and solution design. Do not mark a
  benefit-realization finding as blocking unless the same evidence independently
  proves a correctness, security, data, reliability, or operational failure.

`minor`
: The issue is useful cleanup, clarity, or polish that does not change whether
  the current task is viable.

## Decisions

`accept`
: The finding is valid. The main agent must change the plan, code, tests, logs,
  docs, report, or runbook. Record the broken assumption, action taken, and
  evidence.

`reject`
: The finding is not valid for this task. The main agent must cite concrete
  evidence: code location, test result, log, runtime behavior, product
  constraint, or explicit user instruction. A rejection must defeat the failure
  scenario, not merely restate the main agent's intent.

`defer`
: The finding is valid but outside the current scope. The main agent must state
  why it is not handled now and where it should be tracked. Blocking findings
  should not be deferred unless the user explicitly accepts the risk.

## Closure Rules

- Accepted blocking findings require an additional fresh internal subagent
  review after the fix or response.
- Rejected blocking findings require especially strong evidence.
- Deferred major findings should include a clear owner, future location, or
  follow-up path.
- A report with untriaged findings is not closed.
- A report with accepted blocking findings and no additional review is not
  closed.
- A final user response must not claim completion while closure status is
  blocked.
