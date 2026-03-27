# summary-my-repo Design

## Goal

Add an installable skill that produces an internal engineering summary pack for any repository so a new collaborator can quickly understand:

- what the project is
- how the top-level directories are organized
- which files contain the core logic
- how the main workflows actually run
- which invariants and risks matter during future changes

## Design

Ship `summary-my-repo` as a self-contained skill with:

- a concise `SKILL.md` that defines trigger conditions, evidence discipline, workflow, and output contract
- a small `rubrics/coverage-checklist.md` so the summary does not skip directory responsibilities, control flow, or key files
- `templates/` for a multi-file markdown output pack instead of a single oversized summary
- a default write-to-disk contract under repo-root `summary-my-repo/YYYY-MM-DD-vN/`

## Output Shape

The default artifact is a versioned markdown pack:

- `summary-my-repo/YYYY-MM-DD-vN/00-overview.md`
- `summary-my-repo/YYYY-MM-DD-vN/01-directory-map.md`
- `summary-my-repo/YYYY-MM-DD-vN/02-core-logic.md`

This shape is intentionally internal-facing:

- `00-overview.md` explains repo purpose, architecture, major flows, and reading order
- `01-directory-map.md` explains the directory tree and responsibility boundaries
- `02-core-logic.md` explains the most important files, workflows, and code paths

## Decisions

- Keep this skill separate from `show-my-repo` because the goals differ: `show-my-repo` packages a repo outwardly, while `summary-my-repo` optimizes for onboarding and engineering comprehension
- Prefer a versioned output folder because repo summaries are living artifacts and should be comparable across runs
- Make “core logic coverage” a first-class requirement so the summary does not collapse into a shallow directory listing
- Require evidence-backed claims and explicit marking of inference so the summary stays technically trustworthy
