---
name: rules-install
description: Install or update one shared global coding-agent role/instruction text across locally installed Claude Code, Codex, TRAE CN, OpenCode, Pi, and Grok Build. Use when the user wants to synchronize persistent personal coding rules across multiple agents, inspect which supported agents are installed, preview their effective user-level instruction targets, choose the installation scope, or refresh previously installed roles.
---

# Rules Install

Install the same user-provided global role text into supported coding agents without overwriting unrelated user instructions.

## Hard Gates

- If the role text was not provided, ask the user for the exact text first. Treat it as opaque content: do not rewrite, summarize, or "improve" it unless asked.
- Inspect the local machine before proposing an installation scope. Do not assume every supported agent is installed or using its default profile.
- Show the detected agents, effective target paths, and any compatibility/shared-path behavior, then obtain explicit user confirmation of the install scope.
- Do not write any agent configuration before that scope confirmation.
- Back up every existing file that will be changed. Preserve all unrelated content.
- After installation, tell the user to fully restart the affected agent processes/IDE sessions before relying on the new roles.

## Supported Targets

Resolve the active user/profile root before writing.

| Agent | Effective global role target | Resolution rules |
| --- | --- | --- |
| Claude Code | `<claude-config>/rules/rules-install.md` | `<claude-config>` is `CLAUDE_CONFIG_DIR` when set, otherwise `~/.claude`. Use a dedicated user-level rule file instead of modifying the main `CLAUDE.md`. |
| Codex | `<codex-home>/AGENTS.override.md` or `<codex-home>/AGENTS.md` | `<codex-home>` is `CODEX_HOME` when set, otherwise `~/.codex`. If a non-empty global `AGENTS.override.md` already exists, it is the active global file and must receive the managed block; otherwise use `AGENTS.md`. Do not create an override merely for this skill. |
| OpenCode | `<active-opencode-config>/AGENTS.md` | Default is `~/.config/opencode/AGENTS.md`. If `OPENCODE_CONFIG_DIR` is set, inspect the installed version/current discovery behavior and use its active global `AGENTS.md`; do not assume an alternate config root is active merely because the variable exists. |
| Pi | `<pi-config>/AGENTS.md` | `<pi-config>` is `PI_CODING_AGENT_DIR` when set, otherwise `~/.pi/agent`. |
| TRAE CN | Prefer an existing active `~/.trae-cn/user_rules/` root and write `rules-install.md` inside it | TRAE CN has changed personal-rule storage across versions. Verify the active personal-rule root on the machine. If the current version instead uses an existing monolithic `user_rules.md`, update that file with a managed block. Never create a guessed TRAE path when no active rule location can be verified. |
| Grok Build | A Claude-compatible user rule source verified by `grok inspect`; default candidate `~/.claude/rules/rules-install.md` | Current Grok Build documents Claude Code instruction compatibility but not a dedicated Grok-only user-global instruction file. Do not assume Grok follows `CLAUDE_CONFIG_DIR`; verify its actual instruction source. Disclose that a Claude-compatible target can also affect Claude Code. |

Claude Code and Grok Build may share one physical file when both resolve to the same Claude-compatible rule source. Deduplicate the write only after comparing resolved paths.

### Default paths by OS

`~` means the current user's home directory.

```text
macOS / Linux / WSL
Claude:   ~/.claude/rules/rules-install.md
Codex:    ~/.codex/AGENTS.md                    # unless CODEX_HOME / existing override changes it
OpenCode: ~/.config/opencode/AGENTS.md
Pi:       ~/.pi/agent/AGENTS.md
TRAE CN:  ~/.trae-cn/user_rules/rules-install.md # only when this is a verified active root
Grok:     ~/.claude/rules/rules-install.md       # default compatibility candidate; verify first

Windows native
Claude:   %USERPROFILE%\.claude\rules\rules-install.md
Codex:    %USERPROFILE%\.codex\AGENTS.md
OpenCode: %USERPROFILE%\.config\opencode\AGENTS.md
Pi:       %USERPROFILE%\.pi\agent\AGENTS.md
TRAE CN:  %USERPROFILE%\.trae-cn\user_rules\rules-install.md  # only when verified active
Grok:     %USERPROFILE%\.claude\rules\rules-install.md        # default compatibility candidate; verify first
```

