---
name: docs-manager
description: Use when Codex needs to audit, organize, migrate, or maintain a repository's documentation system: source-of-truth relationships, docs hierarchy, naming, links and indexes, archive policy, stale references, duplicate authority, or documentation validation. Preserve existing artifact-owner contracts instead of imposing a fixed PRD or engineering-plan layout.
---

# Docs Manager

## Purpose

Govern repository documentation without turning one preferred directory layout into a universal framework.

The skill should make documentation easier to find, trust, update, archive, and validate while preserving the repository's existing artifact contracts and specialized workflows.

## Authority Precedence

When rules disagree, use this order:

1. explicit user instruction;
2. existing repository documentation contract or source-of-truth declaration;
3. specialized artifact-owner workflow or skill contract;
4. existing links, automation, CI, release tooling, and consumers;
5. docs-manager defaults.

Never restructure, rename, duplicate, or relocate an existing artifact solely to make it conform to docs-manager's preferred layout.

## Artifact Ownership

`docs-manager` owns documentation **governance**, not the semantic design of every document type.

- PRD content and product clarification belong to the repository's PRD workflow; when `clear-prd` is used, its PRD and protected `Confirmed Product Decisions` section remain canonical product authority.
- Engineering-plan structure and execution controls belong to the repository's planning workflow; when `se-good-plan` is used, its `plan.md` and Product Authority rules remain authoritative.
- Implementation reports, repository summaries, presentation packs, review evidence, debug cases, Storybook docs, and similar specialized artifacts remain owned by their generating workflow.
- Do not copy content from an owner artifact into a docs-manager-owned parallel source of truth.

Use docs-manager to connect these artifacts through indexes, links, lifecycle rules, and validation.

## Use This Skill When

- documentation paths are inconsistent or hard to navigate;
- multiple files claim to be source of truth;
- indexes or release manifests have drifted from actual files;
- stale links or old paths remain after a migration;
- superseded docs need safe archival;
- a repository needs a documentation map or lightweight governance rules;
- documentation validation should detect drift without dictating unrelated artifact formats.

Do not use this skill primarily to author a PRD, engineering plan, implementation report, or repository summary when a specialized workflow owns that artifact.

## Workflow

### 1. Inspect Before Designing

Inspect:

- existing `docs/` and other documentation roots;
- README and contributor docs;
- PRDs, plans, designs, release docs, runbooks, reports, and generated packs;
- release/version sources and documentation indexes;
- scripts, CI, or code that references documentation paths;
- archive conventions and stale-path references.

First infer the repository's actual documentation contract. Do not assume `docs/v<version>/` or any other structure is required.

### 2. Build A Responsibility Map

For each important document or family, identify:

- purpose;
- owner workflow;
- source-of-truth status;
- lifecycle: active, historical, generated, or archived;
- important inbound/outbound links;
- whether another artifact duplicates its authority.

Resolve duplicate authority before cosmetic folder cleanup.

### 3. Choose The Minimum Necessary Change

Prefer, in order:

```text
fix stale link/index
  -> clarify source-of-truth ownership
  -> archive superseded artifact
  -> rename/move a small ambiguous set
  -> reorganize a documentation subtree
  -> introduce new documentation structure
```

A broad migration needs a concrete navigation, ownership, release, or maintenance benefit. "Matches docs-manager defaults" is not a benefit.

### 4. Preserve Artifact Contracts During Migration

When moving or reorganizing docs:

- preserve owner-defined internal structure unless the owner workflow is also being intentionally changed;
- update inbound references, release manifests, indexes, CI, and scripts;
- avoid parallel copies of canonical artifacts;
- archive rather than irreversibly delete superseded documentation unless the user explicitly requests deletion;
- keep generated outputs outside canonical authority unless the repository explicitly says otherwise.

### 5. Validate Drift

Default validation should focus on repository integrity:

- broken local Markdown links;
- index or manifest paths that no longer exist;
- current-release references pointing into archive;
- stale references to migrated paths;
- duplicate or contradictory source-of-truth declarations that can be established from evidence.

Do not fail a repository merely because it lacks a docs-manager-preferred directory or filename.

### 6. Report The Result

Summarize:

- resulting documentation map;
- canonical artifact ownership;
- migrations or archives performed;
- stale/broken references fixed or remaining;
- validation performed;
- any unresolved authority conflict that needs user or artifact-owner review.

## Optional Layout Profile

A repository may explicitly choose a version-trio layout such as:

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

This is an opt-in compatibility profile, not the default repository architecture. Use it only when the user or existing repository contract explicitly selects it.

See `references/version-doc-templates.md` only for that optional profile. Its examples must not override specialized PRD or engineering-plan contracts.

## Optional Validation Script

Run the bundled validator for generic link/index integrity:

```bash
python3 /path/to/docs-manager/scripts/validate_docs_manager.py --repo-root .
```

Only when the repository explicitly uses the legacy version-trio profile:

```bash
python3 /path/to/docs-manager/scripts/validate_docs_manager.py --repo-root . --profile version-trio
```

## Quality Bar

Before finishing documentation-governance work:

- verify important current links and indexes;
- search for stale old paths after migrations;
- confirm canonical artifacts have one owner/source of truth;
- confirm archived files are not presented as current;
- confirm specialized artifact contracts were preserved;
- avoid structural changes that have no demonstrated repository benefit.
