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

## 2026-03-21 Codex GUI Missing CODEX_HOME

- Problem: skills were visible in session metadata, but `CODEX_HOME` was empty inside Codex app and shell subprocesses, which makes path-dependent tooling and automation state brittle
- Root cause: macOS GUI apps launched by `launchd` do not inherit shell startup files such as `~/.zprofile` and `~/.zshrc`; meanwhile local shell config also had no explicit `CODEX_HOME`
- Decision: define `CODEX_HOME=/Volumes/XU-1TB-NPM/devtools/codex/home` in `~/.zprofile` for login shells, in `~/.local/bin/env` for interactive/helper shells, and add `~/Library/LaunchAgents/com.xuzhang.codex-env.plist` to run `launchctl setenv CODEX_HOME ...` at login for GUI apps
- Why it worked: terminal shells, helper scripts, and the Codex desktop process now converge on the same home directory instead of relying on implicit defaults
- Reuse later: whenever Codex desktop can see files but environment-dependent features behave inconsistently, check both shell exports and `launchctl getenv CODEX_HOME` before debugging skills or automations

## 2026-03-26 Packaging-Heavy Skill Authoring

- Problem: a new skill needed rich packaging logic, but putting all design guidance directly into `SKILL.md` would make triggering noisy and inflate context usage
- Decision: keep `SKILL.md` limited to trigger conditions, workflow, evidence discipline, and output contract; move scoring logic into `rubrics/`, reusable output shapes into `templates/`, and style calibration into `examples/`
- Why it worked: the installable skill stays concise enough to trigger cleanly, while still shipping the heavier guidance needed for multi-audience output
- Reuse later: when a skill needs deep judgment frameworks, split the portable package into `SKILL.md` plus selectively loaded supporting files instead of shipping one oversized instruction file

## 2026-03-26 Versioned Output For Document-Producing Skills

- Problem: a packaging skill that only returns inline text makes repeated runs hard to compare, archive, and reuse inside the target repo
- Decision: define a repo-root output contract of `show-my-repo/YYYYMMDD_vN/presentation-pack.md`, creating the root folder when absent and incrementing the version within the same day
- Why it worked: every run gets a deterministic landing zone, and repeated revisions on the same date remain ordered without overwriting older artifacts
- Reuse later: when a skill's main value is a reusable document, give it a default write path and versioning convention instead of leaving persistence to ad-hoc operator behavior

## 2026-03-26 Shell Search Patterns With Backticks

- Problem: using backticks directly inside a quoted `rg` pattern under `zsh` triggered command substitution and broke a content assertion command
- Decision: when searching for literal strings that contain backticks, either use single-quoted shell strings carefully or search for safer substrings that avoid command substitution entirely
- Why it worked: verification commands stopped depending on fragile shell quoting and became repeatable
- Reuse later: treat backticks in shell one-liners as hazardous characters during verification, especially when checking Markdown content

## 2026-03-27 Internal Repo Summary Skill

- Problem: `show-my-repo` covered outward-facing repo packaging, but maintainers still lacked a reusable skill for internal onboarding and architecture digestion
- Decision: add `summary-my-repo` as a separate skill that writes a versioned markdown pack under repo-root `summary-my-repo/YYYY-MM-DD-vN/`, split into overview, directory map, and core logic files
- Why it worked: internal onboarding needs directory responsibilities and control-flow explanation, which are different from investor or user packaging
- Reuse later: when a repo summary is meant for engineers rather than external audiences, default to a multi-file architecture pack with explicit coverage of source-of-truth files, workflows, invariants, and risks

## 2026-03-27 Retiring An Obsolete Skill Cleanly

- Problem: the repository no longer needed one older example skill, but removing only the folder or only the registry entry would leave validation, docs, and exported artifacts inconsistent
- Decision: retire the skill as a full package removal by updating `registry/skills.json`, README examples, install-script examples, generated summary docs, and stale `dist` artifacts together
- Why it worked: the repo's real contract spans filesystem, registry, user docs, and generated marketplace output, so removing a skill has to be treated as a multi-surface change
- Reuse later: when removing a skill, search the whole repo first and clean source, docs, and exported artifacts in one pass before running validation

## 2026-03-28 Summary Skill Needs Code Proof

- Problem: architecture summaries without explicit code snippets are easy to read but hard to verify, and different readers may interpret prose claims differently
- Decision: add a mandatory `03-code-evidence.md` output file and require snippet ids, file paths, line ranges, and short interpretations for core claims
- Why it worked: the summary remains readable while key claims become auditable against concrete code
- Reuse later: for repository-summary skills, treat prose as interpretation and code snippets as proof; require both by contract

## 2026-04-21 Frontend Refactoring Skill Needs Migration Framing

- Problem: long-form frontend cleanup advice can easily collapse into generic CSS tips and fail to tell an agent when to isolate, when to rebuild the DOM, and when to delete legacy styles
- Decision: encode the skill around a fixed sequence of boundary selection, contamination audit, isolation strategy, view rebuild criteria, cutover gating, and deletion order
- Why it worked: the central rule stays visible: the new UI must leave the legacy style pollution domain instead of fighting inside it
- Reuse later: for methodology-heavy refactor skills, encode decision boundaries and migration order first; keep tactic lists secondary
