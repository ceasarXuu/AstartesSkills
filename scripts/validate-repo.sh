#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
registry_file="$repo_root/registry/skills.json"

log() {
  echo "[validate] $*"
}

fail() {
  echo "[validate] ERROR: $*" >&2
  exit 1
}

[[ -d "$skills_dir" ]] || fail "missing skills directory"
[[ -f "$registry_file" ]] || fail "missing registry/skills.json"

log "checking registry json"
python3 - <<'PY' "$registry_file" || exit 1
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    data = json.load(handle)

assert isinstance(data.get("skills"), list)
PY

log "checking release metadata"
python3 - <<'PY' "$registry_file" "$repo_root" || exit 1
import json
import sys
from pathlib import Path

registry_path = Path(sys.argv[1])
repo_root = Path(sys.argv[2])
required_fields = ("version", "published_at", "publisher", "changes")

with registry_path.open("r", encoding="utf-8") as handle:
    registry = json.load(handle)

for skill in registry.get("skills", []):
    skill_id = skill.get("id", "<missing-id>")
    release = skill.get("release")
    assert isinstance(release, dict), f"missing registry release metadata for {skill_id}"

    for field in required_fields:
      assert field in release, f"missing registry release field '{field}' for {skill_id}"

    assert isinstance(release["version"], str) and release["version"].strip(), f"invalid registry release version for {skill_id}"
    assert isinstance(release["published_at"], str) and release["published_at"].strip(), f"invalid registry published_at for {skill_id}"
    assert isinstance(release["publisher"], str) and release["publisher"].strip(), f"invalid registry publisher for {skill_id}"
    assert isinstance(release["changes"], list) and release["changes"], f"invalid registry changes list for {skill_id}"
    assert all(isinstance(item, str) and item.strip() for item in release["changes"]), f"invalid registry change entry for {skill_id}"

    manifest_relpath = (
        skill.get("markets", {})
        .get("openai-compatible", {})
        .get("manifest")
    )
    if not manifest_relpath:
        continue

    manifest_path = repo_root / manifest_relpath
    with manifest_path.open("r", encoding="utf-8") as handle:
        manifest = json.load(handle)

    manifest_release = manifest.get("release")
    assert isinstance(manifest_release, dict), f"missing manifest release metadata for {skill_id}"
    assert manifest_release == release, f"release metadata mismatch between registry and manifest for {skill_id}"
PY

log "checking skill folders"

while IFS= read -r skill_dir; do
  skill_name="$(basename "$skill_dir")"

  if [[ "$skill_name" == "_templates" ]]; then
    continue
  fi

  [[ -f "$skill_dir/SKILL.md" ]] || fail "$skill_name is missing SKILL.md"
  [[ -f "$skill_dir/agents/openai.yaml" ]] || fail "$skill_name is missing agents/openai.yaml"
done < <(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d | sort)

log "checking registry paths"

while IFS= read -r path; do
  [[ -d "$repo_root/$path" ]] || fail "registry path does not exist: $path"
done < <(
  sed -n 's/.*"path": "\(skills\/[^"]*\)".*/\1/p' "$registry_file"
)

log "checking market manifests"

while IFS= read -r manifest; do
  python3 - <<'PY' "$repo_root/$manifest" || exit 1
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as handle:
    json.load(handle)
PY
done < <(
  sed -n 's/.*"manifest": "\(skills\/[^"]*markets\/[^"]*\.json\)".*/\1/p' "$registry_file"
)

log "checking review reports"

if [[ -d "$repo_root/vs_review" ]]; then
  while IFS= read -r report; do
    python3 - <<'PY' "$report" "$repo_root" || exit 1
import re
import sys
from pathlib import Path

report = Path(sys.argv[1])
repo_root = Path(sys.argv[2])
relpath = report.relative_to(repo_root)
text = report.read_text(encoding="utf-8")

def fail(message: str) -> None:
    raise AssertionError(f"review report {relpath} {message}")

if not text.strip():
    fail("is empty")

required = (
    "### Review Input",
    "### Reviewer Selection",
    "### Reviewer Launch Records",
    "### Reviewer Outputs",
    "### Main Agent Response",
    "### Closure Status",
    "## Final Conclusion",
)
for section in required:
    if section not in text:
        fail(f"missing section: {section}")

header = text.split("## Round ", 1)[0].lower()
if "status: open" in header:
    fail("is not closed; status is open")

if text.count("## Final Conclusion") != 1:
    fail("must contain exactly one final conclusion")

round_matches = list(re.finditer(r"(?m)^## Round (\d+):", text))
rounds = []
for position, match in enumerate(round_matches):
    start = match.start()
    end = round_matches[position + 1].start() if position + 1 < len(round_matches) else text.find("## Final Conclusion")
    if end == -1:
        end = len(text)
    rounds.append((int(match.group(1)), text[start:end]))
if not rounds:
    fail("has no review rounds")

