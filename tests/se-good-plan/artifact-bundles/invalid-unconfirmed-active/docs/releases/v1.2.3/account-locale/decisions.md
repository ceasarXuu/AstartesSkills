# Product Decision Baseline

- Release Version: v1.2.3
- Topic: account-locale
- Plan: ./plan.md
- Status: Active

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | Account locale remains optional for existing accounts | Preserve null-compatible reads during rollout | Do not require a backfill before API and client adoption | Existing accounts must remain usable without coordinated migration | Any existing null-locale account fails an unchanged read path | agent-inferred from repository patterns | active |
| D2 | Locale editing uses the existing account settings flow | Reuse the current update endpoint and settings form | Do not add a separate locale service or account subsystem | The feature should not create a parallel ownership or support path | A new service, endpoint family, or account identity model appears | user-confirmed: technical scope review | active |
