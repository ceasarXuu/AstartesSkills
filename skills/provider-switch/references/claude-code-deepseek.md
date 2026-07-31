# Claude Code + DeepSeek

Use this package to add a temporary `claude-ds` entry while preserving Claude Code's global settings and saved claude.ai login.

## Verify before every install

- DeepSeek Claude Code integration: <https://api-docs.deepseek.com/zh-cn/quick_start/agent_integrations/claude_code>
- Claude Code gateway connection: <https://code.claude.com/docs/en/llm-gateway>
- Claude Code settings: <https://code.claude.com/docs/en/settings>
- Claude Code CLI reference: <https://code.claude.com/docs/en/cli-reference>

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
python3 scripts/install_claude_deepseek.py --open-editor
```

Replace `<YOUR_DEEPSEEK_API_KEY>` in the opened settings file. Alternatively, provide `DEEPSEEK_API_KEY` in the installer process environment; the installer writes it to the dedicated `0600` settings file without logging it. On later updates, an existing non-placeholder token takes precedence and is preserved.

Launch with:

```bash
claude-ds
```

Additional arguments are forwarded unchanged. Unlike the bundled Codex wrapper, this launcher keeps Claude Code's default permission prompts and does not enable `--dangerously-skip-permissions`.

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
```

`ANTHROPIC_AUTH_TOKEN` holds the DeepSeek API key for this process. While that provider credential is active, the session does not use the saved claude.ai subscription credential. `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` prevents nonessential telemetry and error-reporting traffic from the provider-switched process.

With Claude Code `2.1.218`, the `[1m]` suffix is interpreted client-side: the Messages request sends model `deepseek-v4-pro` and marks the extended-context request in the URL. The bundled mock validator checks this transport behavior so a future Claude Code change is visible.

## Validate

Run static checks without spending provider tokens:

```bash
python3 -m json.tool "${HOME}/.claude/provider-switch/deepseek.settings.json" >/dev/null
sh -n "${HOME}/.local/bin/claude-ds"
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
