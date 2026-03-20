# AstartesSkills

AI coding skills library for distribution across multiple skill markets and direct GitHub installation.

这是一个“多 skills 集合仓库”，不是单个 skill。目标是同时支持：

- Skills market 分发
- GitHub 直接安装
- 团队内统一维护与版本化

## What This Repository Is

This repository packages multiple independent skills under one catalog.

Each skill lives in its own folder and can be:

- published to a market as a standalone skill
- installed directly from this GitHub repository
- validated in CI before release

The repository is designed for AI coding workflows first: concise instructions, reusable references, deterministic scripts, and easy installation.

## Goals

- Keep every skill independently publishable
- Make repository-level discovery simple
- Support GitHub-based install without requiring a market
- Keep future market adapters straightforward
- Preserve a clean contribution and validation workflow

## Repository Layout

```text
.
├── skills/                     # All standalone skills
│   ├── _templates/             # Reusable templates for new skills
│   └── hello-world/            # Example skill
├── registry/                   # Catalog and distribution metadata
├── scripts/                    # Install, export, list, and validate tooling
├── docs/
│   ├── plans/                  # Design and implementation notes
│   └── runbooks/               # Reusable operational experience
└── .github/workflows/          # CI validation
```

## Skill Layout

Every installable skill should follow this shape:

```text
skills/<skill-name>/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── markets/                   # Optional market-specific metadata
├── references/                # Optional
├── scripts/                   # Optional
└── assets/                    # Optional
```

Notes:

- `SKILL.md` is required
- `agents/openai.yaml` is strongly recommended for market/UI metadata
- `markets/` stores exporter-friendly metadata for specific marketplaces
- keep each skill self-contained so it can be copied out independently

## Installation

### Option 1: Install from local clone

```bash
./scripts/install-skill.sh hello-world
```

Install multiple skills:

```bash
./scripts/install-skill.sh hello-world another-skill
```

Install into a custom directory:

```bash
./scripts/install-skill.sh --target ~/.codex/skills hello-world
```

### Option 2: Install directly from GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/AstartesSkills/main/scripts/install-skill.sh \
  | bash -s -- --repo https://github.com/<owner>/AstartesSkills.git hello-world
```

This flow clones the repository into a temporary directory, copies only the requested skills, and leaves the destination ready for use.

### Option 3: Browse available skills first

```bash
./scripts/list-skills.sh
```

## Registry

The repository-level catalog lives in `registry/skills.json`.

It is the source of truth for:

- skill id and path
- title and summary
- tags
- installability
- future market publishing metadata

This keeps the repo easy to index, validate, and later sync to external marketplaces.

## Exporting Marketplace Manifests

Export repository-level and market-level artifacts:

```bash
./scripts/export-marketplace.py
```

Artifacts are written to `dist/`:

- `dist/catalog.json`: normalized repository catalog
- `dist/markets/openai-compatible/*.json`: per-skill market manifests

This keeps authoring inside the skill folder while still producing clean machine-readable outputs for distribution pipelines.

## Publishing Strategy

Recommended publishing model:

1. Author and validate a skill in this monorepo
2. Keep market-facing metadata inside the skill folder
3. Use `registry/skills.json` for repository-wide discovery
4. Add market-specific exporters later under `scripts/`

This avoids coupling authoring to any single market while keeping each skill portable.

## Development Workflow

### Add a new skill

1. Copy `skills/_templates/basic-skill`
2. Rename the folder
3. Update `SKILL.md`
4. Update `agents/openai.yaml`
5. Register the skill in `registry/skills.json`
6. Add `markets/` metadata if the skill will be published externally
7. Run validation

```bash
./scripts/validate-repo.sh
```

Optionally export distribution artifacts:

```bash
./scripts/export-marketplace.py
```

### Logging and operational notes

This repository follows a log-driven approach.

- Tooling should emit explicit logs for install and validation steps
- Repeated operational tasks should be captured in `docs/runbooks/`
- Failures and fixes should leave behind reusable notes, not tribal knowledge

## Example Skill

`skills/hello-world` is intentionally simple. It demonstrates:

- the minimum valid skill structure
- market metadata placement
- catalog registration
- GitHub install compatibility

## CI

GitHub Actions runs `scripts/validate-repo.sh` on pushes and pull requests.

The validation currently checks:

- every installable skill has `SKILL.md`
- every installable skill has `agents/openai.yaml`
- registry entries point to existing skill directories
- exporter inputs are structurally valid JSON

## Next Steps

- Add more real AI coding skills under `skills/`
- Add market export scripts per platform
- Add semantic versioning and release automation
- Add richer validation for metadata consistency
