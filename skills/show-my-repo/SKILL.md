---
name: show-my-repo
description: Use when the user wants to introduce, package, present, or pitch a repository for investors, users, demos, landing pages, README upgrades, or PR materials. Extract product value, architecture, highlights, risks, and commercialization narratives from repo evidence.
---

# show-my-repo

## Purpose

Turn a repository into an evidence-backed external presentation pack.

This skill is for converting repo facts into product-facing, commercially legible narratives without losing technical credibility.

## Use This Skill When

- The user asks to introduce, package, present, or pitch a repo
- The user wants project highlights, differentiators, architecture summaries, or demo paths
- The user wants investor, user, roadshow, landing-page, or PR-ready versions of the same project
- The user wants a more productized explanation of a technical project

## Do Not Use This Skill When

- The user only wants bug fixing, implementation, or code review
- The user only wants internal API docs or engineering docs
- The repo is too incomplete to support claims beyond speculation

## Non-Negotiable Rules

- Do not invent traction, customers, revenue, scale, or usage data
- Clearly separate `implemented`, `inferred`, `planned`, and `should not overclaim`
- Do not treat third-party API usage as proprietary core technology
- Do not confuse code complexity with product value or moat
- Every major claim must map to repo evidence or be explicitly marked as inference

## Workflow

### 1. Establish the repo basics

Determine:

- project name
- product type
- delivery form: web, desktop, mobile, CLI, API, service, hybrid
- maturity: concept, demoable prototype, MVP, or actively operable product
- target user
- primary use case

### 2. Read the product story from docs

Start with the repo's user-facing docs and product notes. Extract:

- stated problem
- intended audience
- key workflows
- claimed features
- deployment shape
- roadmap or planned scope

### 3. Validate with code and config

Check whether the product story is supported by:

- folder structure
- core modules
- dependencies
- state and data flow
- integrations
- persistence, auth, realtime, AI, queue, or storage patterns
- tests, CI, scripts, or demos

### 4. Build the outward-facing architecture summary

Summarize:

- major components
- module boundaries
- main user flow and system flow
- notable tradeoffs
- why the architecture matters to the user experience

Keep it externally legible. Explain why the design matters before naming technologies.

### 5. Extract highlights, difficulties, and risks

Group findings into:

- product highlights
- technical highlights
- commercial highlights
- execution highlights
- product risks
- engineering risks
- commercialization risks

Use the evidence rubric before making strong claims.

### 6. Convert into audience-specific packaging

Produce:

- one-line positioning
- repo fact sheet
- investor version
- user version
- demo or roadshow version
- elevator pitch
- FAQ
- implemented vs planned table
- evidence map

## Output Standard

Unless the user asks for a narrower output, include:

1. one-line positioning
2. project intro
3. target user and core scenario
4. core modules
5. architecture snapshot
6. highlights
7. challenges and risks
8. investor version
9. user version
10. demo version
11. 15-second pitch
12. 60-second pitch
13. implemented vs planned
14. evidence map

## Claim Language

- Use `implemented` when the repo clearly proves it
- Use `inferred` when code strongly implies it but docs do not say it directly
- Use `planned` when docs or roadmap indicate future work
- Use `should not overclaim` when evidence is weak, partial, or ambiguous

## Supporting Files

Load extra files only when needed:

- `rubrics/product-value-rubric.md` for user, pain, workflow, and ROI extraction
- `rubrics/architecture-rubric.md` for system-shape and tradeoff summaries
- `rubrics/highlights-rubric.md` for highlight selection, difficulty framing, and P1/P2/P3 priority
- `rubrics/commercialization-rubric.md` for market-facing narrative and monetization logic
- `rubrics/evidence-grading-rubric.md` before finalizing any strong claim
- `templates/` for output scaffolds
- `examples/` only when the user needs calibration on style or output depth

## Tone By Audience

### Investor version

- opportunity-aware
- structured
- credible
- explicit about current stage and next step

### User version

- scenario-first
- benefit-first
- low jargon
- trust-building

### Demo version

- problem first
- fast to visualize
- short demo path
- feature-to-value mapping
