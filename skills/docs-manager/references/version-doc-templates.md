# Version Document Templates

Use these templates when a repository wants one version directory per app/product version.

## Version PRD: `docs/v<version>/prd.md`

```markdown
# <Project> v<version> Version PRD

- App/Product Version: `<version>`
- PRD Document Version: `<prd-doc-version>`
- Status: draft
- Created: <YYYY-MM-DD>
- Updated: <YYYY-MM-DD>
- Owner / Requester: <owner>
- Source Request: <one sentence>
- Technical Design: `docs/v<version>/technical-design.md`
- Engineering Plan: `docs/v<version>/engineering-plan.md`
- Version Source: `<version-source>`

## PRD Document Version History

| Document Version | Updated | Change |
|---|---|---|
| <prd-doc-version> | <YYYY-MM-DD> | Created v<version> version PRD. |

## Version Goal And Completion Definition

This version PRD is the source of truth for v<version> product scope, version goal, and completion definition. Technical design and engineering plan must derive from this PRD.

### Version Goal

<goal>

### Must Deliver

- <deliverable>

### Done Definition

- <criterion>

## 1. Background And Product Intent

## 2. Goals And Success Criteria

## 3. Users And Usage Context

## 4. Scope

### In Scope

### Out Of Scope

## 5. Core User Journey

## 6. Interaction And Information Design

## 7. Product Rules And State Logic

## 8. Edge Cases, Errors, And Recovery

## 9. Content And Terminology

## 10. Acceptance Criteria

## 11. Review Checklist And Sign-off Questions

## 12. Decision Log

| Topic | Decision | Rationale | Source |
|---|---|---|---|
```

## Technical Design: `docs/v<version>/technical-design.md`

```markdown
# <Project> v<version> Technical Design

- App/Product Version: `<version>`
- Status: draft
- Version PRD: `docs/v<version>/prd.md`
- Version Source: `<version-source>`
- Created: <YYYY-MM-DD>

## 1. Design Goal

This technical design derives from `docs/v<version>/prd.md` and must not redefine v<version> product scope or completion definition.

## 2. Non-goals

## 3. Architecture

## 4. Data And State Model

## 5. Core Flows

## 6. Platform Or Integration Design

## 7. UI Or Interface Modules

## 8. Version And Release Integration

## 9. Privacy, Permissions, And Logging

## 10. Test Strategy

## 11. Implementation Order

## 12. Risks

## 13. Open Questions
```

## Engineering Plan: `docs/v<version>/engineering-plan.md`

```markdown
# <Project> v<version> Engineering Plan

- App/Product Version: `<version>`
- Status: draft
- Version PRD: `docs/v<version>/prd.md`
- PRD Document Version: `<prd-doc-version>`
- Technical Design: `docs/v<version>/technical-design.md`
- Version Source: `<version-source>`
- Created: <YYYY-MM-DD>

## 1. Plan Goal

This engineering plan derives from `docs/v<version>/prd.md` and `docs/v<version>/technical-design.md`; it must not redefine v<version> product scope or completion definition.

## 2. Document Links

| Document | Path | Responsibility | Update Trigger |
|---|---|---|---|
| Version PRD | `docs/v<version>/prd.md` | Product scope, goal, completion definition, acceptance criteria | User-visible requirement or version scope change |
| Technical Design | `docs/v<version>/technical-design.md` | Architecture, module boundaries, platform strategy, risks | Architecture or implementation strategy change |
| Engineering Plan | `docs/v<version>/engineering-plan.md` | Work breakdown, sequencing, gates, status tracking | Execution path or delivery status change |

## 3. Engineering Principles

## 4. Work Breakdown

### Status Overview

| Workstream | Status | Next Step |
|---|---|---|

## 5. Milestones

## 6. Blocking And Non-blocking Inputs

## 7. Status Tracking Rules

## 8. Done Definition Reference

v<version> done definition is maintained in `docs/v<version>/prd.md`.
```
