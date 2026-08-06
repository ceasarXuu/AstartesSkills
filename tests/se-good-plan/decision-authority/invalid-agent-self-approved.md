<!-- expected-error: baseline decision requires direct user confirmation -->
# Product Decision Baseline

> PROTECTED USER-AUTHORITY ARTIFACT
> Decisions in this file MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.

- Authority: User
- Write Gate: Explicit user approval required
- Agent Self-Approval: Forbidden
- Release Version: v1.2.3
- Topic: account-locale
- Plan: ./plan.md

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| D1 | Locale writes overwrite prior values | Persist the last value | Do not preserve edit history | Simpler implementation | Edit history exists | agent-inferred: implementation and tests already use overwrite semantics | active |
