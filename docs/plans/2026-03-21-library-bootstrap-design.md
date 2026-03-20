# AstartesSkills Library Bootstrap Design

## Goal

Initialize this empty repository as a multi-skill library that supports both future skill-market publishing and direct GitHub installation.

## Design

Use a monorepo layout:

- `skills/` stores independent skill packages
- `registry/skills.json` stores repo-wide discovery metadata
- `scripts/` provides install, list, and validation tooling
- `.github/workflows/` enforces structural correctness

Each skill remains portable. Repository-level tooling improves discoverability and installation without forcing a market-specific format onto authoring.

## Decisions

- Prefer a registry file over scanning alone so metadata can later feed market exporters
- Provide a shell installer first because it is easy to run from GitHub raw URLs
- Include one example skill plus one reusable template
- Start with structure validation before adding more advanced release automation
