# AstartesSkills

[中文](README.zh-CN.md)

Installable AI skills for Codex and compatible agents.

## What This Is

`AstartesSkills` is a multi-skill repository. Each skill is packaged in its own folder so you can install only what you need.

Use this repository to:

- browse available skills
- install one or more skills from a local clone
- install skills directly from GitHub
- use the repository as a distribution source for your own agent setup

This README is the user manual. Internal project rules and maintainer constraints live in `AGENTS.md`.

## Available Skills

Current installable examples include:

- `hello-world`: minimal example skill
- `ornn-coding-governor`: coding-governance and execution-standards skill

List the latest available skills:

```bash
./scripts/list-skills.sh
```

## Install

### Option 1: Install from a local clone

```bash
./scripts/install-skill.sh hello-world
```

Install multiple skills:

```bash
./scripts/install-skill.sh hello-world ornn-coding-governor
```

Install into a custom directory:

```bash
./scripts/install-skill.sh --target ~/.codex/skills hello-world
```

Default install target:

```text
${CODEX_HOME:-$HOME/.codex}/skills
```

### Option 2: Install directly from GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/ceasarXuu/AstartesSkills/main/scripts/install-skill.sh \
  | bash -s -- --repo https://github.com/ceasarXuu/AstartesSkills.git hello-world
```

This flow:

- clones the repository into a temporary directory
- copies only the skills you requested
- installs them into your target directory

## Use an Installed Skill

After installation, each skill appears as its own directory, for example:

```text
~/.codex/skills/hello-world
```

The main instructions for each skill live in that skill's `SKILL.md`. Your agent uses those instructions to determine when and how to apply the skill.

## Repository Layout

```text
.
├── skills/                     # installable skills
├── registry/                   # repository catalog
├── scripts/                    # install/validate/export tooling
└── docs/                       # plans and runbooks
```

## For Maintainers

If you want to maintain or extend this repository instead of only using the skills:

- project rules and constraints: `AGENTS.md`
- contribution flow: `CONTRIBUTING.md`

## Troubleshooting

Start with:

```bash
./scripts/list-skills.sh
./scripts/validate-repo.sh
```

If installation fails, check log lines prefixed with `[install]` or `[validate]`.
