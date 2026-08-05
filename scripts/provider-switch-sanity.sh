#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_dir="$repo_root/skills/provider-switch"
installer="$skill_dir/scripts/install_codex_deepseek.py"
claude_installer="$skill_dir/scripts/install_claude_deepseek.py"
claude_flash_installer="$skill_dir/scripts/install_claude_deepseek_flash.py"
catalog="$skill_dir/assets/providers.json"
config_asset="$skill_dir/assets/codex-deepseek-flash.config.toml"
wrapper_asset="$skill_dir/assets/codex-ds-flash"
claude_settings_asset="$skill_dir/assets/claude-code-deepseek.settings.json"
claude_flash_settings_asset="$skill_dir/assets/claude-code-deepseek-flash.settings.json"
claude_wrapper_asset="$skill_dir/assets/claude-ds"
fixture="$repo_root/tests/provider-switch/fixtures/codex-deepseek-setup.sh"

log() {
  echo "[provider-switch-test] $*"
}

fail() {
  echo "[provider-switch-test] ERROR: $*" >&2
  exit 1
}

log "checking skill contract and catalog"
rg -q '^name: provider-switch$' "$skill_dir/SKILL.md"
rg -q 'temporary profiles' "$skill_dir/SKILL.md"
rg -q 'preserve existing non-placeholder secrets' "$skill_dir/SKILL.md"
rg -q 'login state before and after' "$skill_dir/SKILL.md"

python3 - "$catalog" "$skill_dir" <<'PY'
import json
import sys
from pathlib import Path

catalog_path = Path(sys.argv[1])
skill_dir = Path(sys.argv[2])
data = json.loads(catalog_path.read_text(encoding="utf-8"))
assert data["schema_version"] == 1
ids = []
for item in data["providers"]:
    ids.append(item["id"])
    assert (skill_dir / item["reference"]).is_file()
    assert (skill_dir / item["installer"]).is_file()
assert len(ids) == len(set(ids))
assert "codex-deepseek-flash" in ids
assert "claude-code-deepseek" in ids
assert "claude-code-deepseek-flash" in ids
PY

if rg -q '^(preferred_auth_method|forced_login_method)[[:space:]]*=' "$config_asset"; then
  fail "provider config must not contain global login-policy fields"
fi
rg -q '^requires_openai_auth[[:space:]]*=[[:space:]]*false$' "$config_asset"
rg -q '^exec codex -p deepseek-flash --dangerously-bypass-approvals-and-sandbox "\$@"$' "$wrapper_asset"
python3 -m json.tool "$claude_settings_asset" >/dev/null
rg -q 'https://api.deepseek.com/anthropic' "$claude_settings_asset"
rg -q 'deepseek-v4-pro\[1m\]' "$claude_settings_asset"
rg -q 'deepseek-v4-flash' "$claude_settings_asset"
python3 -m json.tool "$claude_flash_settings_asset" >/dev/null
python3 - "$claude_flash_settings_asset" <<'PY'
import json
import sys
from pathlib import Path

env = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))["env"]
model_fields = [
    "ANTHROPIC_MODEL",
    "ANTHROPIC_DEFAULT_OPUS_MODEL",
    "ANTHROPIC_DEFAULT_SONNET_MODEL",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL",
    "CLAUDE_CODE_SUBAGENT_MODEL",
]
assert all(env[field] == "deepseek-v4-flash" for field in model_fields)
PY
rg -q '^exec claude --settings "\$provider_switch_settings" --dangerously-skip-permissions "\$@"$' "$claude_wrapper_asset"
rg -q 'mode=yolo' "$claude_wrapper_asset"
python3 - "$installer" "$claude_installer" "$claude_flash_installer" "$skill_dir/scripts/validate_claude_mock.py" <<'PY'
import ast
import sys
from pathlib import Path

for item in sys.argv[1:]:
    ast.parse(Path(item).read_text(encoding="utf-8"))
PY

temp_parent="${TMPDIR:-/tmp}"
runtime_root="$(mktemp -d "${temp_parent%/}/provider-switch-test.XXXXXX")"
trap 'rm -rf "$runtime_root"' EXIT
test_home="$runtime_root/codex-home"
test_bin="$runtime_root/bin"
fake_bin="$runtime_root/fake-bin"
mkdir -p "$test_home" "$test_bin" "$fake_bin"

