<!-- expected-error: stale downstream plan cannot continue after material invalidating evidence -->
# Invalid Continue After Evidence Change

- Mode: Execution Tracking

## Execution Tracking

| Work Unit | Execution Status | Evidence | Missing Evidence | Decision |
|---|---|---|---|---|
| W3 | verified | Production traces show the canary works, but load tests fail at the next caller group's concurrency | A replacement performance approach is not selected | pause |

## Phase Reconciliation

| Phase | New Evidence | Affected Assumption / Prior Conclusion | Decision Baseline Impact | Conclusion Update | Downstream Plan Change | Plan Validity | Next Action |
|---|---|---|---|---|---|---|---|
| Phase 2 | Production Evidence: target-concurrency tests exceed the latency budget by four times | Prior conclusion that the current v2 handler could support all planned caller groups | aligned | invalidated: the handler is not viable for the remaining high-volume rollout | no downstream change; keep W4 and W5 exactly as originally planned | needs-revision | continue |
