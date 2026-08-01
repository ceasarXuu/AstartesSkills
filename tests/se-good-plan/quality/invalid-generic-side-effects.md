<!-- expected-error: side effects are missing or too generic -->
# Invalid Generic Side Effects

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Add locale validation | API | src/account/update_account.ts | updateAccountLocale() | Add validation for supported locale values | Invalid locale values are rejected before persistence | Prevents invalid account data and reduces support diagnosis time | Minimal impact | Run supported/unsupported contract tests | Disable locale handling | planned |
