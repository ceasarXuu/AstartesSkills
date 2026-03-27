# AstartesSkills Overview

## What This Repository Is

`AstartesSkills` is a multi-skill repository. Its job is not to host one application, but to manage several installable AI skills in one place while keeping each skill independently copyable, publishable, and verifiable.

The repo is built around one core idea:

- each skill lives as a self-contained package under `skills/<skill-id>/`
- the repository adds a shared registry, validation scripts, install scripts, and export tooling around those packages

That means the architecture is half content library and half packaging pipeline.

## Architecture Snapshot

The repo has five important layers:

1. `skills/`: the deployable units
2. `registry/skills.json`: the source-of-truth catalog of installable skills
3. `scripts/`: operational tooling for install, list, validate, smoke test, and export
4. `docs/`: maintainer-facing design notes and reusable operational knowledge
5. `.github/workflows/validate.yml`: CI entrypoint that enforces repo structure

The design intentionally keeps skill content local to each skill, while pushing cross-cutting repository behavior into scripts and the registry.

## Main Workflows

### Add a new skill

The expected path is:

1. copy the template from `skills/_templates/basic-skill/`
2. create the skill package under `skills/<skill-id>/`
3. register it in `registry/skills.json`
4. validate with `./scripts/validate-repo.sh`
5. optionally export market manifests with `./scripts/export-marketplace.py`

### Install a skill

The install path is implemented in `scripts/install-skill.sh`:

1. resolve repo root or clone a remote repo into a temp directory
2. resolve the install target, defaulting to `${CODEX_HOME:-$HOME/.codex}/skills`
3. verify the requested skill folder and `SKILL.md` exist
4. copy only that skill directory into the target

This keeps installation simple and avoids pulling repo-level tooling into the installed artifact.

### Validate the repository

`scripts/validate-repo.sh` is the structural gate:

1. parse `registry/skills.json`
2. check each local skill folder for `SKILL.md` and `agents/openai.yaml`
3. verify that every registry path exists on disk
4. parse each market manifest referenced by the registry

This is why `registry/skills.json` is the most important single file in the repo. If it drifts from the filesystem, validation fails immediately.

### Export marketplace artifacts

`scripts/export-marketplace.py` reads the registry, copies each market manifest into `dist/markets/openai-compatible/`, and writes a normalized `dist/catalog.json`.

In other words:

- authoring happens in each skill folder
- distribution shape is assembled centrally from the registry

## Critical Invariants

- Every installable skill must have `SKILL.md`.
- Every local skill folder must have `agents/openai.yaml`.
- If a registry entry declares `skills/<id>`, that folder must exist.
- If a registry entry declares an `openai-compatible` manifest, that JSON file must parse.
- Repo-level automation should treat each skill folder as the deployable unit, not the whole repo.

## Current Risks And Sharp Edges

- `scripts/test-repo.sh` only smoke-tests `astartes-coding-custodes`, so it does not prove every skill is exportable.
- The README files can drift from the actual contents if a skill is added or removed without updating user docs.
- Because the repo is small, its structural assumptions live mostly in scripts and docs rather than in a richer typed toolchain; maintainers need to keep those aligned manually.

## Recommended Reading Order

1. `AGENTS.md`: maintainer rules and repository operating model
2. `README.md`: user-facing purpose and install model
3. `registry/skills.json`: catalog and packaging source of truth
4. `scripts/validate-repo.sh`: structural enforcement
5. `scripts/install-skill.sh`: install contract
6. `scripts/export-marketplace.py`: distribution/export logic
7. `skills/show-my-repo/`: best example of a richer shipped skill package
