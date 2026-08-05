---
name: provider-switch
description: Manage and maintain safe, reversible configurations that connect coding agents to model providers. Use when the user asks to add, install, switch, update, validate, roll back, or troubleshoot an Agent/Provider combination such as Codex with DeepSeek; when multiple provider profiles must coexist; or when adding a new provider package to the provider-switch catalog.
---

# Provider Switch

Manage Agent/Provider combinations as named, independently validated packages. Prefer temporary profiles that preserve the agent's default configuration and login state.

## Core Rules

- Verify current official documentation for both the agent and provider before changing files. Treat models, endpoints, CLI flags, schemas, and minimum versions as unstable.
- Inventory the current CLI version, config paths, login state, command resolution, and existing target files without printing secrets.
- Default to a temporary side-load, profile, or wrapper. Modify global defaults only when the user explicitly requests a persistent switch.
- Keep provider credentials separate from the agent's own account login. Never add global login-policy fields to a provider profile merely to send a provider API key.
- Preview all target files and behavioral effects before writing. Back up changed files, preserve existing non-placeholder secrets, and use atomic writes.
- After a successful interactive install, open a dedicated provider config when its credential placeholder still needs user input. Do not open it when a real credential is already present, and provide an opt-out for automation.
- Treat any bundled YOLO launcher as an explicit package contract: log `mode=yolo`, document that permissions and safety checks are bypassed, and never apply that mode to the agent's ordinary command or global settings.
- Log stable action names, targets, modes, and validation results. Never log credential values or authorization headers.
- Stop on unsupported protocols, invalid downloaded metadata, version incompatibility, or login-state regression. Do not add a silent compatibility fallback.

## Workflow

1. Read `assets/providers.json` and select the exact Agent/Provider id.
2. Read the selected entry's reference before running its installer or editing its assets.
3. Confirm scope: temporary by default; obtain explicit authorization for a persistent default change.
4. Capture a redacted baseline:
   - resolved agent and wrapper commands;
   - agent version;
   - relevant file existence and permissions;
   - login status, if the agent exposes one;
   - repository state when managed files live in a repository.
5. Describe creates, updates, backups, preserved secrets, external downloads, and launch behavior.
6. Run the cataloged installer or follow the reference. Do not improvise a different auth boundary without documenting the user-visible reason.
7. Validate in layers:
   - syntax and schema;
   - installer idempotency and failure atomicity;
   - wrapper argument forwarding;
   - a local mock provider request when practical;
   - login state before and after the provider run;
   - a real provider smoke request only with user authorization when it can spend money or mutate remote state.
8. Report the launch command, effective scope, backup path, verification evidence, and rollback steps.

## Catalog Operations

### Install or update an existing combination

- Select the catalog entry and load only its reference.
- Prefer its deterministic installer under `scripts/`.
- Treat a changed official payload as untrusted until its expected structure validates.
- On update, preserve a real credential already present in the dedicated provider file.

### Add a new combination

Read [references/provider-package-contract.md](references/provider-package-contract.md), then:

1. Add one catalog entry with a stable kebab-case id.
2. Add one direct reference describing official sources, auth boundaries, target files, validation, and rollback.
3. Add assets for files copied to the user's machine.
4. Add a deterministic installer when the workflow has fragile parsing, backup, secret-preservation, or atomic-write requirements.
5. Add offline fixtures and a sanity path that exercise success, idempotency, update, failure, and redaction.
6. Update release metadata and repository discovery surfaces.

## Bundled Combination

- `codex-deepseek-flash`: read [references/codex-deepseek-flash.md](references/codex-deepseek-flash.md), then use `scripts/install_codex_deepseek.py`.
- `claude-code-deepseek`: read [references/claude-code-deepseek.md](references/claude-code-deepseek.md), then use `scripts/install_claude_deepseek.py`.
- `claude-code-deepseek-flash`: read [references/claude-code-deepseek-flash.md](references/claude-code-deepseek-flash.md), then use `scripts/install_claude_deepseek_flash.py`.

## Handoff Contract

Always state:

- selected Agent, Provider, model, and scope;
- effective permission mode and its user-visible safety boundary;
- created or changed paths and backup location;
- whether an existing secret was preserved;
- whether the original agent login remained unchanged;
- validation commands and results;
- the exact launch and rollback commands;
- unsupported or unverified behavior.