cat > "$fake_bin/codex" <<'SH'
#!/bin/sh
if [ "${1:-}" = "--version" ]; then
  printf '%s\n' 'codex-cli 0.145.0'
  exit 0
fi
printf '%s\n' "$@"
SH
chmod 755 "$fake_bin/codex"

cat > "$fake_bin/claude" <<'SH'
#!/bin/sh
if [ "${1:-}" = "--version" ]; then
  printf '%s\n' '2.1.218 (Claude Code)'
  exit 0
fi
printf '%s\n' "$@"
SH
chmod 755 "$fake_bin/claude"

cat > "$fake_bin/slow-claude" <<'SH'
#!/bin/sh
if [ "${1:-}" = "--version" ]; then
  sleep 2
  printf '%s\n' '2.1.218 (Claude Code)'
  exit 0
fi
exit 0
SH
chmod 755 "$fake_bin/slow-claude"

cat > "$fake_bin/code" <<'SH'
#!/bin/sh
exit 0
SH
chmod 755 "$fake_bin/code"

log "checking bounded Claude version detection"
slow_home="$runtime_root/slow-claude-home"
if python3 "$claude_installer" --claude-home "$slow_home" --bin-dir "$runtime_root/slow-bin" --claude-command "$fake_bin/slow-claude" --version-timeout 0.1 --no-open-editor > "$runtime_root/slow-claude.log" 2>&1; then
  fail "slow Claude version detection unexpectedly succeeded"
fi
rg -q '\[provider-switch\] ERROR Claude version check timed out after 0.1s' "$runtime_root/slow-claude.log"
[[ ! -e "$slow_home/provider-switch/deepseek.settings.json" ]] || fail "version timeout created partial Claude settings"

log "checking explicit verified Claude version override"
verified_home="$runtime_root/verified-claude-home"
python3 "$claude_installer" --claude-home "$verified_home" --bin-dir "$runtime_root/verified-bin" --claude-command "$fake_bin/slow-claude" --verified-claude-version 2.1.218 --no-open-editor > "$runtime_root/verified-claude.log"
rg -q '\[provider-switch\] validate claude=2.1.218 command=.*slow-claude version_source=provided' "$runtime_root/verified-claude.log"
[[ -f "$verified_home/provider-switch/deepseek.settings.json" ]]

install_cmd=(
  python3 "$installer"
  --codex-home "$test_home"
  --bin-dir "$test_bin"
  --setup-script "$fixture"
  --codex-command "$fake_bin/codex"
)

log "checking first install"
"${install_cmd[@]}" > "$runtime_root/first.log"
[[ -f "$test_home/deepseek-flash.config.toml" ]]
[[ -f "$test_home/deepseek-models.json" ]]
[[ -x "$test_bin/codex-ds-flash" ]]
rg -q '<YOUR_DEEPSEEK_API_KEY>' "$test_home/deepseek-flash.config.toml"
python3 - "$test_home" "$test_bin" <<'PY'
import stat
import sys
from pathlib import Path

home = Path(sys.argv[1])
bin_dir = Path(sys.argv[2])
assert stat.S_IMODE((home / "deepseek-flash.config.toml").stat().st_mode) == 0o600
assert stat.S_IMODE((home / "deepseek-models.json").stat().st_mode) == 0o600
assert stat.S_IMODE((bin_dir / "codex-ds-flash").stat().st_mode) == 0o755
PY

log "checking existing-key preservation and idempotency"
python3 - "$test_home/deepseek-flash.config.toml" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
path.write_text(text.replace("<YOUR_DEEPSEEK_API_KEY>", "diagnostic-provider-token"), encoding="utf-8")
PY
"${install_cmd[@]}" > "$runtime_root/second.log"
rg -q 'diagnostic-provider-token' "$test_home/deepseek-flash.config.toml"
if rg -q 'diagnostic-provider-token' "$runtime_root/second.log"; then
  fail "installer logged a provider key"
