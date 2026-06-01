---
name: clear-prd
description: Use when a user brings a new product, feature, app, website, internal tool, automation, workflow, or other product requirement that needs multi-round clarification before implementation. The skill keeps the conversation focused on product logic, user experience, interaction design, rules, edge cases, and acceptance criteria, then writes a Draft or Ready PRD.
---

# Clear PRD

## Purpose

Use this skill to turn an unclear request into a reviewed product-requirements
document before technical design or implementation begins.

The agent should guide the user through multi-round clarification. Questions
must stay centered on product logic: user goals, experience, interactions,
workflow, rules, states, exceptions, and success criteria. Avoid drifting into
frameworks, databases, deployment, libraries, or implementation tactics unless
the technical choice changes a user-visible product decision.

Default PRD output path in an active project folder:

```text
prd/YYYY-MM-DD-<short-topic>.md
```

Create `prd/` when missing. If the default file already exists, write
`prd/YYYY-MM-DD-<short-topic>-v2.md`, then increment `v3`, `v4`, and so on.
If there is no active project folder or the user asks for inline output, return
the PRD inline instead.

## Use This Skill When

- The user asks to design a product, feature, app, website, internal tool,
  automation, or workflow.
- The request is directionally clear but lacks enough product logic to implement
  safely.
- Important decisions depend on earlier decisions and need layered questioning.
- The user needs a PRD, requirements document, product spec, feature brief, or
  product definition that may be `Draft` or `Ready for implementation`.

Do not use this skill for trivial edits, direct code fixes, bug triage, pure
technical implementation tasks, or questions that already provide a complete
PRD and only need execution.

## Non-Negotiable Rules

- Ask before designing when product logic is underspecified.
- Ask top-down: broad goals first, then dependent details.
- Ask by module, not by random checklist.
- Each clarification question must offer A/B/C-style options when a meaningful
  tradeoff exists.
- Every option must represent a real product direction, constraint, or
  tradeoff, not a disguised technical implementation choice.
- Mark the agent's recommended option and explain why in product terms.
- Always allow the user to choose something outside the listed options.
- Do not force premature technical design. Translate technical concerns into
  product impact before asking.
- Keep asking across multiple rounds until blocking product decisions are
  resolved or explicitly marked as open risks.
- Preserve important decisions, exceptions, unresolved items, and rationale in
  the final PRD.

## Clarification Workflow

### 1. Frame The Request

Restate the request as a product intent:

- target user or operator
- problem or job to be solved
- desired outcome
- likely product surface
- obvious unknowns

If the initial request is too broad, start with scope, user, and success
questions only. Do not ask detailed flow, rules, or acceptance questions until
the upstream direction is stable.

### 2. Use A Top-Down Module Tree

Move through these modules in order. Skip modules that are irrelevant, but do
not jump into lower-level details before their parent decisions are settled.

1. Product goal and success definition
2. Users, roles, and real usage context
3. Scope, non-goals, and launch slice
4. Core scenarios and user journey
5. Interaction model and information structure
6. Rules, permissions, state lifecycle, and constraints
7. Edge cases, empty states, errors, and recovery
8. Content, data meaning, and user-facing terminology
9. Acceptance criteria, review checklist, and open risks

### 3. Ask In Structured Rounds

Each round should contain a small set of questions that share the same module
or dependency layer. Prefer 3-6 questions per round only after the goal and
scope are stable.

Use low-friction pacing:

- For vague initial briefs, mobile-style replies, or low-confidence users, ask
  only 1-2 highest-leverage questions.
- If the user answers partially, pause expansion and resolve the unanswered
  blocker before adding new modules.
- If the user asks for speed, reduce the next round to the smallest decision
  set that unlocks progress.

Use this question format:

```markdown
1. <module>: <question>
A. <direction or tradeoff> - <impact>
B. <direction or tradeoff> - <impact>
C. <direction or tradeoff> - <impact>
Recommended: <A/B/C> - <product reason>
Other: You can answer with a custom direction.
```

Tell the user they can answer compactly, for example:

```text
1B, 2 custom: admins can bypass this only for urgent cases, 3 unsure
```

Partial answers are acceptable. Treat skipped or uncertain answers as open
questions, not as consent to the recommended option.

Good options describe product choices:

- first-use simplicity vs expert control
- strict workflow vs flexible workflow
- user-visible transparency vs minimal interruption
- manual confirmation vs automatic action
- narrow launch scope vs broader complete flow
- forgiving rules vs strict enforcement

Bad options are implementation choices unless the user experience depends on
them:

- React vs Vue
- Postgres vs SQLite
- REST vs GraphQL
- serverless vs container
- which package or library to install

### 4. Track Dependencies Between Rounds

After each user response:

1. Extract confirmed decisions.
2. Extract exceptions or custom constraints.
3. List unanswered, uncertain, or contradictory items as open questions.
4. Identify which module is now unlocked.
5. Ask the next dependent round, downshifting to 1-2 questions when ambiguity
   remains high.

Do not ask detailed questions whose answers depend on an unresolved earlier
choice. Example: do not ask notification copy before deciding which events
should notify users.

When a custom answer mixes options and exceptions, restate it before relying on
it:

```text
Decision I heard: <confirmed part>.
Exception: <custom condition>.
Still open: <what must be confirmed before the next module>.
```

### 5. Decide When Clarification Is Complete

Clarification is complete when the agent can write a PRD that answers:

- who the product is for
- what problem it solves
- what is in scope and out of scope
- what the primary user journey is
- what users see, choose, create, edit, confirm, or recover from
- what rules and states govern the experience
- what happens in important empty, error, and edge states
- how the user and agent will know the implementation is correct
- what the requester needs to review or confirm before implementation starts

If high-impact decisions remain open, write the PRD as `Status: Draft` and list
the unresolved decisions under `Open Questions`. Do not pretend the PRD is
implementation-ready.

## PRD Document Contract

Write the PRD in Markdown. Use this structure unless the user requests a
different shape:

```markdown
# PRD: <product or feature name>

- Status: Draft | Ready for implementation
- Created: <YYYY-MM-DD>
- Updated: <YYYY-MM-DD>
- Owner / requester: <name or unknown>
- Source request: <one-sentence summary>

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

- <question the requester should verify before implementation>

## 12. Clarification Decision Log

| Topic | Decision | Rationale | Source Round |
|---|---|---|---|

## 13. Open Questions And Risks

## 14. Implementation Notes
```

Keep `Implementation Notes` limited to product-driven constraints, such as
privacy requirements, auditability, latency expectations, offline expectations,
integration boundaries visible to users, or regulatory constraints. Do not turn
the PRD into a technical design document.

## Acceptance Criteria Style

Write acceptance criteria from user-visible behavior:

- Given <context>, when <action>, then <observable result>.
- Include important empty, invalid, permission, cancellation, retry, and
  recovery states.
- Include review criteria for usability, ease of use, and ease of
  understanding.

## Supporting Reference

When validating or calibrating handling for partial replies, custom choices, or
overloaded users, use `references/interaction-fixtures.md`.

## Final Response

When the PRD is produced, tell the user:

- where the PRD was written, or that it is inline
- whether it is `Draft` or `Ready for implementation`
- which product decisions remain open, if any
- which exact items the requester should review or sign off
- the next recommended step
