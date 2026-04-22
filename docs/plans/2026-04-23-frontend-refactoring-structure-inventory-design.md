# frontend-refactoring Structure Inventory Update

## Goal

Strengthen `frontend-refactoring` so agents must create a style-agnostic inventory of the legacy page before writing migration code.

## Design

Update the skill so the workflow begins with a structure-first pass over the old frontend:

- read the page without trusting legacy styles
- list structural regions in order
- list all existing reusable and functional components
- list key states and interactions
- mark what must not be invented during refactor without approval

## Decisions

- Make the structure inventory a mandatory workflow step rather than optional advice
- Use the inventory as the migration baseline so visual refactors do not silently break page structure
- Explicitly forbid dropping existing functional components or adding out-of-scope components during a redesign unless the user approves
- Reflect the new rule in skill metadata so the triggering summary stays aligned with the workflow
