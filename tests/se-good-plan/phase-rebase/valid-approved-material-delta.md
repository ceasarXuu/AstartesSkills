# Valid Approved Material Plan Delta

- Mode: Execution Tracking

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
- User approval: user-approved-plan-direct: approve R2 removing the redundant adapter and retargeting rollout verification
- Gate status: ready
- Execution status: in-progress

- Entry condition: Phase 1 route evidence is reconciled
- Work units: W5

## Plan Delta History

| ID | Before Phase | Previous Plan | Current Fact | Proposed Change | Impact | User Approval | Status |
|---|---|---|---|---|---|---|---|
| R2 | Phase 2 | W4 adds a routing adapter before W5 rollout | Phase 1 proved the existing router exposes the required selector and the new adapter would duplicate behavior | Remove W4 and retarget W5 to the existing router | Less code and maintenance; W5 verification target changes | user-approved-plan-direct: approve R2 removing the redundant adapter and retargeting rollout verification | approved-applied |
