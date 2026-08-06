# Claude Code + DeepSeek

Use this package to add a temporary `claude-ds` entry while preserving Claude Code's global settings and saved claude.ai login.

## Verify before every install

- DeepSeek Claude Code integration: <https://api-docs.deepseek.com/zh-cn/quick_start/agent_integrations/claude_code>
- Claude Code gateway connection: <https://code.claude.com/docs/en/llm-gateway>
- Claude Code settings: <https://code.claude.com/docs/en/settings>
- Claude Code environment variables: <https://code.claude.com/docs/en/env-vars>
- Claude Code CLI reference: <https://code.claude.com/docs/en/cli-reference>
- Claude Code permission modes: <https://code.claude.com/docs/en/permission-modes>

The package was initially verified with Claude Code `2.1.218`, which is therefore the minimum declared version until an older release is tested. DeepSeek documents an Anthropic-compatible endpoint, but Anthropic does not support routing Claude Code to non-Claude models. Treat this combination as DeepSeek-supported compatibility rather than Anthropic-supported model behavior.

## Installed files

```text
${HOME}/.claude/provider-switch/deepseek.settings.json
${HOME}/.local/bin/claude-ds
```

The installer does not modify `${HOME}/.claude/settings.json`, project settings, or Claude Code's credential store.

## Install

From the installed skill directory:

```bash
python3 scripts/install_claude_deepseek.py
```

When the dedicated settings still contain `<YOUR_DEEPSEEK_API_KEY>`, the installer opens the file after installation so the user can fill it in. It prefers VS Code, then the macOS `open` command or Linux `xdg-open`. Use `--no-open-editor` in automation. Alternatively, provide `DEEPSEEK_API_KEY` in the installer process environment; the installer writes it to the dedicated `0600` settings file without logging it and does not open an editor. On later updates, an existing non-placeholder token takes precedence, is preserved, and does not trigger the editor.

The installer bounds `claude --version` detection to 10 seconds. If the CLI startup path is temporarily stuck but its version was already obtained separately, pass `--verified-claude-version <version>`; the installer still checks the declared minimum and logs `version_source=provided` without starting a second version process. Do not provide a guessed version.

Launch with:

```bash
claude-ds
```

Additional arguments are forwarded unchanged after the wrapper's built-in `--dangerously-skip-permissions` flag. Every `claude-ds` session therefore starts in `bypassPermissions` mode, logs `mode=yolo`, and executes tool calls without permission prompts or normal safety checks. Use this dedicated command only in trusted workspaces or isolated containers/VMs. Ordinary `claude` remains unchanged. Claude Code may reject bypass mode under root/sudo or when organization managed settings disable it; the wrapper does not silently fall back.

For a separate profile that uses V4 Flash for the main model and every submodel, read [claude-code-deepseek-flash.md](claude-code-deepseek-flash.md) and install `claude-ds-flash`. The two profiles coexist and do not overwrite each other's settings.

## Effective provider configuration

The dedicated settings file follows DeepSeek's documented environment mapping:

```text
ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
ANTHROPIC_MODEL=deepseek-v4-pro[1m]
ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]
ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]
ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
CLAUDE_CODE_EFFORT_LEVEL=max
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
CLAUDE_CODE_AUTO_COMPACT_WINDOW=700000
```

`ANTHROPIC_AUTH_TOKEN` holds the DeepSeek API key for this process. While that provider credential is active, the session does not use the saved claude.ai subscription credential. `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` disables auto-update, feedback, error-reporting, and telemetry traffic for the provider-switched process. `CLAUDE_CODE_AUTO_COMPACT_WINDOW=700000` makes auto-compaction calculations treat the context capacity as 700,000 tokens, reserving more room before a 1M session reaches its hard limit; Claude Code caps this value at the model's actual context window. This reduces but cannot eliminate context-overflow or compaction-failure risk from oversized prompts, attachments, or tool output.

With Claude Code `2.1.218`, the `[1m]` suffix is interpreted client-side: the Messages request sends model `deepseek-v4-pro` and includes the `context-1m` Anthropic beta capability. The bundled mock validator checks this transport behavior so a future Claude Code change is visible.

## Validate

Run static checks without spending provider tokens:

```bash
python3 -m json.tool "${HOME}/.claude/provider-switch/deepseek.settings.json" >/dev/null
sh -n "${HOME}/.local/bin/claude-ds"
rg -q -- '--dangerously-skip-permissions' "${HOME}/.local/bin/claude-ds"
claude auth status
```

For a request-path regression, copy the dedicated settings to a temporary file, replace only `ANTHROPIC_BASE_URL` with a local mock Anthropic Messages endpoint, and run a no-tools `claude -p` request with a strict budget. Verify that an authentication header is present without logging its value, then confirm `claude auth status` is unchanged.

The bundled validator performs that loopback-only check without using the real provider credential:

```bash
python3 scripts/validate_claude_mock.py
```

Do not send a real prompt merely to validate installation unless the user accepts possible provider cost and remote data transmission. Use a content-free prompt such as `Reply with exactly: DEEPSEEK_OK` and disable tools.

## Recovery

- Installer backups: `${HOME}/.claude/provider-switch-backups/<timestamp>/`.
- Restore a changed file by copying its matching backup over the managed target.
- To stop using the profile, run ordinary `claude`; no login recovery should be needed.
- To remove the side-load safely, move the two installed files to a backup directory or the system trash.
- If an update changes the settings schema or DeepSeek model names, leave the current installation untouched until both vendors' current documentation has been checked.
