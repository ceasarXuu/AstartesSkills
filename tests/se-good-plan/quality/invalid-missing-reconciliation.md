<!-- expected-error: verified material phase requires evidence reconciliation before continuing -->
# Invalid Missing Reconciliation

- Mode: Execution Tracking

## Execution Tracking

| Work Unit | Execution Status | Evidence | Missing Evidence | Decision |
|---|---|---|---|---|
| W3 | verified | Production traces show the canary group reaches v2 without compatibility failures | Performance behavior for larger callers remains unknown | proceed |
