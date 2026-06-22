# Seeded Defect Oracle

Do not include this file in reviewer navigation packets.

## code/subscription.ts

- Blocking: no idempotency key or duplicate request protection, so repeated renewal can charge twice.
- Blocking: `requestedPlan.priceCents` is trusted from caller input instead of server-owned plan data.
- Blocking: charge can succeed and `savePayment` can fail, leaving paid-but-unrecorded state.
- Blocking: billing profile loading is represented by fixture data and is not wired into the renewal production path.
- Major: test coverage only checks happy path.

## design/remote-terminal-reconnect.md

- Blocking: reconnect and user close/cancel race has no precedence rule.
- Blocking: half-open or stale server session recovery is undefined.
- Blocking: the one-second interruption benefit is claimed without a baseline, measurement method, or flow that can meet it because retries happen every two seconds.
- Major: no diagnostic logs, trace ids, or failure evidence for reconnect loops.
- Major: assumes retry every two seconds is always acceptable and does not define backoff or stop conditions.

## skill/quick-review-skill.md

- Blocking: reviewer reads the main agent summary instead of a fresh neutral navigation packet.
- Blocking: no explicit fresh-session/no-context-inheritance constraint.
- Blocking: no main-agent finding triage with accept/reject/defer.
- Blocking: no additional review after accepted blocking findings.
- Major: output format does not require broken assumption, failure scenario, trigger, impact, or proof needed.
