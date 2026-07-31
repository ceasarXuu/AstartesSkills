<!-- expected-error: benefit merely repeats resulting behavior -->
# Invalid Duplicate Benefit

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Add locale validation | API | src/account/update_account.ts | updateAccountLocale() | Add validation for supported locale values | Invalid locale values are rejected before persistence | Invalid locale values are rejected before persistence | Run contract tests for supported and unsupported locale values | Disable locale field handling | planned |
