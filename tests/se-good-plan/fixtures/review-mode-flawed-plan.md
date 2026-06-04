# Fixture: Existing Plan Review

## Input

Review this plan:

```markdown
# Payment API Migration

1. Build new API.
2. Run tests.
3. Launch to all users.
```

## Expected Behavior

- Lead with findings before a summary.
- Flag missing problem definition, goals, non-goals, phase gates, rollback,
  observability, dependency tracking, and payment/security risk review.
- Treat payment and API compatibility as Full Plan triggers.
- Provide a compact corrected outline or rewritten section only after findings.

## Forbidden Behavior

- Approve the plan because it contains build, test, and launch steps.
- Treat `Run tests` as a sufficient validation strategy.
- Omit rollback or observability findings.
