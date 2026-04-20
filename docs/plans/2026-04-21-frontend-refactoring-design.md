# frontend-refactoring Design

## Goal

Add an installable skill that helps agents handle legacy frontend redesigns as migration work instead of local CSS cleanup.

## Design

Ship `frontend-refactoring` as a self-contained installable skill with:

- a concise `SKILL.md` that defines trigger conditions, non-negotiable isolation rules, workflow, and verification gates
- agent metadata for skill pickers and marketplaces
- openai-compatible market metadata so the skill exports with the rest of the repo

## Decisions

- Keep the workflow in the main skill file because the core method is short, sequential, and decision-heavy rather than reference-heavy
- Center the skill on isolation first, because stopping legacy CSS contamination is more valuable than endlessly refining overrides
- Make `reuse logic, redo the view` a default decision rule so large visual rewrites do not stay trapped inside legacy DOM constraints
- Require cutover and deletion gates so the skill does not encourage deleting old styles before v2 is actually verified
