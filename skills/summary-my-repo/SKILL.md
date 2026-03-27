---
name: summary-my-repo
description: Use when the user wants an internal repository summary that captures architecture, directory responsibilities, core code paths, and key logic so other engineers can understand the project quickly.
---

# summary-my-repo

## Purpose

Turn a repository into an internal engineering summary pack.

This skill is for fast project onboarding, architecture digestion, and codebase orientation. It should explain the structure and logic of the repo without collapsing into a shallow tree dump.

## Use This Skill When

- the user wants to summarize a repository for future collaborators
- the user wants architecture notes plus a readable directory map
- the user wants the most important files and logic paths explained
- the user wants a markdown pack written into the repository for later reuse

## Do Not Use This Skill When

- the user wants outward-facing product packaging, investor messaging, or GTM framing
- the user only wants a code review or bug fix
- the repository is so incomplete that core logic cannot be identified from evidence

## Non-Negotiable Rules

- Do not stop at listing directories. Explain responsibility boundaries.
- Do not stop at naming files. Explain what each critical file actually does.
- Do not claim architecture that the code does not support.
- Clearly separate `implemented`, `inferred`, `planned`, and `risk`.
- Prefer a small number of dense, high-signal markdown files over one giant unfocused document.
- Preserve important logic even when compressing. Omit repetition, not substance.

## Workflow

### 1. Establish the repo shape

Determine:

- project name
- repo purpose
- top-level directory roles
- main entry docs
- core scripts, services, packages, or applications
- validation or CI shape

### 2. Prepare the output folder

Before writing the final answer, create or reuse the repo-root output directory:

- root output directory: `summary-my-repo/`
- run output directory: `summary-my-repo/YYYY-MM-DD-vN/`

Default output files:

- `summary-my-repo/YYYY-MM-DD-vN/00-overview.md`
- `summary-my-repo/YYYY-MM-DD-vN/01-directory-map.md`
- `summary-my-repo/YYYY-MM-DD-vN/02-core-logic.md`

Versioning rule:

- `YYYY-MM-DD` uses the current local date of the run
- `vN` starts at `v1`
- if `summary-my-repo/YYYY-MM-DD-v1/` already exists, increment to `v2`, then `v3`, and so on

### 3. Read docs first, then verify with code

Start with user-facing docs, maintainer docs, and design notes. Then verify claims with:

- directory structure
- core implementation files
- scripts and automation
- registry or manifest files
- tests and CI
- example artifacts when they meaningfully reveal architecture

### 4. Build the summary pack

Write at least these sections across one or more markdown files:

1. repo purpose and current maturity
2. architecture snapshot
3. directory map with responsibilities
4. core workflows and control flow
5. key files and why they matter
6. invariants, assumptions, and coupling points
7. risks, gaps, or confusing areas
8. recommended reading order

### 5. Emphasize core logic

For the most important files, explain:

- role in the system
- main inputs
- main outputs
- downstream effects
- why the file is central to understanding the repo

When code contains meaningful control flow, summarize the path step by step rather than naming the file only.

## Output Standard

Unless the user asks for a different shape, write a markdown pack to `summary-my-repo/YYYY-MM-DD-vN/` using:

- `templates/00-executive-summary.md`
- `templates/01-directory-map.md`
- `templates/02-core-logic.md`

Read `rubrics/coverage-checklist.md` before finalizing to ensure the pack covers architecture, directories, workflows, invariants, and risks.

If the user also wants an inline answer, provide only a short summary and point to the generated files.