fi
rg -q '\[provider-switch\] preserve credential=existing-provider-bearer' "$runtime_root/second.log"
rg -q '\[provider-switch\] unchanged target=.*deepseek-flash.config.toml' "$runtime_root/second.log"

log "checking changed-file backup"
printf '%s\n' '{"changed":true}' > "$test_home/deepseek-models.json"
"${install_cmd[@]}" > "$runtime_root/update.log"
backup_catalog="$(find "$test_home/provider-switch-backups" -name deepseek-models.json -type f -print -quit)"
[[ -n "$backup_catalog" ]] || fail "missing recoverable catalog backup"
rg -q '\[provider-switch\] backup source=' "$runtime_root/update.log"
printf '%s\n' '{"changed":"again"}' > "$test_home/deepseek-models.json"
"${install_cmd[@]}" > "$runtime_root/update-again.log"
backup_count="$(find "$test_home/provider-switch-backups" -name deepseek-models.json -type f | wc -l | tr -d ' ')"
[[ "$backup_count" -ge 2 ]] || fail "same-second backups collided"

log "checking empty CODEX_HOME fallback and editor target"
(
  cd "$runtime_root"
  CODEX_HOME='' python3 "$installer" --dry-run --bin-dir "$test_bin" --setup-script "$fixture" --codex-command "$fake_bin/codex"
) > "$runtime_root/empty-home.log"
rg -q "target=$HOME/.codex/deepseek-flash.config.toml" "$runtime_root/empty-home.log"
rg -q 'config_path}:13' "$installer"

log "checking invalid-payload failure atomicity"
printf '%s\n' 'invalid setup payload' > "$runtime_root/invalid-setup.sh"
bad_home="$runtime_root/bad-home"
if python3 "$installer" --codex-home "$bad_home" --bin-dir "$runtime_root/bad-bin" --setup-script "$runtime_root/invalid-setup.sh" --codex-command "$fake_bin/codex" > "$runtime_root/invalid.log" 2>&1; then
  fail "invalid setup payload unexpectedly succeeded"
fi
[[ ! -e "$bad_home/deepseek-models.json" ]] || fail "invalid payload created a partial catalog"
rg -q '\[provider-switch\] ERROR' "$runtime_root/invalid.log"

log "checking wrapper argument forwarding and redacted launch log"
PATH="$fake_bin:$PATH" CODEX_HOME="$test_home" "$test_bin/codex-ds-flash" --version 'argument with spaces' > "$runtime_root/wrapper.out" 2> "$runtime_root/wrapper.err"
rg -q 'auth=provider-bearer' "$runtime_root/wrapper.err"
rg -q '^-p$' "$runtime_root/wrapper.out"
rg -q '^deepseek-flash$' "$runtime_root/wrapper.out"
rg -q '^--dangerously-bypass-approvals-and-sandbox$' "$runtime_root/wrapper.out"
rg -q '^argument with spaces$' "$runtime_root/wrapper.out"
if rg -q 'diagnostic-provider-token' "$runtime_root/wrapper.err"; then
  fail "wrapper logged a provider key"
fi

log "checking Claude Code first install and global-settings isolation"
claude_home="$runtime_root/claude-home"
claude_bin="$runtime_root/claude-bin"
mkdir -p "$claude_home" "$claude_bin"
printf '%s\n' '{"marker":"preserve-global-settings"}' > "$claude_home/settings.json"
global_settings_hash="$(shasum -a 256 "$claude_home/settings.json" | awk '{print $1}')"
claude_install_cmd=(
  python3 "$claude_installer"
  --claude-home "$claude_home"
  --bin-dir "$claude_bin"
  --claude-command "$fake_bin/claude"
  --no-open-editor
)
"${claude_install_cmd[@]}" > "$runtime_root/claude-first.log"
claude_settings="$claude_home/provider-switch/deepseek.settings.json"
[[ -f "$claude_settings" ]]
[[ -x "$claude_bin/claude-ds" ]]
rg -q '<YOUR_DEEPSEEK_API_KEY>' "$claude_settings"
if rg -q '\[provider-switch\] editor ' "$runtime_root/claude-first.log"; then
  fail "--no-open-editor unexpectedly launched an editor"
