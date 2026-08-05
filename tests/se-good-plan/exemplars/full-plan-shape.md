# Example High-Risk API Migration Plan

- Mode: Plan Authoring
- Plan Depth: Full
- Risk: High
- Material Uncertainty: yes

## Problem And Target

Migrate a production-facing account API while preserving old-client behavior.
Caller inventory and version-routing feasibility are not yet proven, so formal
implementation is gated by bounded evidence rather than a broad prototype.

## Technical Approach

Reuse the existing route file, add one compatibility branch and one v2 handler,
move callers in observable groups, then remove the old path after zero-traffic
evidence. No provider registry, event bus, or new dependency is introduced.

## Pre-Investment Validation

| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
| V1 | The existing route context exposes a stable client-version signal that can select v1 or v2 without redesigning request ingress | Whether to invest in the compatibility branch and v2 handler plan | Sandbox Evidence: use the existing route-test harness to route one v1 fixture and one v2 fixture while keeping application source unchanged | enough: both fixtures select the expected existing or placeholder handler; not proven: v2 handler correctness, production scale, complete client compatibility, observability, or rollout safety | Budget: one disposable test file using existing fixtures and less than one work unit; Allowed: read-only route inspection and isolated test harness code; Forbidden: production route, schema, defaults, deployment configuration, or public abstraction changes | Stop: after both routing assertions pass or the route is shown to lack a stable version signal; Cleanup/Promotion: delete the disposable harness or rewrite it as the formal W1 contract test | planned |

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W0 | Establish the caller baseline | discovery | services/account-api/routes/account.ts | account route callers | Validate the caller inventory from static references and request logs | Migration scope and unknown callers are documented before design closes | Prevents hidden callers from turning migration into an unbounded compatibility incident | Complexity: adds one temporary inventory artifact and no runtime path; Reach/Cost: requires repository and log review but does not affect production behavior or infrastructure cost | Compare repository references with a sampled production route report | Keep migration blocked until inventory review | blocked-on-discovery |
| W1 | Preserve old-client routing | API | services/account-api/routes/account.ts | selectAccountHandler() | Add version-aware routing between existing v1 and new v2 handlers | Existing clients stay on v1 while selected callers can use v2 | Allows migration without coordinated upgrades across existing clients | Complexity: adds one temporary routing branch until W4, with no new framework or dependency; Reach/Cost: account API contracts, route tests, monitoring, and on-call diagnosis gain a second path | Run route contract tests for each supported client version | Route all requests to v1 | planned |
| W2 | Implement new account behavior | internal | services/account-api/handlers/account_v2.ts | handleAccountV2() | Add the target account behavior behind the compatibility route | Requests selected for v2 execute new behavior without changing v1 | Isolates the capability behind a reversible boundary so defects do not affect all callers | Complexity: adds one handler and focused test surface with no new abstraction layer; Reach/Cost: account-api maintenance and runtime profiling include v2 until migration completes | Run handler tests and API integration tests through v2 | Disable v2 selection and leave handler unused | planned |
| W3 | Move one caller group | deployment | deploy/account-api/traffic-rules.yaml | account-v2 caller rule | Route the first named caller group to v2 | Only the selected group uses the new path | Limits blast radius and makes production impact attributable | Complexity: adds one traffic rule with no application-code path; Reach/Cost: deployment configuration, caller-scoped telemetry, release coordination, and on-call observation are affected | Inspect route metrics and trace samples for the group | Restore the previous traffic rule | planned |
| W4 | Remove the retired route | cleanup | services/account-api/routes/account.ts | handleAccountV1() | Remove v1 after approved zero-traffic evidence | The codebase no longer maintains the retired route | Reduces long-term compatibility and maintenance cost after safe retirement | Complexity: removes one route, branch, and dual-path state; Reach/Cost: compatibility-test scope shrinks while rollback temporarily depends on prior artifact retention | Run compatibility tests and confirm zero old-route traffic | Revert cleanup while prior artifact is retained | deferred |

## Planning Artifacts

| Artifact | Kind | Expected Output | Status |
|---|---|---|---|
| Caller inventory | discovery | Named caller groups, versions, and unknowns | planned |
| Compatibility decision | design | Routing rule, fallback, and removal criteria | planned |

## Phases

### Phase 0: Bound The Migration

- Entry condition: V1 is direction-supported and repository plus route telemetry are available
- Work units: W0
- Phase-local evidence: reviewed caller inventory
- Cross-unit side effects: none beyond W0 because this phase changes no runtime code, dependency, configuration, or infrastructure
- Next-phase condition: no unknown caller can silently bypass compatibility

### Phase 1: Build A Reversible Path

- Entry condition: compatibility decision is reviewed
- Work units: W1, W2
- Phase-local evidence: route contracts and v2 integration tests
- Cross-unit side effects: v1 and v2 coexistence temporarily increases runtime paths, regression scope, monitoring, and maintenance until W4 removes v1
- Next-phase condition: rollback to v1 is proven without data repair and phase evidence is reconciled before Phase 2

### Phase 2: Move And Observe Traffic

- Entry condition: reconciled evidence still supports v2 rollout
- Work units: W3
- Phase-local evidence: caller-scoped metrics, traces, and failure reasons
- Cross-unit side effects: dual-path operational burden continues and release plus on-call coordination increases for the observation window
- Next-phase condition: selected caller group meets the observation gate and evidence is reconciled before broader movement

### Phase 3: Cleanup

- Entry condition: reconciled evidence shows all callers migrated and old route has zero traffic for the required window
- Work units: W4
- Phase-local evidence: compatibility tests and zero-traffic report
- Cross-unit side effects: cumulative complexity decreases; rollback temporarily depends on prior artifact retention
- Next-phase condition: none
