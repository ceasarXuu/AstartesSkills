#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_dir="$repo_root/skills/provider-switch"
installer="$skill_dir/scripts/install_codex_deepseek.py"
catalog="$skill_dir/assets/providers.json"
config_asset="$skill_dir/assets/codex-deepseek-flash.config.toml"
wrapper_asset="$skill_dir/assets/codex-ds-flash"
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
PY

if rg -q '^(preferred_auth_method|forced_login_method)[[:space:]]*=' "$config_asset"; then
  fail "provider config must not contain global login-policy fields"
fi
rg -q '^requires_openai_auth[[:space:]]*=[[:space:]]*false$' "$config_asset"
rg -q '^exec codex -p deepseek-flash --dangerously-bypass-approvals-and-sandbox "\$@"$' "$wrapper_asset"
python3 - "$installer" <<'PY'
import ast
import sys
from pathlib import Path

ast.parse(Path(sys.argv[1]).read_text(encoding="utf-8"))
PY

runtime_root="$(mktemp -d "${TMPDIR:-/tmp}/provider-switch-test.XXXXXX")"
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

log "provider-switch sanity passed"
