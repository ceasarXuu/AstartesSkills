# summary-my-repo Code Evidence Upgrade Design

## Goal

Upgrade `summary-my-repo` so outputs contain necessary core code evidence, not prose-only summaries.

## Problem

The existing summary format explained architecture and workflow clearly, but did not force code-level proof. This made some conclusions hard to audit and reduced trust for maintainers who need concrete verification.

## Design

Evolve the skill contract from three documents to four:

1. `00-overview.md`
2. `01-directory-map.md`
3. `02-core-logic.md`
4. `03-code-evidence.md`

Add mandatory code-evidence rules:

- Every core workflow claim must map to at least one snippet.
- Every snippet must include path plus line range.
- Every snippet must include a short interpretation.
- `02-core-logic.md` must reference snippet ids from `03-code-evidence.md`.

## Decisions

- Keep snippets concise (prefer 8-40 lines) to avoid dumping full files.
- Use a dedicated evidence document to keep overview and logic docs readable.
- Upgrade checklist and templates together so execution quality follows the new contract by default.
