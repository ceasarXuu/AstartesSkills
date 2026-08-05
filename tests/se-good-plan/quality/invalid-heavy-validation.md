<!-- expected-error: shadow implementation rather than minimum sufficient evidence -->
# Invalid Heavy Validation

- Mode: Plan Authoring
- Material Uncertainty: yes

## Pre-Investment Validation

| ID | Critical Assumption | Decision Unlocked | Cheapest Credible Method | Enough Evidence / Not Proven | Budget / Isolation | Stop / Cleanup | Status |
|---|---|---|---|---|---|---|---|
| V1 | The provider supports the required tool-call response format | Whether to invest in provider integration | Prototype Evidence: build the full solution with full production integration, retries, configuration migration, all tool types, and complete observability | enough: the entire feature works end to end; not proven: nothing material | Budget: one full implementation cycle; Allowed: all repository modules; Forbidden: unrelated products | Stop: after the full feature passes; Cleanup/Promotion: keep the prototype as production code | planned |

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Integrate provider tools | API | src/provider/client.ts | sendRequest() | Add tool-call parsing after validation | Tool calls can enter the formal integration path | Enables provider-backed agent tools | Complexity: adds one parser branch; Reach/Cost: provider client and contract tests expand | Run contract tests | Disable tool parsing | deferred |
