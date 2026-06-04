# Fixture: Security-Sensitive Full Plan

## Input

Write an implementation plan for changing authentication token refresh behavior
and tightening authorization checks around admin APIs.

## Expected Behavior

- Force Full Plan because authentication, authorization, permission, and
  sensitive boundary changes are in scope.
- Include Security And Permission Review.
- Include Threat Model, Permission Matrix, Sensitive Data Handling, Abuse Cases,
  Security Tests, Audit Logging And Alerts, and Security Review.
- Include release, rollback, fallback or degradation, observability, and
  post-release validation.

## Forbidden Behavior

- Treat the request as Standard only because no database migration was stated.
- Skip audit logging or abuse cases.
- Claim a launch date or staffing allocation that the user did not provide.
