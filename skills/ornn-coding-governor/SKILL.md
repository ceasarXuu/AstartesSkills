---
name: custodes-coding-governor
description: Use this skill when iterative AI-assisted coding starts to degrade code quality, architecture consistency, or maintainability. It enforces staged implementation, architecture guardrails, duplication control, strict review, and entropy-reduction refactors.
---

# custodes-coding-governor

## Purpose

Prevent quality decay during repeated AI-assisted coding iterations.

Use it when:

- a feature has gone through multiple rounds of edits
- local fixes are starting to damage global consistency
- code quality is degrading after repeated patching
- the system is accumulating duplicated abstractions, naming drift, weak typing, inconsistent error handling, or architectural violations
- the user asks for a robust, maintainable, system-aware implementation rather than a fast patch

This skill changes the default behavior from "solve the current local task quickly" to "preserve system integrity while implementing only the minimum safe change".

## Core Principles

1. Do not jump directly into coding. Analyze affected modules, architecture boundaries, and likely regression risks first.
2. Prefer system integrity over local convenience. Do not weaken layering, naming consistency, type safety, or error-handling discipline.
3. Prefer reuse over parallel abstraction. Reuse existing modules, patterns, and interfaces wherever possible.
4. Minimize change scope. Only edit what is necessary for the requested outcome.
5. Make hidden constraints explicit. Surface assumptions, invariants, and conventions before implementation.
6. Separate authoring from reviewing. After implementation, switch into strict reviewer mode.
7. Reduce entropy periodically. When iterations have clearly degraded the code, recommend a focused refactor pass.

## Required Workflow

### Phase 1: Analysis

Produce a concise analysis covering:

- what the user is asking for
- which modules or files are likely affected
- which architecture boundaries matter
- what existing implementations may already solve part of the problem
- what could go wrong if solved naively
- whether the task is a feature, bug fix, refactor, review, or architecture repair

Do not write code in this phase.

### Phase 2: Minimal Change Plan

Before editing, provide:

- files to inspect
- files likely to change
- purpose of each change
- why the plan is minimal
- what should remain unchanged
- tests and checks that should validate the change

### Phase 3: Implementation

When implementing:

- prefer the smallest viable safe change
- preserve existing architecture and naming
- preserve error-handling conventions
- preserve typing discipline
- avoid fallback hacks, broad optionality, or `any`-style escapes unless already justified by the codebase
- do not create parallel abstractions without explicit need

### Phase 4: Strict Review

After implementation, report:

- architecture consistency issues
- naming drift
- duplicated logic introduced or still unresolved
- weak typing or widened interfaces
- missing error handling
- missing tests
- regression risks
- follow-up refactor candidates

Do not merely praise the implementation. Actively search for weaknesses.

### Phase 5: Entropy Control

If repeated iterations have clearly degraded the code, pause further feature work and produce:

- a short list of structural issues
- priority-ranked refactor suggestions
- a recommended cleanup sequence

Examples of structural issues:

- repeated utilities for the same concept
- DTO/domain/view-model leakage
- inconsistent naming for the same concept
- mixed error handling styles
- state duplication
- multiple competing adapters
- overgrown files or functions
- widened types over time

## Heuristics

Actively look for:

- duplication signals: repeated mapping, validation, normalization, or fallback logic
- architecture drift: cross-layer imports, view logic leaking into domain logic, or infrastructure bypasses
- naming drift: the same concept represented with multiple names
- type decay: broad types, avoidable optional fields, ambiguous unions, or coercion-heavy code
- error-handling decay: mixed throw/null/partial-object styles or swallowed errors
- scope creep: a small fix expanding across many unrelated layers

## Default Output Format

Unless the user asks otherwise, structure responses as:

1. Task classification
2. Impact analysis
3. Minimal change plan
4. Implementation notes
5. Strict review findings
6. Recommended follow-up refactors

## Rules During Code Changes

- Do not silently introduce a new abstraction category.
- Do not silently rename concepts inconsistently.
- Do not widen types just to make the patch pass.
- Do not bypass existing interfaces for convenience.
- Do not add unbounded compatibility branches unless necessary.
- Do not keep dead temporary code without calling it out.
- Do not mix concerns into a single function if separation already exists elsewhere.

## Review Checklist

- Is the change consistent with current module boundaries?
- Did it reuse an existing pattern instead of creating a parallel one?
- Did it keep naming aligned with the existing codebase?
- Did it preserve or improve type safety?
- Did it preserve the project's error-handling convention?
- Did it avoid hidden behavioral regressions?
- Did it introduce duplicated logic?
