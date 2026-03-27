# Directory Map

## Top-Level Tree

```text
.
├── skills/
├── registry/
├── scripts/
├── docs/
├── summary-my-repo/
└── .github/workflows/
```

## Directory Responsibilities

### `skills/`

This is the product payload of the repository. Every installable skill is intended to be copied out of this directory as an independent package.

Important subdirectories:

- `skills/_templates/basic-skill/`: the starter skeleton for new skills
- `skills/astartes-coding-custodes/`: a compact governance-oriented skill with only the essential package files
- `skills/show-my-repo/`: the best current example of a richer skill that ships auxiliary `rubrics/`, `templates/`, and `examples/`
- `skills/summary-my-repo/`: the internal repo-summary skill added in this run
- `skills/hello-world/`: the minimal structural example used for repository/package validation

Maintenance implication:

- add new installable skills here
- keep each skill self-contained
- avoid relying on repo-external files from inside a shipped skill

### `registry/`

`registry/skills.json` is the repository catalog and packaging source of truth.

It defines:

- skill id
- skill display name
- relative path to the skill package
- summary and tags
- source repository coordinates
- market manifest locations

Maintenance implication:

- adding a skill without registering it makes it undiscoverable
- registering a skill with the wrong path breaks validation and export

### `scripts/`

This directory holds the repo-level operations layer.

Files and responsibilities:

- `install-skill.sh`: copy a selected skill to a target skills directory, optionally from a remote git repo
- `list-skills.sh`: list local installable skill folders by scanning `skills/`
- `validate-repo.sh`: enforce packaging invariants between disk layout and registry metadata
- `test-repo.sh`: smoke test one skill and exported artifacts
- `export-marketplace.py`: generate normalized distribution artifacts under `dist/`

Maintenance implication:

- if repo behavior changes, this is where install/validation/export contracts must be updated

### `docs/`

Maintainer knowledge base. It is not shipped as part of installed skills.

Subdirectories:

- `docs/plans/`: design and implementation notes for concrete work items
- `docs/runbooks/`: reusable operational lessons
- `docs/tobeSkills/`: long-form idea drafts that have not yet been compressed into shipped skills

Maintenance implication:

- design intent belongs here, not in end-user README content

### `summary-my-repo/`

This is a runtime artifact directory, not a skill package. It stores generated repository summary packs in versioned subfolders such as `2026-03-27-v1/`.

Maintenance implication:

- treat this as derived documentation
- keep versioned runs so architectural snapshots remain comparable over time

### `.github/workflows/`

Contains CI entrypoints. Right now the repo has a single workflow:

- `validate.yml`: run structural validation on push and pull request

Maintenance implication:

- CI currently checks structure only; deeper smoke tests remain a local maintainer responsibility

## Source Of Truth Vs Derived Output

### Source of truth

- `skills/<skill-id>/`
- `registry/skills.json`
- `scripts/`
- `docs/` for maintainer intent and operational knowledge

### Derived or runtime output

- `dist/` after running export
- `summary-my-repo/<date>-vN/` after running the summary skill

## Where To Change What

- add or modify a shipped skill: `skills/<skill-id>/`
- change repository discovery or market metadata: `registry/skills.json`
- change install/validate/export behavior: `scripts/`
- document maintainer practices or lessons learned: `docs/runbooks/`
- capture one-off design reasoning: `docs/plans/`
