# Clear PRD Interaction Fixtures

Use these fixtures to validate that `clear-prd` handles realistic clarification
turns without pretending partial answers are complete decisions.

## Partial Reply Downshift

### User Request

```text
I want an internal tool for approving creator payouts.
```

### Agent Round

The agent asks only 1-2 highest-leverage questions because the request is still
broad.

### User Reply

```text
1B, not sure on the approval scope yet.
```

### Expected Agent Handling

- Confirmed decisions:
  - The user selected option B for question 1.
- Exceptions:
  - none
- Open questions:
  - Approval scope remains unresolved.
- Next behavior:
  - Downshift to one follow-up question about approval scope before asking
    detailed rule, notification, or reporting questions.

## Custom Answer Normalization

### User Reply

```text
Mostly B, but admins can bypass it only for urgent cases.
```

### Expected Agent Handling

- Confirmed decisions:
  - Base direction is option B.
- Exceptions:
  - Admin bypass exists only for urgent cases.
- Open questions:
  - Define who counts as admin.
  - Define what qualifies as urgent.
  - Decide whether bypass requires audit logging or later review.
- Next behavior:
  - Restate the decision and exception before unlocking downstream modules.
