# 03 Code Evidence Template

Write to:

- `summary-my-repo/YYYY-MM-DD-vN/03-code-evidence.md`

## Purpose

This file is the code-backed proof layer for claims made in `00-overview.md` and `02-core-logic.md`.

## Minimum Requirement

- include at least 3 snippet entries for non-trivial repositories
- include path and line range for every snippet
- keep snippets focused and readable

## Snippet Format

### S01

- File: `path/to/file.ext:start-end`
- Claim: one sentence describing what this snippet proves

```lang
# exact snippet from repository
```

- Interpretation: short explanation of why this code supports the claim

### S02

- File: `path/to/file.ext:start-end`
- Claim:

```lang
# exact snippet from repository
```

- Interpretation:

## Traceability Check

- Every core workflow in `02-core-logic.md` should reference at least one snippet id here.
- If a key claim has no snippet, mark it as `inferred` and explain the gap.
