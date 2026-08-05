<!-- expected-error: material uncertainty requires bounded pre-investment validation -->
# Invalid Missing Pre-Investment Validation

- Mode: Plan Authoring
- Material Uncertainty: yes

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Replace the external protocol path | API | src/provider/client.ts | sendRequest() | Replace the current request format with the undocumented beta format | All provider traffic uses the new beta format | Enables the requested provider capability if the beta contract is compatible | Complexity: replaces one protocol path and may require follow-up error branches; Reach/Cost: every provider caller, contract test, and production request is affected | Run one provider integration test | Revert the request formatter | planned |
