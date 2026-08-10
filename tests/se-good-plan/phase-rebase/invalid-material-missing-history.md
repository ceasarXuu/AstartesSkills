<!-- expected-error: material Plan Delta requires preserved Plan Delta History -->
# Invalid Material Plan Delta Without History

## Execution Contract

- Before every material phase, rebase remaining work against actual completed implementation and evidence.
- Do not start a Phase while its Pre-Phase Plan Rebase Gate is pending or blocked-on-plan-approval.
- Material Plan Delta requires explicit direct user approval before the approved revision is applied and executed.

## Phases

### Phase 2: Roll Out Existing Router Path

#### Pre-Phase Plan Rebase Gate

- Rebase scope: completed implementation + remaining plan
- Material plan delta: material
- Plan delta record: R2
- User approval: user-approved-plan-direct: approve R2 removing the redundant adapter
- Gate status: ready
- Execution status: in-progress

- Entry condition: Phase 1 completed
- Work units: W5
