---
name: docs-manager
description: "Use when Codex needs to design, reorganize, audit, or maintain a repository's documentation system: docs/ directory hierarchy, global vs version-level documents, version PRDs, technical designs, engineering plans, document versioning, naming conventions, link/index management, archive policy, or automated docs structure validation."
---

# Docs Manager

## Purpose

Use this skill to turn ad hoc project documentation into a maintainable docs system. The default pattern is:

- Global docs for long-lived cross-version knowledge.
- Version docs for per-release product scope, technical design, and execution plan.
- Machine-readable indexes and validation scripts to keep links and directory rules honest.

## Workflow

1. Inspect the current repo:
   - List `docs/`, top-level docs, version files, release/version source files, and existing validation scripts.
   - Search for old paths and duplicate document roles.
   - Check whether the repo already has app/product versions.
2. Choose the document layers:
   - Use global docs for architecture, release/version rules, playbooks, and archive.
   - Use version docs for one concrete app/product version.
   - Do not keep a global PRD when version PRDs are the source of truth.
3. Establish or migrate the directory map:
   - `docs/architecture/` for cross-version architecture.
   - `docs/release/` for release/version management.
   - `docs/playbooks/` for reusable operating procedures and governance.
   - `docs/archive/` for superseded documents.
   - `docs/v<version>/` for per-version docs.
4. For each version directory, keep exactly the version trio:
   - `prd.md`
   - `technical-design.md`
   - `engineering-plan.md`
5. Set source-of-truth relationships:
   - Version PRD defines product scope, version goal, completion definition, rules, and acceptance criteria.
   - Technical design is derived from the version PRD and must not redefine product scope.
   - Engineering plan is derived from the version PRD and technical design and must not redefine product scope.
6. Add link/index management:
   - Use an existing `version.json`, package file, release manifest, or similar source if present.
   - Record the current version docs root and the three version docs paths.
   - Ensure current-release document lists never point to archived files.
7. Add validation:
   - Enforce no files directly under `docs/`.
   - Enforce version directory naming and exact trio membership.
   - Enforce PRD document version metadata.
   - Enforce design/plan links back to their source documents.
   - Run the project test command after changes.
8. Archive safely:
   - Move superseded documents into `docs/archive/`.
   - Add archived status, reason, and replacement document.
   - Avoid irreversible deletes unless the user explicitly asks and policy allows it.

## Version Doc Pattern

Use this default version package:

```text
docs/
  architecture/
  archive/
  playbooks/
  release/
  v<version>/
    prd.md
    technical-design.md
    engineering-plan.md
```

Naming rules:

- Version directory: `docs/v0.1.0`, `docs/v1.0.0`, etc.
- Version files: always `prd.md`, `technical-design.md`, `engineering-plan.md`.
- Global stable docs: kebab-case, no date prefix.
- One-time records or migration notes: date prefix is acceptable.
- No Markdown files directly under `docs/`.

## PRD Versioning

The version PRD must carry its own document version independent from the app/product version.

Require:

- A top metadata line such as `PRD 文档版本：1.0` or `PRD Document Version: 1.0`.
- A PRD version history table.
- User confirmation before creating a new PRD document version.
- If the user declines a new document version, update the current version history entry instead.

## Templates

When creating a new version docs package, read `references/version-doc-templates.md` and adapt the three templates to the repo.

Keep templates project-neutral. Replace product names, version numbers, owner, dates, and section details.

## Optional Validation Script

The bundled script `scripts/validate_docs_manager.py` can validate the common pattern:

```bash
python3 /path/to/docs-manager/scripts/validate_docs_manager.py --repo-root .
```

Use it directly when the repo follows the default pattern, or copy/adapt its checks into the repo's own tooling when the repo needs custom rules.

## Quality Bar

Before finishing docs governance work:

- Run the repo's normal tests or validation command.
- Search for stale old paths.
- Confirm docs index/source files reference the new paths.
- Confirm archived files are not current-release documents.
- Summarize the resulting directory map and source-of-truth chain.
