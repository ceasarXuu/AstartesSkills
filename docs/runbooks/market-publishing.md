# Market Publishing Runbook

## Purpose

Make each skill publishable without turning the whole repository into one giant market package.

## Current Pattern

- Author the skill inside `skills/<skill-id>/`
- Keep UI-facing metadata in `agents/openai.yaml`
- Keep exporter-facing market metadata in `markets/`
- Register the skill in `registry/skills.json`
- Export normalized artifacts with `./scripts/export-marketplace.py`

## Why This Pattern Is Better

- Skill folders stay self-contained
- The repository can publish many skills without flattening authoring structure
- New marketplaces can be supported by adding exporters, not by restructuring all skills

## Reuse Rule

When integrating a new marketplace, add:

1. a `markets/<market-name>.json` file format when per-skill metadata is required
2. an exporter under `scripts/`
3. a validation rule in `scripts/validate-repo.sh`
