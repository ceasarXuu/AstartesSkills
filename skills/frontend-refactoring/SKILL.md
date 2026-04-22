---
name: frontend-refactoring
description: Use when a frontend redesign or legacy CSS refactor is blocked by global style pollution, selector collisions, unstable DOM reuse, or the need to migrate a page or module to a new UI without breaking the old system.
---

# frontend-refactoring

## Purpose

Treat large frontend visual rewrites as a migration problem, not a patching problem.

Use this skill when new UI keeps getting contaminated by old global CSS, generic classes, inherited selectors, `!important`, deep descendant chains, or legacy component structure.

This skill helps isolate new UI, reuse logic without reusing polluted presentation, and cut over safely from a legacy frontend surface to a v2 system.

## Use This Skill When

- the user wants to redesign or modernize a legacy page or module
- global CSS, generic classes, or inherited styles keep breaking new work
- the target UI is meaningfully different from the old DOM or layout structure
- the team needs a migration path with feature flags, visual regression, and staged deletion
- a refactor must preserve business logic while rebuilding the view layer

## Do Not Use This Skill When

- the task is a small styling fix inside an already well-scoped component system
- the design change is minor and does not require a new style boundary
- the codebase already has reliable local scoping and the issue is purely functional, not architectural

## Non-Negotiable Rules

- Do not keep new UI inside the same style pollution domain as the legacy system.
- Do not reuse legacy class names for new UI.
- Do not keep adding page-specific rules to `global.css`, `index.css`, or equivalent global entry files.
- Before writing migration code, read the legacy frontend without its styles and build a style-agnostic inventory of page structure and required components.
- Do not force a radically different design onto a legacy DOM structure when the structure itself is the problem.
- Reuse business logic when useful, but do not blindly reuse legacy visual components.
- Do not drop functional components, structural regions, or required states that appear in the legacy UI unless the user explicitly approves that removal.
- Do not invent new components during refactor unless they are required by the target design or are a clear extraction of existing behavior.
- Delete old styles only after cutover, regression checks, and dependency confirmation.

## Core Diagnosis

Look for:

- generic global selectors such as `.title`, `.content`, `.btn`
- deep descendant chains such as `.page .card .title`
- `!important` and specificity wars
- tag selectors controlling page detail such as `h2 {}` or `ul li a {}`
- parent or ancestor styles leaking into reused components
- mixed concerns where component boundaries and style boundaries do not match

If these are present, frame the work as a migration from legacy UI to isolated UI, not as incremental cleanup.

## Isolation Strategy Order

Pick the lightest strategy that truly isolates the new work:

1. CSS Modules or framework-scoped styles
2. Strong namespace wrapper
3. Shadow DOM

Default recommendations:

- React, Next.js, Vue, or component-based apps: prefer CSS Modules or framework-scoped styles
- legacy or mixed stacks without reliable local scoping: use a root namespace such as `.v2-page`
- widgets, embeds, or highly isolated panels: use Shadow DOM only when host-page isolation must be strict

Always state why the chosen isolation level is sufficient and what it does not solve.

## Required Workflow

### 1. Define the migration boundary

Classify the refactor as one of:

- a single page
- a business module
- a set of shared base components

Do not start with a whole-site rewrite unless the user explicitly asks for it.

### 2. Build a style-agnostic structure inventory

Before touching migration code, inspect the legacy frontend as if styles did not exist.

Capture a concrete inventory covering:

- page or route name
- top-level structural regions and section order
- required content blocks inside each region
- all reusable components present on the page
- all functional components such as forms, filters, tables, tabs, modals, drawers, pagination, uploaders, or charts
- key states, interactions, and conditional branches
- explicit omissions: components or regions that do not exist today and must not be invented during refactor without approval

Treat this inventory as the migration baseline.

The refactor should happen against this structure-first checklist, not against visual memory or class names.

### 3. Audit the legacy contamination

Identify:

- CSS entry points that can hit the target area
- legacy classes or selectors that must not be reused
- DOM structures that encode old layout assumptions
- shared tokens, resets, or utilities that are safe to reuse versus unsafe to inherit

Summarize the likely contamination sources before editing.

### 4. Decide whether to rebuild the view

If the target UI differs substantially from the current layout, prefer:

- keep data fetching
- keep state management
- keep validation and business rules
- rebuild DOM structure
- rebuild component styling
- rename classes from scratch

Default principle: reuse logic, redo the view.

When rebuilding, map each new region or component back to the structure inventory so you can prove nothing required was lost and nothing undefined was added.

### 5. Build the new isolated surface

Preferred migration shape:

- `components-v2/` or the repo-native equivalent
- `pages-v2/` or a route-local replacement
- `styles/tokens.css`
- component-level style files or CSS Modules
- an explicit v2 root wrapper when local scoping is not guaranteed

Rules:

- all new UI uses new class names or locally scoped classes
- no new generic classes like `.card`, `.title`, or `.button` without a scope boundary
- avoid descendant chains deeper than 2 to 3 levels
- avoid `!important` unless documenting a temporary containment override

### 6. Establish the style system in this order

1. Tokens
2. Base components
3. Page composition
4. Temporary overrides
5. Deletion of legacy dependencies

Token groups usually include:

- color
- spacing
- radius
- typography
- elevation
- motion durations

Do not start by patching pixel-level page details without first defining the token and component system.

### 7. Control cascade and specificity

When using traditional CSS:

- prefer `@layer reset, base, components, utilities, overrides`
- keep page detail out of `base`
- use `:where()` when you want selectors easy to override later
- use a local reset when the legacy surface is unusually dirty, for example `box-sizing: border-box` inside the new root
- treat `all: initial` or `all: revert` as last-resort tools because they can break inheritance unexpectedly

### 8. Cut over safely

Require a switch mechanism such as:

- feature flag
- route split
- configuration gate
- explicit v1 or v2 render branch

Migration order:

1. ship isolated v2
2. verify behavior and visuals
3. switch traffic or default route
4. remove legacy style dependencies
5. delete unused legacy CSS and components

Never delete first and hope the new UI covers everything.

## Verification Standard

Before calling the refactor complete, verify:

- every required region and component from the structure inventory still exists or has an explicit approved replacement
- no required functional component disappeared during the visual rewrite
- no out-of-scope component was invented without design justification
- the new surface is not hit by unintended legacy selectors
- key interactions still work
- screenshots or visual regression cover the critical states
- the old style dependency graph for that area is understood well enough to delete safely
- no new global page styles were introduced during the refactor

If tooling exists, use screenshot comparison, Storybook visual tests, or CSS coverage to build deletion confidence.

## Default Output Format

Unless the user asks otherwise, structure the response as:

1. Refactor boundary
2. Style-agnostic structure inventory
3. Legacy contamination map
4. Recommended isolation strategy
5. View rewrite decision
6. v2 structure and naming plan
7. Migration and cutover sequence
8. Verification and deletion gates

## Heuristics And Anti-Patterns

Prefer:

- structure-first inventories before any styling work
- CSS Modules or scoped styles for new work
- new naming over compatibility naming
- component classes over deep descendant selectors
- single-direction migration where new UI may consume old logic, but not old style conventions

Avoid:

- keeping old DOM just to save time when layout semantics are wrong
- refactoring directly from screenshots or styled output without a structure checklist
- mixing old and new class systems in the same component
- writing page detail into global style entry files
- relying on `!important` to win cascade battles
- leaving v2 permanently dependent on v1 visual assets unless explicitly intentional
