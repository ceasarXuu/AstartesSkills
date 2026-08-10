<!-- expected-error: material Plan Delta ready state requires direct user plan approval -->
# Invalid Agent-Approved Material Plan Delta

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
- User approval: agent-approved: tests prove the new route is better
- Gate status: ready
- Execution status: in-progress

- Entry condition: Phase 1 completed
- Work units: W5

## Plan Delta History

| ID | Before Phase | Previous Plan | Current Fact | Proposed Change | Impact | User Approval | Status |
|---|---|---|---|---|---|---|---|
| R2 | Phase 2 | W4 adds a routing adapter | Phase 1 proved the existing router exposes the selector | Remove W4 and retarget W5 | Less code; verification target changes | agent-approved: tests prove the new route is better | approved-applied |
