<!-- expected-error: plan.md must persist the Execution Contract -->
# Account Locale Engineering Plan

- Release Version: v1.2.3
- Topic Directory: docs/releases/v1.2.3/account-locale
- Decision Baseline: ./decisions.md
- Applicable Decisions: D1
- Mode: Plan Authoring

## Design

Reuse the existing account settings flow and preserve null-compatible reads.

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Store optional locale | data | db/migrations/042_account_locale.sql | accounts.locale | Add a nullable locale field | Existing reads remain compatible | Enables locale support without breaking old accounts | Complexity: adds one nullable field; Reach/Cost: database deployment coordination increases while reads remain unchanged | Apply migration in staging and inspect schema | Reverse before writes | planned |