for index, round_text in rounds:
    for section in required[:-1]:
        if section not in round_text:
            fail(f"round {index} missing section: {section}")

    launch_section = round_text.split("### Reviewer Launch Records", 1)[1].split("### Reviewer Outputs", 1)[0]
    if "Session / Job ID" not in launch_section or "Trace Source" not in launch_section or "Context Forked" not in launch_section:
        fail(f"round {index} launch records missing required columns")

    launch_rows = [
        line for line in launch_section.splitlines()
        if line.startswith("|") and "adversary" in line
    ]
    if not launch_rows:
        fail(f"round {index} has no reviewer launch rows")
    launched_reviewers = []
    for row in launch_rows:
        cells = [cell.strip() for cell in row.strip("|").split("|")]
        if len(cells) < 8:
            fail(f"round {index} has incomplete launch row")
        launched_reviewers.append(cells[0])
        if not cells[2] or cells[2].lower() in {"pending", "to be recorded after spawn"}:
            fail(f"round {index} launch row missing session id")
        if not cells[3] or "tool call" not in cells[3].lower():
            fail(f"round {index} launch row missing trace source")
        if "fork_context=false" not in cells[4].lower():
            fail(f"round {index} launch row does not prove context isolation")

    reviewer_outputs = round_text.split("### Reviewer Outputs", 1)[1].split("### Main Agent Response", 1)[0]
    reviewer_block_matches = list(re.finditer(r"(?m)^#### ([^\n]+)", reviewer_outputs))
    if not reviewer_block_matches:
        fail(f"round {index} has no reviewer output blocks")
    reviewer_names = [match.group(1).strip() for match in reviewer_block_matches]
    for reviewer in launched_reviewers:
        if reviewer not in reviewer_names:
            fail(f"round {index} missing reviewer output for {reviewer}")
    for position, match in enumerate(reviewer_block_matches):
        block_start = match.end()
        block_end = reviewer_block_matches[position + 1].start() if position + 1 < len(reviewer_block_matches) else len(reviewer_outputs)
        block = reviewer_outputs[block_start:block_end]
        required_buckets = (
            "Summary",
            "Blocking Findings",
            "Non-blocking Risks",
            "Required Fixes",
            "Missing Tests",
            "Missing Logs / Observability",
            "Evidence",
        )
        for bucket in required_buckets:
            heading = f"##### {bucket}"
            if heading not in block:
                fail(f"round {index} reviewer {match.group(1).strip()} missing {heading}")
        for bucket in required_buckets:
            bucket_match = re.search(rf"##### {re.escape(bucket)}\n(?P<body>.*?)(?=\n##### |\Z)", block, re.S)
            if not bucket_match or len(bucket_match.group("body").strip()) < 12:
                fail(f"round {index} reviewer {match.group(1).strip()} has thin {bucket}")

    response = round_text.split("### Main Agent Response", 1)[1].split("### Closure Status", 1)[0]
    response_lines = [
        line for line in response.splitlines()
        if line.startswith("|") and "|---" not in line and "Reviewer | Finding" not in line
    ]
    response_rows = []
    for line in response_lines:
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) >= 7:
            response_rows.append(cells)
    if not any(row[2] in {"blocking", "major", "minor"} and row[3] in {"accept", "reject", "defer"} for row in response_rows):
        fail(f"round {index} has no populated main-agent response row")
    accepted_blocking_rows = [
        row for row in response_rows
        if len(row) >= 7 and row[2] == "blocking" and row[3] == "accept"
    ]
    for row in accepted_blocking_rows:
        if not re.search(r"Round \d+", row[6]):
            fail(f"round {index} accepted blocking row lacks follow-up round reference")

    closure = round_text.split("### Closure Status", 1)[1].split("\n## ", 1)[0]
    lower_closure = closure.lower()
    for forbidden in (
        "to be recorded",
        "will be recorded",
        "unresolved before",
        "allowed to proceed: no",
        "blocking re-review completed: no",
        "blocking re-review passed: no",
        "findings found: pending",
        "accepted blocking findings fixed: pending",
        "rejected findings backed by evidence: pending",
        "deferred findings documented: pending",
    ):
        if forbidden in lower_closure:
            fail(f"round {index} closure is not closed; found '{forbidden}'")
    if "Allowed to proceed: yes" not in closure:
        fail(f"round {index} is not allowed to proceed")
    if "Blocking re-review completed: yes" not in closure:
        fail(f"round {index} missing completed blocking re-review")
    if "Blocking re-review passed: yes" not in closure:
        fail(f"round {index} missing passed blocking re-review")
    if accepted_blocking_rows:
        if not re.search(r"Blocking re-review round links:\n(?:  - Round \d+: .+\n)+", closure):
            fail(f"round {index} accepted blocking findings lack concrete follow-up round links")
        if not re.search(r"Blocking re-review launch records:\n(?:  - Round \d+ Reviewer Launch Records: .+\n)+", closure):
            fail(f"round {index} accepted blocking findings lack concrete launch-record links")
        concrete_round_links = re.findall(r"(?m)^  - Round \d+: .+", closure)
        concrete_launch_links = re.findall(r"(?m)^  - Round \d+ Reviewer Launch Records: .+", closure)
        if len(concrete_round_links) < len(accepted_blocking_rows):
            fail(f"round {index} has fewer follow-up round links than accepted blocking findings")
        if len(concrete_launch_links) < len(accepted_blocking_rows):
            fail(f"round {index} has fewer launch-record links than accepted blocking findings")

if re.search(r"\|\s*[^|\n]+\s*\|\s*[^|\n]+\s*\|\s*blocking\s*\|\s*accept\s*\|", text):
    if not re.search(r"Blocking re-review round links:\n(?:  - Round \d+: .+\n)+", text):
        fail("accepted blocking findings lack follow-up round links")
    if not re.search(r"Blocking re-review launch records:\n(?:  - Round \d+ Reviewer Launch Records: .+\n)+", text):
        fail("accepted blocking findings lack launch-record links")
PY
  done < <(find "$repo_root/vs_review" -type f -name '*.md' | sort)
fi

log "repository validation passed"
