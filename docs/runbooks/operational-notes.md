# Operational Notes

## 2026-03-21 Repo Initialization

- Problem: empty repository needed a structure that supports both market publishing and GitHub direct install
- Decision: keep each skill self-contained under `skills/`, then add repo-level discovery with `registry/skills.json`
- Why it worked: market metadata stays near each skill, while install tooling and validation stay centralized
- Reuse later: future install, packaging, and publishing tooling should continue treating each skill folder as the deployable unit

## 2026-03-21 First Real Skill Onboarding

- Problem: converting a draft document under `docs/tobeSkills/` into the first installable and exportable skill
- Decision: keep the source idea document in `docs/tobeSkills/`, but distill the actual reusable skill into a concise `SKILL.md` plus `agents/` and `markets/` metadata
- Why it worked: the long-form ideation doc remains available for iteration, while the shipped skill stays compact enough for real triggering and marketplace use
- Reuse later: when drafting future skills, write exploratory docs first if needed, then compress them into portable skill packages rather than shipping the drafts directly

## 2026-03-21 Documentation Split For Users vs Maintainers

- Problem: `README.md` was mixing end-user instructions with repository governance, making both audiences scan irrelevant content
- Decision: move project description, constraints, and maintainer norms into root `AGENTS.md`; keep `README.md` user-facing only; add `README.zh-CN.md` as a dedicated Chinese manual linked from the English default entry
- Why it worked: end users get a cleaner install/use path, while maintainers and agents have a single authoritative governance document
- Reuse later: repository-wide conventions go to `AGENTS.md`; user-facing setup and usage guidance stays in the README manuals