fi
[[ "$global_settings_hash" = "$(shasum -a 256 "$claude_home/settings.json" | awk '{print $1}')" ]]
python3 - "$claude_settings" "$claude_bin/claude-ds" <<'PY'
import stat
import sys
from pathlib import Path

settings = Path(sys.argv[1])
wrapper = Path(sys.argv[2])
assert stat.S_IMODE(settings.stat().st_mode) == 0o600
assert stat.S_IMODE(wrapper.stat().st_mode) == 0o755
PY

log "checking Claude Code default editor launch for a missing key"
editor_home="$runtime_root/editor-home"
editor_bin="$runtime_root/editor-bin"
PATH="$fake_bin:$PATH" python3 "$claude_installer" --claude-home "$editor_home" --bin-dir "$editor_bin" --claude-command "$fake_bin/claude" > "$runtime_root/claude-editor.log"
rg -q '\[provider-switch\] complete ' "$runtime_root/claude-editor.log"
rg -q '\[provider-switch\] next add-provider-key=' "$runtime_root/claude-editor.log"
rg -q '\[provider-switch\] editor target=.*deepseek.settings.json opener=code' "$runtime_root/claude-editor.log"
python3 - "$runtime_root/claude-editor.log" <<'PY'
import sys
from pathlib import Path

lines = Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()
complete = next(index for index, line in enumerate(lines) if " complete " in line)
editor = next(index for index, line in enumerate(lines) if " editor " in line)
assert complete < editor
PY

log "checking Claude Code credential import, preservation, and idempotency"
DEEPSEEK_API_KEY='diagnostic-claude-token' "${claude_install_cmd[@]}" > "$runtime_root/claude-key.log"
rg -q 'diagnostic-claude-token' "$claude_settings"
if rg -q 'diagnostic-claude-token' "$runtime_root/claude-key.log"; then
  fail "Claude installer logged a provider key"
fi
rg -q '\[provider-switch\] import credential=environment name=DEEPSEEK_API_KEY' "$runtime_root/claude-key.log"
"${claude_install_cmd[@]}" > "$runtime_root/claude-second.log"
rg -q '\[provider-switch\] preserve credential=existing-provider-token' "$runtime_root/claude-second.log"
rg -q '\[provider-switch\] unchanged target=.*deepseek.settings.json' "$runtime_root/claude-second.log"
if rg -q 'diagnostic-claude-token' "$runtime_root/claude-second.log"; then
  fail "Claude installer logged a preserved provider key"
fi
PATH="$fake_bin:$PATH" python3 "$claude_installer" --claude-home "$claude_home" --bin-dir "$claude_bin" --claude-command "$fake_bin/claude" > "$runtime_root/claude-existing-key-editor.log"
if rg -q '\[provider-switch\] editor ' "$runtime_root/claude-existing-key-editor.log"; then
  fail "existing provider key unexpectedly launched an editor"
fi

log "checking Claude Code all-Flash profile and sibling-key import"
claude_flash_install_cmd=(
  python3 "$claude_flash_installer"
  --claude-home "$claude_home"
  --bin-dir "$claude_bin"
  --claude-command "$fake_bin/claude"
  --no-open-editor
)
"${claude_flash_install_cmd[@]}" > "$runtime_root/claude-flash-first.log"
claude_flash_settings="$claude_home/provider-switch/deepseek-flash.settings.json"
[[ -f "$claude_flash_settings" ]]
[[ -x "$claude_bin/claude-ds-flash" ]]
rg -q 'diagnostic-claude-token' "$claude_flash_settings"
rg -q '\[provider-switch\] import credential=sibling-profile profile=claude-code-deepseek' "$runtime_root/claude-flash-first.log"
if rg -q 'diagnostic-claude-token' "$runtime_root/claude-flash-first.log"; then
  fail "Flash installer logged an imported provider key"
fi
python3 - "$claude_flash_settings" "$claude_bin/claude-ds-flash" <<'PY'
import json
import stat
import sys
from pathlib import Path

settings = Path(sys.argv[1])
wrapper = Path(sys.argv[2])
env = json.loads(settings.read_text(encoding="utf-8"))["env"]
for field in (
    "ANTHROPIC_MODEL",
    "ANTHROPIC_DEFAULT_OPUS_MODEL",
    "ANTHROPIC_DEFAULT_SONNET_MODEL",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL",
    "CLAUDE_CODE_SUBAGENT_MODEL",
):
    assert env[field] == "deepseek-v4-flash"
