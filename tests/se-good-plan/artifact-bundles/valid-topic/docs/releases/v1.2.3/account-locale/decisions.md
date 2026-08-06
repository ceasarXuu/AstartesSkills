# Product Decision Baseline

> PROTECTED USER-AUTHORITY ARTIFACT
> Decisions in this file MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.
> Agent inference, implementation, tests, reviews, existing documents, or lack
> of user objection are not approval.

- Authority: User
- Write Gate: Explicit user approval required
- Agent Self-Approval: Forbidden
- Release Version: v1.2.3
- Topic: account-locale
- Plan: ./plan.md

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | Account locale remains optional for existing accounts | Preserve null-compatible reads during rollout | Do not require a backfill before API and client adoption | Existing accounts must remain usable without coordinated migration | Any existing null-locale account fails an unchanged read path | user-confirmed-direct: "keep existing accounts compatible without mandatory backfill" | active |
| D2 | Locale editing uses the existing account settings flow | Reuse the current update endpoint and settings form | Do not add a separate locale service or account subsystem | The feature should not create a parallel ownership or support path | A new service, endpoint family, or account identity model appears | user-confirmed-direct: "reuse the existing account settings flow" | active |
