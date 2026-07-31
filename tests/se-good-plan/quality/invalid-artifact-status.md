<!-- expected-error: production-code state applied to planning artifact -->
# Invalid Artifact Status

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|
| W1 | Define locale compatibility | design | docs/design/account_locale.md | null-locale rule | Add the compatibility decision and examples | Old clients retain existing behavior | Review the decision against current client contracts | Remove the draft before implementation starts | planned |

## Planning Artifacts

| Artifact | Kind | Expected Output | Status |
|---|---|---|---|
| Locale compatibility design | design | Null handling and client compatibility rules | runtime-verified |
