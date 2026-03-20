# AstartesSkills

A curated multi-skill library for AI coding agents.

This repository is a collection of standalone skills, not a single skill. Each skill is designed to be:

- installable directly from GitHub
- discoverable by the `skills` CLI / `skills.sh` ecosystem
- publishable to skill marketplaces with minimal extra work

Current repository: [ceasarXuu/AstartesSkills](https://github.com/ceasarXuu/AstartesSkills)

## Why This Repo Exists

Most skill repositories solve one of two problems well:

- authoring skills locally
- publishing skills to a marketplace

This repo is designed to handle both.

The model is simple:

- each skill is self-contained under `skills/<skill-id>/`
- the repo provides a unified registry and tooling
- installation should work whether the user comes from `skills.sh`, raw GitHub, or a local clone

## Quick Start

### Install with `skills` CLI

List available skills in this repository:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills --list
```

Install one skill from this repository:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills --skill ornn-coding-governor
```

Install for a specific agent:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills \
  --skill ornn-coding-governor \
  --agent codex
```

Install globally without prompts:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills \
  --skill ornn-coding-governor \
  --agent codex \
  --global \
  --yes
```

### Install with the repository script

Clone locally, then install by copying the skill folder:

```bash
./scripts/install-skill.sh ornn-coding-governor
```

Install to a custom destination:

```bash
./scripts/install-skill.sh --target ~/.codex/skills ornn-coding-governor
```

Install directly from GitHub without cloning first:

```bash
curl -fsSL https://raw.githubusercontent.com/ceasarXuu/AstartesSkills/main/scripts/install-skill.sh \
  | bash -s -- --repo https://github.com/ceasarXuu/AstartesSkills.git ornn-coding-governor
```

## skills.sh Compatibility

This repository is structured to work with the open `skills` CLI ecosystem.

Relevant compatibility points:

- skills are stored under `skills/`, which is one of the standard discovery locations
- every installable skill includes a `SKILL.md` with required YAML frontmatter
- each skill remains independently installable from the repository

Verified repository commands:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills --list
npx skills add https://github.com/ceasarXuu/AstartesSkills --skill ornn-coding-governor
```

Reference:

- [skills.sh docs](https://skills.sh/docs)
- [skills CLI reference](https://skills.sh/docs/cli)
- [vercel-labs/skills](https://github.com/vercel-labs/skills)

## Available Skills

| Skill | Purpose | Install |
| --- | --- | --- |
| `ornn-coding-governor` | Prevent iterative quality decay during AI-assisted coding by enforcing analysis, minimal change planning, strict review, and entropy control. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill ornn-coding-governor` |
| `hello-world` | Minimal example skill used to validate structure, install flow, and export flow. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill hello-world` |

## Repository Layout

```text
.
├── skills/                         # Standalone skills
│   ├── _templates/                 # Reusable skill templates
│   ├── hello-world/                # Example skill
│   └── ornn-coding-governor/       # First real AI coding skill
├── registry/                       # Repository-level catalog
├── scripts/                        # Install, export, test, validate tooling
├── docs/
│   ├── plans/                      # Design docs
│   ├── runbooks/                   # Reusable operational knowledge
│   └── tobeSkills/                 # Draft skill ideas not yet shipped
└── .github/workflows/              # CI validation
```

## Skill Contract

Each installable skill should look like this:

```text
skills/<skill-id>/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── markets/
│   └── openai-compatible.json
├── references/                     # Optional
├── scripts/                        # Optional
└── assets/                         # Optional
```

Required:

- `SKILL.md`

Strongly recommended:

- `agents/openai.yaml`
- `markets/<market>.json`

Design rule:

- keep each skill self-contained so it can be copied, exported, or published independently

## Registry And Export Model

Repository-wide discovery is defined in [registry/skills.json](/Volumes/XU-1TB-NPM/projects/AstartesSkills/registry/skills.json).

It is the source of truth for:

- skill id
- skill path
- summary
- tags
- GitHub source location
- market export metadata

Export normalized marketplace artifacts with:

```bash
./scripts/export-marketplace.py
```

This writes:

- `dist/catalog.json`
- `dist/markets/openai-compatible/*.json`

The point of this layer is to keep authoring simple while still supporting future marketplace pipelines.

## Development Workflow

### Add a new skill

1. Copy `skills/_templates/basic-skill`
2. Rename the folder to the final skill id
3. Write `SKILL.md`
4. Fill `agents/openai.yaml`
5. Fill `markets/openai-compatible.json` if the skill should be distributed externally
6. Register the skill in `registry/skills.json`
7. Validate and export

```bash
./scripts/validate-repo.sh
./scripts/test-repo.sh
./scripts/export-marketplace.py
```

### Validate the repository

```bash
./scripts/validate-repo.sh
```

Checks currently include:

- registry JSON parses correctly
- every installable skill has `SKILL.md`
- every installable skill has `agents/openai.yaml`
- registry paths exist
- declared market manifests are valid JSON

### Smoke test the first real skill

```bash
./scripts/test-repo.sh
```

This verifies that `ornn-coding-governor` is:

- present in the repository
- registered correctly
- exportable

## Publishing Strategy

Recommended publishing flow:

1. Draft or refine a skill idea under `docs/tobeSkills/` if needed
2. Convert it into a self-contained package under `skills/`
3. Register it in `registry/skills.json`
4. Validate and export
5. Push to GitHub
6. Publish to marketplaces from exported metadata when required

This avoids locking the library to a single marketplace while keeping each skill portable.

## Operational Principles

This repository follows a few strict rules:

- small-topic commits over large ambiguous commits
- log-driven tooling and reusable runbooks
- direct fixes over bypasses
- shipped skills should be concise, installable, and independently publishable

Operational notes are recorded in:

- [docs/runbooks/operational-notes.md](/Volumes/XU-1TB-NPM/projects/AstartesSkills/docs/runbooks/operational-notes.md)
- [docs/runbooks/market-publishing.md](/Volumes/XU-1TB-NPM/projects/AstartesSkills/docs/runbooks/market-publishing.md)

## Current Status

Implemented:

- repository bootstrap
- GitHub direct-install script
- registry and export scaffolding
- `skills.sh`-compatible repository layout
- first real skill: `ornn-coding-governor`

Planned next:

- more AI coding skills
- a `new-skill` generator script
- richer validation for metadata consistency
- marketplace-specific exporters beyond the current normalized manifest
