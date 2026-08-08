---
name: clear-prd
description: Use when a product, feature, app, website, internal tool, automation, or workflow needs product-logic clarification before implementation. Guides focused multi-round questions and writes a Draft or Ready PRD whose directly confirmed material product decisions can serve as canonical downstream product authority.
---

# Clear PRD

## Purpose

Turn an unclear product request into a reviewed product-requirements document before technical design or implementation.

Keep clarification centered on user goals, experience, interactions, workflow, rules, states, exceptions, and acceptance criteria. Avoid implementation tactics unless a technical choice materially changes user-visible product behavior.

## Output Location

Preserve the repository's existing PRD convention instead of creating a competing one.

Use this precedence:

1. explicit user-requested path;
2. an existing repository PRD location or documentation contract;
3. fallback `prd/YYYY-MM-DD-<short-topic>.md`.

For the fallback only, create `prd/` when missing. If the path already exists, append `-v2`, then `-v3`, and so on. Do not relocate or duplicate an existing PRD solely to match this fallback.

If there is no active project folder or the user asks for inline output, return the PRD inline.

## Use This Skill When

- Product logic is incomplete or layered clarification is needed.
- Important product decisions depend on earlier decisions.
- The user needs a PRD, requirements document, product spec, feature brief, or product definition.

Do not use it for trivial edits, direct bug fixes, pure technical implementation, or a complete PRD that only needs engineering execution.

## Product Authority Contract

A PRD produced or maintained by this skill is the preferred canonical product authority for its scope when the repository uses it as such.

The whole PRD is not automatically user authority. Only directly confirmed **material product decisions** belong in `## Confirmed Product Decisions`.

A material product decision is a choice whose alternatives materially change user-visible behavior, product rules, core domain modeling, lifecycle/state semantics, defaults or automation, user control or reversibility, persistence, permissions or visibility, compatibility, external side effects, or important limits.

Rules:

- Stable decision IDs use `PD1`, `PD2`, and so on.
- Every active row requires direct user confirmation evidence.
- Explicit approval of the specific decision or explicit approval of the reviewed PRD counts; Agent inference does not.
- Agent inference, existing code, tests, reviews, other documents, implementation success, user silence, or a generic "continue" do not count as confirmation.
- Allowed statuses are `active` and `superseded`.
- Replacing an active decision requires explicit user approval; preserve the old row as `superseded`.
- Unconfirmed choices stay under `Open Questions And Risks`; never promote them into the confirmed table.
- Downstream engineering artifacts should reference these decision IDs instead of copying the decisions into another authority document.

Use this protected section:

```markdown
## Confirmed Product Decisions

> PROTECTED USER-AUTHORITY SECTION
> Rows in this section MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.
> Agent self-approval is forbidden.

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| PD1 | ... | ... | ... | ... | ... | user-confirmed-direct: ... | active |
```

Do not fill this table with minor wording choices or ordinary engineering details. It is a compact execution authority layer, not a second copy of the PRD body.

## Clarification Workflow

### 1. Frame The Request

Restate:

- target user or operator;
- problem or job to solve;
- desired outcome;
- likely product surface;
- obvious unknowns.

Start broad when the request is vague. Do not ask downstream detail before upstream choices are stable.

### 2. Move Top-Down

Use these modules as needed:

1. Product goal and success definition
2. Users, roles, and usage context
3. Scope, non-goals, and launch slice
4. Core scenarios and user journey
5. Interaction model and information structure
6. Rules, permissions, lifecycle, and constraints
7. Edge cases, empty states, errors, and recovery
8. Content, data meaning, and terminology
9. Acceptance criteria and open risks

### 3. Ask In Structured Rounds

Group questions by dependency layer. Prefer 3-6 questions only after goal and scope are stable; otherwise ask 1-2 highest-leverage questions.

When a meaningful tradeoff exists, offer product-level A/B/C options, mark the recommended option with a short product reason, and allow a custom answer. Avoid disguising React/Vue, database, protocol, deployment, or library choices as product questions.

Partial answers are acceptable. Treat skipped or uncertain answers as open questions, not consent to the recommendation.

### 4. Track Decisions Between Rounds

After each response:

1. extract directly confirmed decisions;
2. extract exceptions and constraints;
3. keep unanswered or contradictory items open;
4. identify what is now unlocked;
5. ask the next dependent round.

When a custom answer mixes a decision and exception, restate the interpretation before relying on it.

### 5. Decide Completion State

A PRD may be `Ready for implementation` only when blocking product decisions are resolved and acceptance criteria are sufficient to judge implementation behavior.

If material decisions remain open, use `Status: Draft` and list them explicitly. Do not treat Draft status as authority for unresolved choices.

## PRD Document Contract

Use this shape unless the repository already has a compatible PRD structure or the user asks for another format:

```markdown
# PRD: <product or feature name>

- Status: Draft | Ready for implementation
- Created: <YYYY-MM-DD>
- Updated: <YYYY-MM-DD>
- Owner / requester: <name or unknown>
- Source request: <one-sentence summary>
- Product Authority: Confirmed Product Decisions section

## Requester Review Summary

- Key decisions:
- Important exceptions:
- Must-confirm before implementation:
- Status reason:

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
## Confirmed Product Decisions

> PROTECTED USER-AUTHORITY SECTION
> ...

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|

## 12. Open Questions And Risks
## 13. Implementation Notes
```

Keep `Implementation Notes` limited to product-driven constraints such as privacy, auditability, latency expectations, offline expectations, integration boundaries visible to users, or regulation. Do not turn the PRD into a technical design.

## Acceptance Criteria Style

Prefer user-observable criteria:

- Given <context>, when <action>, then <observable result>.
- Cover important empty, invalid, permission, cancellation, retry, and recovery states.
- Include usability and understandability where relevant.

## Supporting Reference

Use `references/interaction-fixtures.md` when calibrating partial replies, custom choices, or overloaded users.

## Final Response

When the PRD is produced, state:

- where it was written or that it is inline;
- whether it is Draft or Ready;
- which product decisions remain open;
- which exact items need requester sign-off;
- the next recommended step.
