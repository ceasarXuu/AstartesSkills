# se-good-plan Skill Design

- Date: 2026-06-04
- Status: Implemented
- Source: attached software engineering plan writing design document
- Skill id: `se-good-plan`

## Intent

`se-good-plan` helps agents write or review software engineering plans that are
phased, executable, verifiable, reviewable, and rollback-aware.

The skill targets implementation plans, refactor plans, migrations, rollouts,
bug-fix plans, performance plans, security changes, and DevOps / CI/CD work. It
does not replace engineering judgment or production approval.

## Design Choices

- Keep `SKILL.md` focused on trigger conditions, complexity assessment, plan
  depth selection, context honesty, phase schema, review gates, and quality
  checks.
- Move task-specific phase models and reusable tables to
  `references/plan-patterns.md` so agents load detailed patterns only when the
  task type needs them.
- Default to continuing with explicit assumptions, open questions, and
  `Phase 0: Discovery` when repository or system context is missing.
- Force `Full Plan` for production data, auth, security, payment, core API,
  irreversible, cross-system, high-availability, or external dependency
  changes.
- Add a dedicated sanity script so the core plan-writing contract remains
  structurally testable.
- Keep a normalized source contract in `references/source-contract.md` so the
  shipped skill remains traceable to the original design document.
- Encode low-risk, security-sensitive, missing-context, and existing-plan-review
  behavior in fixtures under `tests/se-good-plan/fixtures/`.
- Add performance and DevOps / CI/CD fixtures plus a Full Plan shape exemplar to
  guard against phrase-only validation drift.

## Acceptance

- The skill package exists under `skills/se-good-plan`.
- `SKILL.md` stays under 500 lines.
- The package has `agents/openai.yaml` and `markets/openai-compatible.json`.
- `registry/skills.json` and the market manifest share the same release
  metadata.
- README discovery entries mention `se-good-plan`.
- `./scripts/test-repo.sh se-good-plan` runs the dedicated sanity script.
- `./scripts/validate-repo.sh` validates registry coverage and release metadata.
- The sanity script validates source-contract coverage, Standard and Full plan
  section inventories, metadata/status and dependency templates, trigger text,
  fixture expectations, and the Full Plan exemplar shape.
