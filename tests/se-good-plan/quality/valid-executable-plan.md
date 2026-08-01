# Valid Executable Plan

- Mode: Plan Authoring

## Problem And Target

Add account locale support by changing existing schema, API, and UI paths in
separate units without introducing a provider framework or new dependency.

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Store account locale | data | db/migrations/042_account_locale.sql | accounts.locale | Add a nullable locale column without changing reads | Existing reads remain compatible and the field exists | Enables later API and client rollout without breaking existing accounts | Complexity: +1 nullable field and migration artifact, no new runtime branch; Reach/Cost: database deployment and rollback coordination increase while read paths and query cost stay unchanged | Apply migration in staging and inspect schema | Reverse before locale writes | planned |
| W2 | Accept locale updates | API | src/account/update_account.ts | updateAccountLocale() | Add validation and persistence for locale | Valid locale values persist through the existing endpoint | Keeps locale rules consistent and prevents invalid account data | Complexity: +1 validation/persistence branch using existing handler structure, no new abstraction or dependency; Reach/Cost: account API and contract-test scope increase with negligible runtime cost | Run contract tests for valid and invalid values | Disable locale field handling | planned |
| W3 | Expose locale control | client | web/settings/LocaleField.tsx | LocaleField | Wire the control to the existing account update endpoint | Users can view and update locale | Lets users manage locale without support intervention | Complexity: +1 UI integration path using existing form components and feature flag; Reach/Cost: web bundle, component/E2E tests, support documentation, and client release are affected | Run component and settings-flow E2E tests | Hide through existing feature flag | planned |

## Planning Artifacts

| Artifact | Kind | Expected Output | Status |
|---|---|---|---|
| Locale compatibility note | design | Null handling for old clients | planned |
