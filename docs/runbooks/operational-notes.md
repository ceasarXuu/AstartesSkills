# Operational Notes

## 2026-03-21 Repo Initialization

- Problem: empty repository needed a structure that supports both market publishing and GitHub direct install
- Decision: keep each skill self-contained under `skills/`, then add repo-level discovery with `registry/skills.json`
- Why it worked: market metadata stays near each skill, while install tooling and validation stay centralized
- Reuse later: future install, packaging, and publishing tooling should continue treating each skill folder as the deployable unit
