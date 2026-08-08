# Optional Version-Trio Layout Profile

Use this reference only when the user or the repository's existing documentation contract explicitly selects a version-trio layout.

It is not the default docs-manager architecture and must not override specialized artifact-owner contracts.

## Example Layout

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

## Ownership Rules

- `prd.md` remains owned by the repository's PRD workflow. If `clear-prd` is in use, preserve its Product Authority contract and protected `Confirmed Product Decisions` section.
- `technical-design.md` contains technical design only and must not silently redefine product authority.
- `engineering-plan.md` is only appropriate when the repository explicitly uses that filename and planning model. If `se-good-plan` is in use, preserve its `docs/releases/<version>/<topic>/plan.md` contract instead of forcing this example.
- Do not duplicate canonical artifacts to satisfy this layout.

## Minimal Metadata Example

A version-level document may record only the links needed by the repository, for example:

```markdown
- App/Product Version: <version>
- Status: draft | active | archived
- Source Of Truth: <path or role>
- Related Documents:
  - <path>
```

Do not add document-version tables, fixed section inventories, or internal templates unless the owning workflow or repository contract requires them.

## When Not To Use This Profile

Do not enable it merely because:

- the repository has releases;
- docs-manager is installed;
- versioned folders look tidy;
- another project used this structure successfully.

Use it only when the repository has intentionally chosen this layout and its benefits outweigh migration cost.
