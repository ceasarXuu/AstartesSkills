# Claude Code + DeepSeek V4 Flash

Use this package to add an independent `claude-ds-flash` entry where the main model, Claude model aliases, fast model, and subagent model all use `deepseek-v4-flash`. The existing `claude-ds-pro` Pro/Flash profile and its legacy `claude-ds` alias remain unchanged.

## Verify before every install

- DeepSeek Claude Code integration: <https://api-docs.deepseek.com/zh-cn/quick_start/agent_integrations/claude_code>
- Claude Code gateway connection: <https://code.claude.com/docs/en/llm-gateway>
- Claude Code settings: <https://code.claude.com/docs/en/settings>
- Claude Code environment variables: <https://code.claude.com/docs/en/env-vars>
- Claude Code permission modes: <https://code.claude.com/docs/en/permission-modes>

DeepSeek's official example uses V4 Pro for the main model and V4 Flash for Haiku and subagents. This all-Flash profile is an explicit user-selected variant built from the documented `deepseek-v4-flash` model, not the official recommended quality mix.

## Installed files

```text
${HOME}/.claude/provider-switch/deepseek-flash.settings.json
${HOME}/.local/bin/claude-ds-flash
```

The installer does not modify `claude-ds-pro`, `claude-ds`, `${HOME}/.claude/settings.json`, project settings, or Claude Code's credential store.

## Install

```bash
python3 scripts/install_claude_deepseek_flash.py
```

Credential priority is: an existing Flash profile token, the existing same-provider `deepseek.settings.json` token, `DEEPSEEK_API_KEY`, then the placeholder. A reused token is written only to the dedicated `0600` Flash settings and never logged. If no real token is available, the installer opens the Flash settings after installation; use `--no-open-editor` in automation.

Claude version detection times out after 10 seconds. If the version was already obtained through a separate successful probe, `--verified-claude-version <version>` avoids starting another stuck CLI process while still enforcing the minimum version. Never supply an unverified value.

Launch with:

```bash
claude-ds-flash
```

Additional arguments are forwarded unchanged after the wrapper's built-in `--dangerously-skip-permissions` flag. Every `claude-ds-flash` session starts in `bypassPermissions` mode, logs `mode=yolo`, and executes tool calls without permission prompts or normal safety checks. Use it only in trusted workspaces or isolated containers/VMs. Ordinary `claude` remains unchanged. Root/sudo execution or organization managed settings may reject bypass mode; there is no silent fallback.

## Effective model configuration

```text
ANTHROPIC_MODEL=deepseek-v4-flash
ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-flash
ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-flash
ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
CLAUDE_CODE_EFFORT_LEVEL=max
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
CLAUDE_CODE_AUTO_COMPACT_WINDOW=700000
```

The last two values are profile-scoped guardrails. Nonessential update, feedback, error-reporting, and telemetry traffic is disabled, while auto-compaction calculations use an effective 700,000-token capacity so a long 1M session reserves more room before the hard limit. Claude Code caps the configured capacity at the model's actual context window. This reduces but does not eliminate context-overflow risk from oversized prompts, attachments, or tool output.

## Validate

Run the loopback-only request check without using the real provider credential:

```bash
python3 scripts/validate_claude_mock.py \
  --settings "${HOME}/.claude/provider-switch/deepseek-flash.settings.json"
rg -q -- '--dangerously-skip-permissions' "${HOME}/.local/bin/claude-ds-flash"
```

For a real smoke request, obtain user authorization for possible provider cost and remote transmission, then use a content-free prompt, disable tools, limit the turn count and budget, and confirm `claude auth status` is unchanged afterward.

## Recovery

- Backups: `${HOME}/.claude/provider-switch-backups/<timestamp>/`.
- Restore a changed managed file from its matching backup.
- To stop using the profile, run `claude-ds-pro`, its `claude-ds` compatibility alias, or ordinary `claude`.
- To remove only this profile safely, move `deepseek-flash.settings.json` and `claude-ds-flash` to a backup directory or system trash.
