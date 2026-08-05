<!-- expected-error: validation budget or isolation is unbounded -->
# Invalid Unbounded Validation

- Mode: Plan Authoring
- Material Uncertainty: yes

## Pre-Investment Validation

| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
| V1 | The provider returns parseable structured tool calls | Whether formal integration should start | Sandbox Evidence: send one isolated real request and inspect the response envelope | enough: one response contains a parseable tool call; not proven: retries, scale, all tools, or production readiness | Budget: as needed; Allowed: any code required; Forbidden: no restrictions | Stop: when confidence feels sufficient; Cleanup/Promotion: decide later | planned |

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Parse provider tools | API | src/provider/client.ts | parseToolCall() | Add structured parsing after validation | Supported responses become tool calls | Enables formal tool integration | Complexity: adds one parser function; Reach/Cost: provider tests and maintenance expand | Run parser contract tests | Remove the parser | deferred |
