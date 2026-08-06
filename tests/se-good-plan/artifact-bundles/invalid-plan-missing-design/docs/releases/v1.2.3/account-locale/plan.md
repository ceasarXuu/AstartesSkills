# Account Locale Engineering Plan

- Release Version: v1.2.3
- Topic Directory: docs/releases/v1.2.3/account-locale
- Decision Baseline: ./decisions.md
- Applicable Decisions: D1, D2
- Mode: Plan Authoring
- Material Uncertainty: no

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Store optional account locale | data | db/migrations/042_account_locale.sql | accounts.locale | Add a nullable locale column without changing reads | Existing reads remain compatible and the optional field exists | Enables later locale support without breaking existing accounts | Complexity: adds one nullable field and one migration artifact with no new runtime branch; Reach/Cost: database deployment and rollback coordination increase while existing reads and query cost stay unchanged | Apply the migration in staging and inspect the resulting schema | Reverse the migration before locale writes occur | planned |
