# Contributing

## Principles

- Keep changes small and easy to review
- Commit actively by small theme
- Treat every skill as independently publishable
- Prefer direct fixes over bypasses
- Add logs or runbooks when a task teaches us something repeatable

## Adding a Skill

1. Copy `skills/_templates/basic-skill`
2. Rename the directory to the final skill id
3. Fill in `SKILL.md`
4. Fill in `agents/openai.yaml`
5. Add the skill to `registry/skills.json`
6. Run `./scripts/validate-repo.sh`

## Review Checklist

- Is the skill self-contained?
- Is `SKILL.md` concise and trigger-friendly?
- Is market metadata present?
- Is the skill listed in the registry?
- Does installation via `scripts/install-skill.sh` work?
- Did the change add useful logs or operational notes if needed?
