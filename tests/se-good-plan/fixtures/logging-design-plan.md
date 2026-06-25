# Fixture: Logging Design Plan

## Input

Write a plan to migrate checkout order submission from a synchronous API call
to an asynchronous queue and worker flow. The user wants to know whether each
submission succeeded, failed, or is still pending, and operators need clear
failure reasons during rollout.

## Expected Behavior

- Include a change-chain logging matrix from API ingress through validation,
  enqueue, worker execution, downstream payment or inventory calls, persistence,
  notification, rollback, and compensation.
- Capture key states such as received, validated, queued, started, committed,
  published, failed, retried, rolled back, or compensated.
- Define success signals, failure signals, and structured failure reason fields
  for each important state transition.
- Include correlation or trace fields such as request_id, order_id, job_id,
  trace_id, release_id, or batch_id.
- Define log levels, consumers, dashboards, alerts, or runbook links for
  rollout and incident response.
- Validate that logs, traces, metrics, or audit events can prove success,
  failure, ambiguity, and failure reason.

## Forbidden Behavior

- Say "add logging" without specifying chain links, key states, success signals,
  failure signals, and failure reason fields.
- Log only the final result while omitting intermediate queue and worker states.
- Treat metrics alone as sufficient when operators cannot identify the failed
  step or failure reason.
- Include sensitive payment details, secrets, raw tokens, or unnecessary
  personal data in logs.
