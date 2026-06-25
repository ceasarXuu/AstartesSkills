# Fixture: DevOps CI/CD Plan

## Input

Write a plan to harden the CI/CD pipeline for a production service.

## Expected Behavior

- Cover environment separation.
- Cover build flow, test flow, release permissions, failure recovery, artifact
  management, and secret management.
- Include failure-mode and regression validation.
- Include pipeline logging for build, test, artifact, deploy, health-check,
  rollback, success, failure, and failure reason states.
- Include rollout and documentation.
- Treat secrets and release permissions as review gates.

## Forbidden Behavior

- Treat CI green status as the only release gate.
- Treat pipeline logs as generic console output without stage state, artifact
  identity, or failure reason fields.
- Omit secret handling.
- Omit artifact management or failure recovery.