Environment/profile overrides take precedence over these defaults where documented and verified.

## Detection

Probe without launching interactive sessions or changing configuration.

1. Identify OS, home directory, and relevant profile variables: `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, `OPENCODE_CONFIG_DIR`, `PI_CODING_AGENT_DIR`, and `GROK_HOME`.
2. Check executable resolution and version where applicable: `claude`, `codex`, `opencode`, `pi`, `grok`.
3. Detect TRAE CN through the installed desktop application/process plus its user configuration roots; it may not expose a CLI.
4. Treat an executable/app bundle as `installed`. A leftover config directory without an executable/app is only `config-only`, not proof of installation.
5. Resolve each installed agent's effective target and inspect whether the target already exists.
6. For OpenCode with `OPENCODE_CONFIG_DIR`, inspect both the custom and default global candidates and use the active one for the installed version.
7. For TRAE CN, search only inside TRAE-specific user configuration roots for active personal-rule files/directories. If no active location can be verified, mark it `unresolved` and do not silently install there.
8. For Grok Build, run `grok inspect` when available before the scope prompt so the compatibility source and any Claude-path sharing are visible to the user.

Before writing, present a compact table like:

```text
Agent      Status       Effective target                         Existing   Notes
Claude     installed    ~/.claude/rules/rules-install.md         yes        dedicated rule
Codex      installed    ~/.codex/AGENTS.md                       yes        managed block
TRAE CN    unresolved   —                                        —          rule root not verified
...
```

Ask the user to confirm exactly which detected/resolved agents to install to. Do not preselect `unresolved` targets.

## Write Rules

Use two write modes.

### Dedicated file

For a resolved Claude/Grok `rules/rules-install.md` and a verified TRAE CN `user_rules/rules-install.md`:

- create parent directories only when their location is documented or already verified;
- if the file already exists and content differs, back it up first;
- write the exact user-supplied role text as UTF-8;
- if the content is already identical, leave the file untouched.

### Shared aggregate file

For Codex, OpenCode, Pi, and legacy monolithic TRAE CN rule files, preserve all existing content and own only this block:

```markdown
<!-- rules-install:begin -->
<exact user-provided role text>
<!-- rules-install:end -->
```

- If the block exists, replace only its body.
- If it does not exist, append it with clean surrounding newlines.
- Never delete or rewrite content outside the markers.
- Back up the original file before a real change.
- Use a same-directory temporary file plus atomic rename when possible.
- Name backups `<filename>.rules-install.bak-YYYYMMDD-HHMMSS`.
- A no-op reinstall must not create a new backup.

## Validation

After writes:

1. Re-read every target and verify the dedicated file or managed block exactly matches the supplied role text.
2. Verify unrelated aggregate-file content remains present.
3. Confirm every changed existing file has a backup and report its path.
4. Run `grok inspect` when Grok Build is selected and the command is available; verify the chosen compatibility instruction source is discoverable.
5. Do not start inference requests merely to prove compliance unless the user explicitly authorizes that extra validation.
6. Do not claim that file installation guarantees model obedience. Installation success means the intended persistent instruction source was written and structurally verified.

## Handoff

Report:

- installed, unchanged, skipped, and unresolved agents;
- effective target path for each selected agent;
- shared targets, if any;
- backup paths;
- validation results and any path/version uncertainty.

End with an explicit restart notice: fully exit and restart all affected coding-agent processes or IDE sessions before expecting the new global roles to load. Pi can also reload context with `/reload`, but a full restart is the consistent default.
