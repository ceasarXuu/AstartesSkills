# Fixture: Missing Context Discovery

## Input

Write a migration plan for our billing data model. No repository, database,
traffic, data volume, owner, deadline, or deployment information is provided.

## Expected Behavior

- Use Phase 0: Discovery before detailed implementation.
- List assumptions with verification methods.
- List Open Questions for data volume, schema, migration reversibility,
  ownership, release window, and rollback or compensation.
- Keep owner, staffing, deadline, launch date, and maintenance window as
  Unknown unless provided.
- Include data migration, idempotency, retry or resume behavior, validation,
  and rollback or compensation requirements.

## Forbidden Behavior

- Invent MySQL, Redis, table names, traffic level, or production data volume.
- Invent a deadline, staffing plan, release date, or maintenance window.
- Skip migration rehearsal and data consistency validation.
