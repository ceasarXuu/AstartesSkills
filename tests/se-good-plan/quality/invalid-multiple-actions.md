<!-- expected-error: multiple primary actions are coupled -->
# Invalid Multiple Actions

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|
| W1 | Change locale persistence | data | db/migrations/042_account_locale.sql | accounts.locale | Add the locale column and update the backfill job | Schema and historical rows change together | Apply the migration and compare all migrated rows | Restore the database snapshot | planned |
