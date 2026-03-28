# Coverage Checklist

Before finalizing a summary pack, check that it covers all of the following.

## Repo Basics

- project purpose
- target maintainer or collaborator
- current maturity
- main entry docs

## Structure

- top-level directory responsibilities
- important subdirectory responsibilities
- source-of-truth files
- generated or derived artifacts

## Core Logic

- install flow
- validation flow
- export or build flow
- CI trigger and what it verifies
- central registries, manifests, or configs

## Critical Files

For each critical file:

- role
- inputs
- outputs
- downstream impact
- reason it is central

## Code Evidence

- at least one snippet for each core workflow section
- snippet includes repository path and line range
- snippet includes one-sentence claim of what it proves
- snippet includes a short interpretation, not just raw code
- snippet length is focused (prefer 8-40 lines)
- `02-core-logic.md` references snippet ids from `03-code-evidence.md`

## Maintenance Guidance

- reading order for a new collaborator
- invariants that should not be broken
- current gaps, risks, or confusing spots

## Failure Mode

If a summary pack cannot explain how the repo actually works with concrete code evidence, it is not complete even if the directory tree is accurate.
