<!-- expected-error: Phase cannot execute before Pre-Phase Plan Rebase Gate is ready -->
# Invalid Execute Pending Gate

## Execution Contract

- Before every material phase, rebase remaining work against actual completed implementation and evidence.
- Do not start a Phase while its Pre-Phase Plan Rebase Gate is pending or blocked-on-plan-approval.
- Material Plan Delta requires explicit direct user approval before the approved revision is applied and executed.

## Phases

### Phase 2: Roll Out New Path

#### Pre-Phase Plan Rebase Gate

- Rebase scope: completed implementation + remaining plan
- Material plan delta: pending
- Plan delta record: pending
- User approval: pending-if-material
- Gate status: pending
- Execution status: in-progress

- Entry condition: Phase 1 completed
- Work units: W4, W5
