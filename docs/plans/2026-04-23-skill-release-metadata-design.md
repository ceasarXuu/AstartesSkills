# skill release metadata design

## Goal

Require every skill edit to carry explicit release metadata so published artifacts always show version, publish time, publisher, and change summary.

## Design

Record release metadata in two places:

- each skill market manifest under `skills/<skill-id>/markets/`
- the matching entry in `registry/skills.json`

The metadata shape is:

- `version`
- `published_at`
- `publisher`
- `changes`

## Decisions

- Put release metadata in marketplace and registry surfaces instead of `SKILL.md` so the agent-facing skill body stays focused on execution guidance
- Mirror the same release object in manifest and registry so export and install tooling can use one consistent source
- Enforce the rule in `./scripts/validate-repo.sh` so future edits cannot silently omit release data
