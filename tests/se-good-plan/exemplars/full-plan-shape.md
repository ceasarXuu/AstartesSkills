# Example High-Risk API Migration Plan

- Mode: Plan Authoring
- Plan Depth: Full
- Risk: High

## Problem And Target

Migrate a production-facing account API while preserving old-client behavior.
The current caller inventory and exact route ownership are unknown, so the plan
starts with a bounded Discovery unit rather than claiming those facts are known.

## Technical Approach

Introduce a compatibility route, implement the new handler behind that route,
move callers in separately observable groups, and remove the old path only after
runtime evidence shows no remaining traffic. Data, API, rollout, and cleanup are
kept as separate change axes.

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|
| W0 | Establish the caller baseline | discovery | services/account-api/routes/account.ts | account route callers | Validate the caller inventory from static references and request logs | The migration scope and unknown callers are documented before design closes | Prevents hidden callers from turning the migration into an unbounded compatibility incident | Compare repository references with a sampled production route report | Keep the migration blocked until the inventory is reviewed | blocked-on-discovery |
| W1 | Preserve old-client routing | API | services/account-api/routes/account.ts | selectAccountHandler() | Add version-aware routing between the old and new handlers | Existing clients continue using the old handler while selected callers can use the new path | Allows migration to begin without forcing coordinated upgrades across existing clients | Run route contract tests for each supported client version | Route every request back to the old handler | planned |
| W2 | Implement the new account behavior | internal | services/account-api/handlers/account_v2.ts | handleAccountV2() | Add the target account behavior behind the compatibility route | Requests selected for v2 execute the new behavior without changing v1 | Isolates the new capability behind a reversible boundary so defects do not affect all callers | Run handler unit tests and API integration tests through the v2 route | Disable v2 selection and retain the handler unused | planned |
| W3 | Move one caller group | deployment | deploy/account-api/traffic-rules.yaml | account-v2 caller rule | Route the first named caller group to the v2 handler | Only the selected caller group uses the new path | Limits blast radius and makes production impact attributable to one caller group | Inspect route metrics and trace samples for the selected caller group | Restore the previous traffic rule | planned |
| W4 | Remove the retired route | cleanup | services/account-api/routes/account.ts | handleAccountV1() | Remove the old route after zero-traffic evidence is approved | The codebase no longer maintains the retired path | Reduces long-term maintenance and compatibility cost after retirement is proven safe | Run compatibility tests and confirm the observation report shows no old-route traffic | Revert the cleanup commit while the compatibility contract remains available | deferred |

## Planning Artifacts

| Artifact | Kind | Expected Output | Status |
|---|---|---|---|
| Caller inventory | discovery | Named caller groups, client versions, and unknowns | planned |
| Compatibility decision | design | Routing rule, fallback behavior, and removal criteria | planned |

## Phases

### Phase 0: Bound The Migration

- Entry condition: repository and route telemetry are available
- Work units: W0
- Phase-local evidence: reviewed caller inventory
- Next-phase condition: no unknown caller can silently bypass compatibility

### Phase 1: Build A Reversible Path

- Entry condition: the compatibility decision is reviewed
- Work units: W1, W2
- Phase-local evidence: route contracts and v2 integration tests
- Next-phase condition: rollback to v1 is proven without data repair

### Phase 2: Move And Observe Traffic

- Entry condition: v2 is deployable behind the route selector
- Work units: W3
- Phase-local evidence: caller-scoped metrics, traces, and failure reasons
- Next-phase condition: the selected caller group meets the observation gate

### Phase 3: Cleanup

- Entry condition: all caller groups have completed migration and the old route
  has zero traffic for the required observation window
- Work units: W4
- Phase-local evidence: compatibility regression tests and zero-traffic report
- Next-phase condition: none

## Verification And Release

- Correctness: route contracts, handler tests, and API integration tests pass.
- Compatibility: old clients remain on v1 until explicitly selected.
- Observability: route selection, fallback, failure reason, client version, and
  request correlation are visible.
- Rollback: traffic rules return callers to v1 without removing v2 code.
- Cleanup: W4 stays deferred until runtime evidence exists; this draft does not
  mark the phase complete or proceed.
