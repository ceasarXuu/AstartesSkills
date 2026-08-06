<!-- expected-error: decisions.md must declare protected user authority -->
# Product Decision Baseline

- Release Version: v1.2.3
- Topic: account-locale
- Plan: ./plan.md

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | Account locale remains optional | Preserve null-compatible reads | Do not require backfill before rollout | Existing accounts remain compatible | Null-locale reads fail | user-confirmed-direct: "keep existing accounts compatible" | active |
