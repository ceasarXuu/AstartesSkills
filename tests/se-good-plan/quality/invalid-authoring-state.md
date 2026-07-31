<!-- expected-error: execution state used in Plan Authoring -->
# Invalid Authoring State

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|
| W1 | Store account locale | data | db/migrations/042_account_locale.sql | accounts.locale | Add a nullable locale column | The target field exists without changing current reads | Apply the migration in staging and inspect the schema | Reverse the migration before writes | verified |
