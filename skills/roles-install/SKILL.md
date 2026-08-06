---
name: roles-install
description: Install or update one shared global coding-agent role/instruction text across locally installed Claude Code, Codex, TRAE CN, OpenCode, Pi, and Grok Build. Use when the user wants to synchronize persistent personal coding rules across multiple agents, inspect which supported agents are installed, preview their effective user-level instruction targets, choose the installation scope, or refresh previously installed roles.
---

# Roles Install

Install the same user-provided global role text into supported coding agents without overwriting unrelated user instructions.

## Hard Gates

- If the role text was not provided, ask the user for the exact text first. Treat it as opaque content: do not rewrite, summarize, or "improve" it unless asked.
- Inspect the local machine before proposing an installation scope. Do not assume every supported agent is installed.
- Show the detected agents, effective target paths, and any compatibility/shared-path behavior, then obtain explicit user confirmation of the install scope.
- Do not write any agent configuration before that scope confirmation.
- Back up every existing file that will be changed. Preserve all unrelated content.
- After installation, tell the user to fully restart the affected agent processes/IDE sessions before relying on the new roles.

## Supported Targets

Resolve `~` to the current user's home directory. On Windows this is normally `%USERPROFILE%`.

| Agent | Global role target | Resolution rules |
| --- | --- | --- |
| Claude Code | `~/.claude/rules/roles-install.md` | Preferred dedicated user-level rule file. It applies to all Claude projects without modifying the user's main `CLAUDE.md`. |
| Codex | `$CODEX_HOME/AGENTS.override.md` or `$CODEX_HOME/AGENTS.md` | `CODEX_HOME` defaults to `~/.codex`. If a non-empty global `AGENTS.override.md` already exists, it is the active global file and must receive the managed block; otherwise use `AGENTS.md`. Do not create an override merely for this skill. |
| OpenCode | `~/.config/opencode/AGENTS.md` | User-global rule file. On Windows `~` resolves under `%USERPROFILE%`. If the installation exposes an explicitly configured alternate config root, use the effective root instead of guessing. |
| Pi | `~/.pi/agent/AGENTS.md` | User-global context file. |
| TRAE CN | Prefer an existing `~/.trae-cn/user_rules/` root and write `roles-install.md` inside it | TRAE CN has changed personal-rule storage across versions. Verify the active personal-rule root on the machine. If the current version instead uses an existing monolithic `user_rules.md`, update that file with a managed block. Never create a guessed TRAE path when no active rule location can be verified. |
| Grok Build | `~/.claude/rules/roles-install.md` through Grok's Claude Code compatibility | Current Grok Build documentation exposes project `AGENTS.md` plus Claude instruction compatibility, but not a dedicated Grok-only user-global instruction file. Disclose that this shared compatibility file can also affect Claude Code. Use `grok inspect` when available to verify discovery. |

Claude Code and Grok Build therefore share one physical target when both are selected; write it once and report both consumers.

## Detection

Probe without launching interactive sessions or changing configuration.

1. Identify OS, home directory, and relevant environment overrides such as `CODEX_HOME`.
2. Check executable resolution and version where applicable: `claude`, `codex`, `opencode`, `pi`, `grok`.
3. Detect TRAE CN through the installed desktop application/process plus its user configuration roots; it may not expose a CLI.
4. Treat an executable/app bundle as `installed`. A leftover config directory without an executable/app is only `config-only`, not proof of installation.
5. Resolve each installed agent's effective target and inspect whether the target already exists.
6. For TRAE CN, search only inside TRAE-specific user configuration roots for active personal-rule files/directories. If no active location can be verified, mark it `unresolved` and do not silently install there.
7. For Grok Build, note whether the Claude-compatible target is shared with a detected Claude installation.

Before writing, present a compact table like:

```text
Agent      Status       Effective target                         Existing   Notes
Claude     installed    ~/.claude/rules/roles-install.md         yes        dedicated rule
Codex      installed    ~/.codex/AGENTS.md                       yes        managed block
TRAE CN    unresolved   —                                        —          rule root not verified
...
```

Ask the user to confirm exactly which detected/resolved agents to install to. Do not preselect `unresolved` targets.

## Write Rules

Use two write modes.

### Dedicated file

For `~/.claude/rules/roles-install.md` and a verified TRAE CN `user_rules/roles-install.md`:

- create parent directories only when their location is documented or already verified;
- if the file already exists and content differs, back it up first;
- write the exact user-supplied role text as UTF-8;
- if the content is already identical, leave the file untouched.

### Shared aggregate file

For Codex, OpenCode, Pi, and legacy monolithic TRAE CN rule files, preserve all existing content and own only this block:

```markdown
<!-- roles-install:begin -->
<exact user-provided role text>
<!-- roles-install:end -->
```

- If the block exists, replace only its body.
- If it does not exist, append it with clean surrounding newlines.
- Never delete or rewrite content outside the markers.
- Back up the original file before a real change.
- Use a same-directory temporary file plus atomic rename when possible.
- Name backups `<filename>.roles-install.bak-YYYYMMDD-HHMMSS`.
- A no-op reinstall must not create a new backup.

## Validation

After writes:

1. Re-read every target and verify the dedicated file or managed block exactly matches the supplied role text.
2. Verify unrelated aggregate-file content remains present.
3. Confirm every changed existing file has a backup and report its path.
4. Run `grok inspect` when Grok Build is selected and the command is available; verify the compatibility instruction source is discoverable.
5. Do not start inference requests merely to prove compliance unless the user explicitly authorizes that extra validation.
6. Do not claim that file installation guarantees model obedience. Installation success means the intended persistent instruction source was written and structurally verified.

## Handoff

Report:

- installed, unchanged, skipped, and unresolved agents;
- effective target path for each selected agent;
- shared targets such as Claude + Grok;
- backup paths;
- validation results and any path/version uncertainty.

End with an explicit restart notice: fully exit and restart all affected coding-agent processes or IDE sessions before expecting the new global roles to load. Pi can also reload context with `/reload`, but a full restart is the consistent default.