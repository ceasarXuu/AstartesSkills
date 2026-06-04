# Fixture: Low-Risk Lightweight Plan

## Input

Write a plan to rename one internal configuration key in a single service. It
does not affect production data and can be reverted by restoring the old key.

## Expected Behavior

- Classify the task as Low complexity.
- Choose Lightweight Plan.
- Keep the plan to 2-3 phases or a compact step list.
- Include Background, Goals, Non-goals, Implementation steps, Acceptance
  criteria, Test plan, and Risks and rollback.
- Avoid Full Plan ceremony unless the user adds production, data, security, or
  cross-system risk.

## Forbidden Behavior

- Generate an 8-phase Full Plan for this narrow change.
- Invent a release date, staffing plan, or maintenance window.
- Omit rollback only because the change is low risk.
