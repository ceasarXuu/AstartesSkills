# Codex CLI + DeepSeek V4 Pro

Use this package to add a temporary `codex-ds-pro` entry while preserving Codex's default config and ChatGPT login.

## Verify before every install

- DeepSeek Codex integration: <https://api-docs.deepseek.com/zh-cn/quick_start/agent_integrations/codex>
- DeepSeek models and pricing: <https://api-docs.deepseek.com/quick_start/pricing>
- OpenAI Codex configuration: <https://developers.openai.com/codex/config-reference>
- OpenAI Codex source schema: <https://github.com/openai/codex/blob/main/codex-rs/core/config.schema.json>

DeepSeek's official payload declares `deepseek-v4-pro`, a 1,048,576-token context window, the Responses wire API, and Codex CLI `0.144.0` as the minimum client version. Recheck these unstable facts before every install.

## Installed files

```text
${CODEX_HOME:-$HOME/.codex}/deepseek-pro.config.toml
${CODEX_HOME:-$HOME/.codex}/deepseek-models.json
${HOME}/.local/bin/codex-ds-pro
```

The installer does not modify `${CODEX_HOME:-$HOME/.codex}/config.toml` or any Codex auth store. It shares only the validated model catalog with `codex-ds-flash`.

## Install

```bash
python3 scripts/install_codex_deepseek_pro.py --open-editor
```

The installer downloads the official DeepSeek setup script as data without executing it, validates both V4 model entries, and writes the dedicated side-load atomically. Credential priority is the existing Pro config, the sibling Flash config, then the placeholder. A real credential is never logged, and the editor opens only while the placeholder remains.

Launch with:

```bash
codex-ds-pro
```

Additional arguments are forwarded unchanged. The wrapper enables YOLO through `--dangerously-bypass-approvals-and-sandbox`; run it only in a trusted workspace.

## Effective provider configuration

```toml
model = "deepseek-v4-pro"
model_reasoning_effort = "max"

[model_providers.deepseek]
base_url = "https://api.deepseek.com/"
wire_api = "responses"
requires_openai_auth = false
```

The dedicated `experimental_bearer_token` authenticates DeepSeek independently. Do not add `forced_login_method` or `preferred_auth_method`; those fields can invalidate the existing ChatGPT login boundary.

The official model catalog registers `low`, `high`, and `max`. In Codex CLI `0.146.0`, run `/model` (singular), select `deepseek-v4-pro`, then choose the reasoning level. Codex does not currently expose a separate `/effort` command. The profile value above is only the launch default and does not remove the session picker.

## Validate

```bash
python3 -m json.tool "${CODEX_HOME:-$HOME/.codex}/deepseek-models.json" >/dev/null
codex -p deepseek-pro mcp list >/dev/null
sh -n "${HOME}/.local/bin/codex-ds-pro"
codex login status
```

The repository sanity test uses an offline official-payload fixture and a fake Codex command. A real provider smoke request can spend money and transmit prompt data, so run it only with explicit authorization.

## Recovery

- Backups: `${CODEX_HOME:-$HOME/.codex}/provider-switch-backups/<timestamp>/`.
- Restore a changed managed file from its matching backup.
- To stop using the profile, run ordinary `codex`; no login recovery should be needed.
- To remove only this profile safely, move `deepseek-pro.config.toml` and `codex-ds-pro` to a backup directory or system trash.