assert stat.S_IMODE(settings.stat().st_mode) == 0o600
assert stat.S_IMODE(wrapper.stat().st_mode) == 0o755
PY
"${claude_flash_install_cmd[@]}" > "$runtime_root/claude-flash-second.log"
rg -q '\[provider-switch\] preserve credential=existing-provider-token' "$runtime_root/claude-flash-second.log"
rg -q '\[provider-switch\] unchanged target=.*deepseek-flash.settings.json' "$runtime_root/claude-flash-second.log"
rg -q '\[provider-switch\] unchanged target=.*claude-ds-flash' "$runtime_root/claude-flash-second.log"

log "checking Claude Code all-Flash wrapper model and argument forwarding"
PATH="$fake_bin:$PATH" "$claude_bin/claude-ds-flash" --version 'flash argument with spaces' > "$runtime_root/claude-flash-wrapper.out" 2> "$runtime_root/claude-flash-wrapper.err"
rg -q 'model=deepseek-v4-flash fast_model=deepseek-v4-flash' "$runtime_root/claude-flash-wrapper.err"
rg -q '^--settings$' "$runtime_root/claude-flash-wrapper.out"
rg -Fqx "$claude_flash_settings" "$runtime_root/claude-flash-wrapper.out"
rg -q '^--dangerously-skip-permissions$' "$runtime_root/claude-flash-wrapper.out"
rg -q '^flash argument with spaces$' "$runtime_root/claude-flash-wrapper.out"
if rg -q 'diagnostic-claude-token' "$runtime_root/claude-flash-wrapper.err"; then
  fail "Flash wrapper logged a provider key"
fi

log "checking Claude Code changed-file backup"
python3 - "$claude_settings" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
data["unmanaged-test-field"] = True
path.write_text(json.dumps(data), encoding="utf-8")
PY
"${claude_install_cmd[@]}" > "$runtime_root/claude-update.log"
backup_settings="$(find "$claude_home/provider-switch-backups" -name claude-deepseek.settings.json -type f -print -quit)"
[[ -n "$backup_settings" ]] || fail "missing recoverable Claude settings backup"
rg -q '\[provider-switch\] backup source=' "$runtime_root/claude-update.log"

log "checking Claude Code invalid-existing-settings failure atomicity"
bad_claude_home="$runtime_root/bad-claude-home"
bad_claude_bin="$runtime_root/bad-claude-bin"
mkdir -p "$bad_claude_home/provider-switch"
printf '%s\n' '{invalid' > "$bad_claude_home/provider-switch/deepseek.settings.json"
if python3 "$claude_installer" --claude-home "$bad_claude_home" --bin-dir "$bad_claude_bin" --claude-command "$fake_bin/claude" > "$runtime_root/claude-invalid.log" 2>&1; then
  fail "invalid existing Claude settings unexpectedly succeeded"
fi
[[ ! -e "$bad_claude_bin/claude-ds" ]] || fail "invalid settings created a partial Claude wrapper"
rg -q '\[provider-switch\] ERROR' "$runtime_root/claude-invalid.log"

log "checking Claude Code wrapper argument forwarding and redacted launch log"
PATH="$fake_bin:$PATH" "$claude_bin/claude-ds" --version 'argument with spaces' > "$runtime_root/claude-wrapper.out" 2> "$runtime_root/claude-wrapper.err"
rg -q 'auth=provider-token' "$runtime_root/claude-wrapper.err"
rg -q '^--settings$' "$runtime_root/claude-wrapper.out"
rg -Fqx "$claude_settings" "$runtime_root/claude-wrapper.out"
rg -q '^--dangerously-skip-permissions$' "$runtime_root/claude-wrapper.out"
rg -q '^argument with spaces$' "$runtime_root/claude-wrapper.out"
if rg -q 'diagnostic-claude-token' "$runtime_root/claude-wrapper.err"; then
  fail "Claude wrapper logged a provider key"
fi

log "provider-switch sanity passed"
