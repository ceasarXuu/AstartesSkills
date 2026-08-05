<!-- expected-error: invalid validation state or implementation evidence claim -->
# Invalid Validation Status

- Mode: Plan Authoring
- Material Uncertainty: yes

## Pre-Investment Validation

| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
| V1 | The provider response contains a stable tool-call envelope | Whether formal parsing should be implemented | Sandbox Evidence: send one isolated real request and inspect the response envelope | enough: one stable envelope is observed; not proven: formal integration, scale, retries, or complete compatibility | Budget: one disposable script and two requests; Allowed: scripts/validation only; Forbidden: production client, schema, defaults, deployment, or public abstraction changes | Stop: after success or confirmed incompatibility; Cleanup/Promotion: delete the script and rewrite production parsing formally | implemented |

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Parse provider tools | API | src/provider/client.ts | parseToolCall() | Add structured parsing after validation | Supported responses become tool calls | Enables formal tool integration | Complexity: adds one parser function; Reach/Cost: provider tests and maintenance expand | Run parser contract tests | Remove the parser | deferred |
