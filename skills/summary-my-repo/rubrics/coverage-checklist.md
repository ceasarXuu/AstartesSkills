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

## Maintenance Guidance

- reading order for a new collaborator
- invariants that should not be broken
- current gaps, risks, or confusing spots

## Failure Mode

If a summary pack cannot explain how the repo actually works, it is not complete even if the directory tree is accurate.
