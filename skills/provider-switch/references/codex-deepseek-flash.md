# Codex CLI + DeepSeek V4 Flash

Use this package to add a temporary `codex-ds-flash` entry while preserving Codex's default config and ChatGPT login.

## Verify before every install

- DeepSeek Codex integration: <https://api-docs.deepseek.com/zh-cn/quick_start/agent_integrations/codex>
- OpenAI Codex configuration: <https://developers.openai.com/codex/config-reference>
- OpenAI Codex source schema: <https://github.com/openai/codex/blob/main/codex-rs/core/config.schema.json>

The auth-isolation incident was reproduced with Codex CLI `0.145.0`, and the initial packaged installer dry-run was verified with `0.146.0`. The bundled catalog declares `0.144.0` as the minimum for DeepSeek entries. Recheck these facts because models and configuration fields can change.

## Installed files

```text
${CODEX_HOME:-$HOME/.codex}/deepseek-flash.config.toml
${CODEX_HOME:-$HOME/.codex}/deepseek-models.json
${HOME}/.local/bin/codex-ds-flash
```

The installer does not modify `${CODEX_HOME:-$HOME/.codex}/config.toml` or any Codex auth store.

## Install

From the installed skill directory:

```bash
python3 scripts/install_codex_deepseek.py --open-editor
```

The installer downloads the official DeepSeek setup script as data, extracts its `models.json` payload without executing the script, validates the expected model entries, and writes dedicated side-load files atomically.

On the first install, replace `<YOUR_DEEPSEEK_API_KEY>` in the opened config. On later updates, the installer preserves an existing non-placeholder bearer token and does not open the editor.

Launch with:

```bash
codex-ds-flash
```

Additional arguments are forwarded unchanged. The wrapper enables YOLO through `--dangerously-bypass-approvals-and-sandbox`; run it only in a trusted workspace.

The official model catalog registers `low`, `high`, and `max`. In Codex CLI `0.146.0`, use `/model` (singular) to select the model and reasoning level; there is no separate native `/effort` command in this version. The configured `high` value is only the launch default.

## Authentication boundary

Keep these provider fields:

```toml
[model_providers.deepseek]
wire_api = "responses"
requires_openai_auth = false
experimental_bearer_token = "<YOUR_DEEPSEEK_API_KEY>"
```

Do not put `forced_login_method = "api"` or `preferred_auth_method = "apikey"` in the side-load file. `forced_login_method` constrains Codex's global login mechanism; when ChatGPT credentials already exist, Codex treats them as a policy violation and logs the user out. The provider bearer token already authenticates DeepSeek requests independently.

## Validate

Run static checks without spending provider tokens:

```bash
python3 -m json.tool "${CODEX_HOME:-$HOME/.codex}/deepseek-models.json" >/dev/null
codex -p deepseek-flash mcp list >/dev/null
sh -n "${HOME}/.local/bin/codex-ds-flash"
codex login status
```

For a request-path regression, override only `model_providers.deepseek.base_url` to a local mock Responses endpoint, verify an Authorization header is present without logging its value, and confirm `codex login status` is unchanged afterward.

Do not send a real prompt merely to validate installation unless the user accepts possible provider cost and remote data transmission.

## Recovery

- Installer backups: `${CODEX_HOME:-$HOME/.codex}/provider-switch-backups/<timestamp>/`.
- Restore a changed file by copying its matching backup over the managed target.
- If an older config already caused `Logging out`, remove the two global login-policy fields and run `codex login` to restore ChatGPT authentication.
- If the official payload validation fails, leave the current installation untouched and update the extractor only after checking the new official format.
