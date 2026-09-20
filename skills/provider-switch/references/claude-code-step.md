# Claude Code + Step Plan

Use this package to add an independent `claude-step` command backed by Step Plan and `step-5-preview`. It keeps Claude Code's global settings and saved claude.ai login unchanged.

## Verify before every install

- StepFun Claude Code integration: <https://platform.stepfun.com/docs/zh/step-plan/integrations/claude-code>
- Claude Code settings: <https://code.claude.com/docs/en/settings>
- Claude Code environment variables: <https://code.claude.com/docs/en/env-vars>
- Claude Code CLI reference: <https://code.claude.com/docs/en/cli-reference>
- Claude Code permission modes: <https://code.claude.com/docs/en/permission-modes>

The package is verified with Claude Code `2.1.218`, which is the declared minimum until an older version is tested. StepFun documents this Anthropic-compatible integration; Anthropic does not support non-Claude model behavior, so compatibility responsibility remains with StepFun.

## Installed files

```text
${HOME}/.claude/provider-switch/step.settings.json
${HOME}/.local/bin/claude-step
```

The installer does not modify `${HOME}/.claude/settings.json`, project settings, the Claude credential store, or any DeepSeek profile. Step and DeepSeek credentials are never imported across provider boundaries.

## Install and launch

```bash
python3 scripts/install_claude_step.py
claude-step
```

Credential priority is an existing Step profile token, `STEPFUN_API_KEY`, then `<YOUR_STEPFUN_API_KEY>`. A real token is written only to the dedicated `0600` settings and is never logged. If the placeholder remains, the installer opens the settings in VS Code when available; use `--no-open-editor` for automation.

Arguments are forwarded unchanged after `--dangerously-skip-permissions`. Thus every `claude-step` session starts in `bypassPermissions` mode, logs `mode=yolo`, and can run tools without permission prompts. Use it only in a trusted workspace or isolated environment. Ordinary `claude` remains unchanged, and there is no silent fallback if managed policy rejects bypass mode.

## Effective configuration

```text
ANTHROPIC_AUTH_TOKEN=<Step API key>
ANTHROPIC_BASE_URL=https://api.stepfun.com/step_plan
ANTHROPIC_MODEL=step-5-preview
model=step-5-preview
CLAUDE_CODE_MAX_CONTEXT_TOKENS=1000000
CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

The profile sets both the documented top-level `model` and `ANTHROPIC_MODEL` to prevent an older user-level provider environment from silently overriding Step. It also maps Claude's Opus, Sonnet, Haiku, and subagent aliases to `step-5-preview`, following StepFun's optional alias pattern. The 1M context values follow StepFun's documented `step-5-preview` setup. These client-side settings do not override server-side account permissions or quotas, and very large prompts or tool output can still overflow or fail compaction.

## Validate

Static and loopback-only checks do not spend Step credits:

```bash
python3 -m json.tool "${HOME}/.claude/provider-switch/step.settings.json" >/dev/null
sh -n "${HOME}/.local/bin/claude-step"
python3 scripts/validate_claude_mock.py \
  --settings "${HOME}/.claude/provider-switch/step.settings.json"
claude auth status
```

Only run a real provider prompt after explicit authorization for possible cost and remote transmission. Then use `/status` and `/context`, send a content-free prompt, and verify Step Plan channel usage separately; a successful response alone does not prove correct billing attribution.

## Recovery

- Backups: `${HOME}/.claude/provider-switch-backups/<timestamp>/`.
- Restore a changed managed file from its matching backup.
- To stop using the profile, run ordinary `claude`; the original login requires no recovery.
- To remove only this profile, move `step.settings.json` and `claude-step` to a backup directory or system trash.
