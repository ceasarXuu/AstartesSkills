#!/usr/bin/env bash

TMP_MODELS="unused"
cat > "$TMP_MODELS" <<'CODEX_MODELS_JSON'
{
  "models": [
    {
      "slug": "deepseek-v4-flash",
      "context_window": 1048576,
      "shell_type": "shell_command",
      "minimal_client_version": "0.144.0"
    },
    {
      "slug": "deepseek-v4-pro",
      "context_window": 1048576,
      "shell_type": "shell_command",
      "minimal_client_version": "0.144.0"
    }
  ]
}
CODEX_MODELS_JSON
