---
name: storybook-skills-standard
description: Use when the user needs to design, implement, audit, or govern Storybook stories for frontend components, design systems, page states, interaction tests, accessibility checks, visual baselines, or component-driven UI workflows.
---

# storybook-skills-standard

## Purpose

Turn Storybook into the execution surface for frontend design, component development, testing, documentation, and review.

Use this skill to create or audit Storybook standards for shared components, pattern components, page-level UI, design systems, and cross-project UI asset governance.

## Use This Skill When

- the user asks for Storybook story design, story coverage, or story granularity
- the user wants a component-driven development workflow
- the user is building or auditing a design system or component library
- the user needs CSF, TypeScript stories, args, decorators, globals, mocks, loaders, or `play` guidance
- the user wants accessibility, visual regression, documentation, or PR review gates around stories
- the user needs a Story Map, state matrix, or Storybook Definition of Done

## Do Not Use This Skill When

- the task is only production UI implementation with no Storybook surface
- the user only needs generic React, Vue, Angular, or CSS advice
- the user asks for the latest Storybook API behavior and the local project/docs do not prove it; verify official Storybook docs first
- the task is a temporary throwaway demo that will not enter review, tests, docs, or long-term asset governance

## Non-Negotiable Rules

- Treat each story as an executable UI state, not as a loose demo page.
- Start from a Story Map before writing or rewriting story files.
- Prefer `args` for user-visible state, `decorators` for context, and mocks for external dependencies.
- Do not connect stories to real production backends, real login state, or unstable third-party services.
- Keep one story focused on one concept, state, or user-visible scenario.
- Do not build a Cartesian product of props; keep the highest-value states.
- Put project-wide providers, globals, layout defaults, docs defaults, and a11y policy in `.storybook/preview.*`.
- Use `play` for critical Pattern and Screen flows when the behavior matters.
- Stable stories should be candidates for docs, component tests, accessibility checks, and visual baselines.
- Any user-visible UI change should come with a story addition or story update.

## Workflow

### 1. Establish Project Context

Inspect the local project before giving specific implementation instructions:

- framework and Storybook builder from `package.json` and `.storybook/main.*`
- story file conventions and existing title hierarchy
- test stack, a11y addon, visual testing setup, and MSW/module mock setup
- existing providers, themes, locales, routers, and feature flags
- current CI or PR review commands

If the user asks for version-specific or latest Storybook behavior, confirm against official Storybook docs before relying on memory.

### 2. Build The Story Map

Before writing stories, identify:

- component tree or page tree
- state matrix: default, variant, disabled, loading, empty, error, permission, boundary, responsive, theme, locale
- interaction matrix: click, input, submit, filter, sort, pagination, navigation, feedback
- dependency boundary: API, router, auth, feature flag, browser API, timers, storage
- story layer: Foundations, Primitive, Pattern, Screen, or Connected container

Use `references/storybook-standard.md` if the user needs the full standard, tables, templates, or official link list.

### 3. Choose Story Granularity

Classify the work:

- Foundations: token galleries, color, typography, spacing, icon rules
- Primitive: reusable UI units such as Button, Input, Avatar, Badge
- Pattern: user-task components such as LoginForm, DataTable, FilterBar
- Screen: page states such as OrdersPage or DashboardPage
- Connected container: only when browser/framework integration must be represented

Baseline coverage:

- Primitive: default, key variants, disabled/read-only where applicable, one boundary case
- Pattern: default or empty, success flow, error or validation, key interactions
- Screen: loaded, loading, empty, error, permission where applicable

### 4. Author Or Audit Stories

Default to modern CSF with TypeScript:

- `satisfies Meta<typeof Component>`
- `type Story = StoryObj<typeof meta>`
- `args` for visible state and Controls
- `fn()` or equivalent action mocks for callbacks
- `parameters` for static metadata such as layout, docs, a11y, MSW, or visual options
- project-level decorators for theme, locale, router, auth, and app providers
- globals and toolbar controls for theme, locale, density, and similar cross-cutting variables

Read example files only when a concrete code pattern is needed:

- `examples/Button.stories.tsx` for Primitive stories
- `examples/LoginForm.stories.tsx` for Pattern stories with `play`
- `examples/OrdersPage.stories.tsx` for Screen stories and MSW
- `examples/preview.tsx` for project-level preview configuration when decorators use JSX

### 5. Bind Quality Gates To Stories

Use stories as shared quality assets:

- Autodocs for component and design-system documentation
- `play` for critical user flows
- a11y checks with `error` by default, `todo` only for tracked debt, and `off` only for explicit exceptions
- visual baselines for stable stories that are easy to regress
- `composeStories` or `composeStory` when external tests should reuse story fixtures
- published Storybook links or local preview URLs for PR review

### 6. Produce A Reviewable Result

When giving recommendations, include:

- story map or state matrix
- proposed files and sidebar titles
- stories to add, change, or remove
- mock/decorator/global strategy
- quality gates and commands to run
- exceptions, risks, and follow-up debt

When editing code, run the repository's existing Storybook, test, lint, or build commands when available. Do not invent commands when the repo already defines them.

## Red Flags

- story files import live services or require real authentication
- page stories cannot render offline
- loaders are used for ordinary state that should be args or mocks
- each story combines many unrelated UI states
- `preview.*` configuration is duplicated inside every story
- a11y is turned off without a recorded exception
- visual baselines include noisy or unstable stories
- story names expose internal implementation details instead of product or design language

## Supporting Files

- `references/storybook-standard.md`: full source standard, state matrices, templates, and reference links
- `examples/`: compact Storybook examples for primitive, pattern, screen, and preview configuration
