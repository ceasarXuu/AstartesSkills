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
npx skills add https://github.com/ceasarXuu/AstartesSkills --skill astartes-coding-custodes
```

Install for a specific agent:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills \
  --skill astartes-coding-custodes \
  --agent codex
```

Install globally without prompts:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills \
  --skill astartes-coding-custodes \
  --agent codex \
  --global \
  --yes
```

Install this repository with the default CLI flow:

```bash
npx skills add https://github.com/ceasarXuu/AstartesSkills
```

### Install with the repository script

Clone locally, then install by copying the skill folder:

```bash
./scripts/install-skill.sh astartes-coding-custodes
```

Install to a custom destination:

```bash
./scripts/install-skill.sh --target ~/.codex/skills astartes-coding-custodes
```

Install directly from GitHub without cloning first:

```bash
curl -fsSL https://raw.githubusercontent.com/ceasarXuu/AstartesSkills/main/scripts/install-skill.sh \
  | bash -s -- --repo https://github.com/ceasarXuu/AstartesSkills.git astartes-coding-custodes
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
npx skills add https://github.com/ceasarXuu/AstartesSkills --skill astartes-coding-custodes
```

Reference:

- [skills.sh docs](https://skills.sh/docs)
- [skills CLI reference](https://skills.sh/docs/cli)
- [vercel-labs/skills](https://github.com/vercel-labs/skills)

## Available Skills

| Skill | Purpose | Install |
| --- | --- | --- |
| `astartes-coding-custodes` | Prevent iterative quality decay during AI-assisted coding by enforcing analysis, minimal change planning, strict review, and entropy control. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill astartes-coding-custodes` |
| `coe-debug` | Track complex debug cases in project-root `/coe` files with strict problem, hypothesis, and evidence nodes. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill coe-debug` |
| `frontend-refactoring` | Refactor legacy frontend surfaces by isolating new UI, rebuilding the view layer when needed, and migrating safely away from polluted style systems. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill frontend-refactoring` |
| `show-my-repo` | Turn a repository into an evidence-backed presentation pack for investors, users, demos, README upgrades, and landing pages. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill show-my-repo` |
| `storybook-skills-standard` | Design and audit Storybook-driven component workflows, story coverage, mocks, docs, interaction tests, accessibility checks, and visual baselines. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill storybook-skills-standard` |
| `summary-my-repo` | Generate an internal repository summary pack with architecture, directory responsibilities, and core logic walkthroughs. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill summary-my-repo` |
| `threejs-game` | Route three.js game work across runtime, assets, rendering, input, physics, animation, performance, networking, tooling, and XR tracks. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game` |
| `threejs-game-animation-character` | Build maintainable character-animation systems with state graphs, clip conventions, retargeting, skeletal reuse, and optional IK. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-animation-character` |
| `threejs-game-asset-pipeline` | Define glTF/GLB asset pipelines for compression, validation, naming conventions, prefab assembly, and loader setup. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-asset-pipeline` |
| `threejs-game-bootstrap-runtime` | Create maintainable three.js game runtime structure with renderer factory, game loop, resize flow, lifecycle hooks, and service boundaries. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-bootstrap-runtime` |
| `threejs-game-input-camera` | Design device-agnostic input and camera control for keyboard, mouse, pointer lock, gamepad, touch, and mode switching. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-input-camera` |
| `threejs-game-interaction-ui` | Implement robust world interaction, picking, triggers, HUD coordination, and world-space UI patterns. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-interaction-ui` |
| `threejs-game-materials-tsl-vfx` | Implement custom materials, TSL, procedural shaders, particle systems, and VFX with explicit WebGL/WebGPU boundaries. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-materials-tsl-vfx` |
| `threejs-game-performance-profiler` | Set performance budgets and profiling workflows for draw calls, memory, cleanup, streaming, batching, and CPU/GPU bottlenecks. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-performance-profiler` |
| `threejs-game-physics-collision` | Design collision and physics layers with character movement, collision layers, scene queries, and engine-adapter boundaries. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-physics-collision` |
| `threejs-game-render-lighting` | Set rendering baselines for color management, PBR, lighting, environment maps, shadows, transparency, and post-processing. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-render-lighting` |
| `threejs-game-save-load-network` | Define save/load, snapshot, replay, and networking boundaries for serializable and synchronized game state. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-save-load-network` |
| `threejs-game-tooling-qa-release` | Create repeatable quality workflows with tests, asset validation, visual regression, browser coverage, and release checklists. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-tooling-qa-release` |
| `threejs-game-xr-platform` | Add WebXR support with controller mapping, interaction design, comfort rules, and XR-specific rendering constraints. | `npx skills add https://github.com/ceasarXuu/AstartesSkills --skill threejs-game-xr-platform` |

## Repository Layout

```text
.
├── skills/                         # Standalone skills
│   ├── _templates/                 # Reusable skill templates
│   ├── astartes-coding-custodes/   # AI coding governance skill
│   ├── frontend-refactoring/       # Legacy frontend migration skill
│   ├── show-my-repo/               # Repo packaging and presentation skill
│   ├── storybook-skills-standard/  # Storybook component workflow governance skill
│   ├── summary-my-repo/            # Internal repo summary and onboarding skill
│   └── threejs-game*/              # Three.js game development skill family
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

This verifies that `astartes-coding-custodes` is:

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
- first real skill: `astartes-coding-custodes`

Planned next:

- more AI coding skills
- a `new-skill` generator script
- richer validation for metadata consistency
- marketplace-specific exporters beyond the current normalized manifest
