# Core Logic Walkthrough

## Core Files

| File | Role | Why It Matters |
| --- | --- | --- |
| `registry/skills.json` | Repository catalog and packaging source of truth | Every install/export/validation path depends on it being accurate |
| `scripts/install-skill.sh` | Copies one or more selected skills into a target skills directory | Defines the repo's installation contract |
| `scripts/validate-repo.sh` | Checks structural integrity between local folders and registry metadata | Prevents broken packaging state from landing silently |
| `scripts/export-marketplace.py` | Builds normalized marketplace artifacts under `dist/` | Converts authoring-time skill metadata into distribution-time outputs |
| `scripts/list-skills.sh` | Lists local skill directories | Small but useful orientation tool for users and maintainers |
| `scripts/test-repo.sh` | Smoke-tests one representative skill path | Shows intended verification shape, but currently only covers one skill |
| `.github/workflows/validate.yml` | Runs validation in CI on push and PR | Makes structural checks automatic |

## Workflow 1: Install A Skill

Central file: `scripts/install-skill.sh`

Control flow:

1. Parse optional `--repo` and `--target` arguments plus one or more skill ids.
2. If `--repo` is provided, clone that repository into a temp directory.
3. Resolve `repo_root` either to the temp clone or the current local repository.
4. For each requested skill:
   - build `source_dir="$repo_root/skills/$skill"`
   - fail if the directory is missing
   - fail if `SKILL.md` is missing
   - replace any existing destination directory
   - copy the entire skill folder only
5. Print `[install]`-prefixed logs for operator clarity.

Important assumption:

- installed artifacts are just copied skill folders, so a skill must be self-contained enough to work after being detached from the repo

## Workflow 2: Validate The Repository

Central file: `scripts/validate-repo.sh`

Control flow:

1. Verify that `skills/` and `registry/skills.json` exist.
2. Parse the registry with Python's `json` module.
3. Scan every direct child directory of `skills/` except `_templates`.
4. Assert that each local skill has both `SKILL.md` and `agents/openai.yaml`.
5. Extract each registry `path` with `sed` and assert the directory exists.
6. Extract each declared market manifest and parse it as JSON with Python.
7. Exit on the first mismatch.

Why this logic is central:

- it is the main guard against content drift between the filesystem and the registry
- a broken registry entry will fail here before export or CI goes further

Example of what it catches:

- a skill listed in `registry/skills.json` but missing on disk
- a missing `agents/openai.yaml`
- malformed market JSON

## Workflow 3: Export Marketplace Artifacts

Central file: `scripts/export-marketplace.py`

Control flow:

1. Resolve `repo_root`, `dist/`, and the `openai-compatible` output directory.
2. Load `registry/skills.json`.
3. Create a normalized `catalog` object with a subset of registry fields.
4. For each skill:
   - append a normalized entry to the catalog
   - if an `openai-compatible` manifest exists, load it
   - write that manifest to `dist/markets/openai-compatible/<skill-id>.json`
5. Write `dist/catalog.json`.
6. Print `[export]`-prefixed logs describing each written file.

Why this matters:

- authoring data remains close to each skill
- export logic stays centralized
- marketplace artifacts can be regenerated deterministically from repo state

## Workflow 4: CI Enforcement

Central file: `.github/workflows/validate.yml`

Control flow:

1. Trigger on `push` and `pull_request`
2. Check out the repo
3. Run `./scripts/validate-repo.sh`

This is intentionally narrow. CI guarantees packaging structure, but not deeper smoke tests or behavioral correctness.

## Skill Package Anatomy

The real unit of reuse in this repository is not a script or a registry entry. It is a skill folder with this contract:

- `SKILL.md`: trigger and workflow instructions
- `agents/openai.yaml`: UI-facing metadata
- `markets/...json`: optional external distribution metadata
- optional `references/`, `templates/`, `rubrics/`, `examples/`, `scripts/`, or `assets/`

Good example:

- `skills/show-my-repo/` shows how a richer skill can stay compact at the top level while shipping selective supporting material

Minimal example:

- `skills/hello-world/` shows the irreducible package shape

## Invariants And Coupling Points

### Tight coupling

- `registry/skills.json` must match the actual `skills/` directory layout
- market manifest paths inside the registry must remain accurate
- README skill lists should stay aligned with the registry to avoid user confusion

### Loose coupling

- each skill folder can evolve internally as long as its declared files and paths remain valid
- docs under `docs/` guide maintainers but are not runtime dependencies for installation

## Current Limitations

- `scripts/test-repo.sh` hardcodes one skill id instead of testing a set of skills or all registry entries
- validation uses shell text extraction with `sed`, which is workable here but fragile if the JSON shape changes significantly
- the repository currently relies on human discipline to keep docs, registry, and examples synchronized
