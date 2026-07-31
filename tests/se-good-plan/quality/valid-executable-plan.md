# Valid Executable Plan

- Mode: Plan Authoring

## Problem And Target

Add account locale support without coupling schema, API, and client changes into
one implementation block.

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Store account locale | data | db/migrations/042_account_locale.sql | accounts.locale | Add a nullable locale column without changing reads | Existing reads remain compatible and the target field exists | Enables later API and client rollout without breaking existing accounts | Apply the migration in staging and inspect the resulting schema | Reverse the migration before any locale writes occur | planned |
| W2 | Accept locale updates | API | src/account/update_account.ts | updateAccountLocale() | Add validation and persistence for the locale field | Valid locale values persist through the existing endpoint | Keeps locale rules consistent across clients and prevents invalid account data | Run the account contract test for valid and invalid locale values | Disable locale field handling while keeping the nullable column | planned |
| W3 | Expose locale control | client | web/settings/LocaleField.tsx | LocaleField | Wire the control to the existing account update endpoint | Users can view and update their locale setting | Lets users manage locale directly without support intervention | Run the component test and settings-flow end-to-end test | Hide the control through the existing settings feature flag | planned |

## Planning Artifacts

| Artifact | Kind | Expected Output | Status |
|---|---|---|---|
| Locale compatibility note | design | Document null handling for old clients | planned |
