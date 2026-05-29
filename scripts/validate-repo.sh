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
date_match = re.match(r"(\d{4}-\d{2}-\d{2})", report.name)
requires_adversarial_contract = (
    "Report schema: adversarial-v1" in text
    or bool(date_match and date_match.group(1) >= "2026-05-28")
)

def fail(message: str) -> None:
    raise AssertionError(f"review report {relpath} {message}")

def section_body(source: str, level: str, heading: str) -> str:
    match = re.search(rf"(?m)^{re.escape(level)} {re.escape(heading)}\n(?P<body>.*?)(?=^#{{2,5}} |\Z)", source, re.S)
    return match.group("body").strip() if match else ""

def is_thin(body: str) -> bool:
    normalized = re.sub(r"[\s`*_|<>-]+", " ", body).strip().lower()
    return len(normalized) < 12 or normalized in {
        "none",
        "n a",
        "todo",
        "pending",
        "to be recorded",
        "will be recorded",
    }

def is_none_bucket(body: str) -> bool:
    lines = [line.strip().lower() for line in body.splitlines() if line.strip()]
    return bool(lines) and all(re.fullmatch(r"-?\s*(none|n/a|not applicable)\.?", line) for line in lines)

def finding_items(body: str) -> list[str]:
    if is_none_bucket(body):
        return []
    chunks = []
    current = []
    for line in body.splitlines():
        if line.startswith("- ") and not re.match(r"^-\s*(none|n/a|not applicable)\b", line.strip(), re.I):
            if current:
                chunks.append("\n".join(current).strip())
            current = [line]
        elif current:
            current.append(line)
    if current:
        chunks.append("\n".join(current).strip())
    return [chunk for chunk in chunks if chunk]

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
final_conclusion = text.split("## Final Conclusion", 1)[1].strip()
if is_thin(final_conclusion) or re.search(r"\b(pending|to be recorded|will be recorded)\b", final_conclusion, re.I):
    fail("final conclusion is not closed")

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
round_numbers = {number for number, _ in rounds}

for index, round_text in rounds:
    for section in required[:-1]:
        if section not in round_text:
            fail(f"round {index} missing section: {section}")
    if requires_adversarial_contract:
        for heading in ("Assumptions To Attack", "Adversarial Lenses"):
            body = section_body(round_text, "####", heading)
            if is_thin(body):
                fail(f"round {index} has thin {heading}")

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
        if is_thin(cells[3]):
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
            if not bucket_match:
                fail(f"round {index} reviewer {match.group(1).strip()} missing {bucket} body")
            bucket_body = bucket_match.group("body").strip()
            if is_thin(bucket_body) and not is_none_bucket(bucket_body):
                fail(f"round {index} reviewer {match.group(1).strip()} has thin {bucket}")
        if requires_adversarial_contract:
            reviewer_name = match.group(1).strip()
            for bucket in ("Blocking Findings", "Non-blocking Risks"):
                bucket_match = re.search(rf"##### {re.escape(bucket)}\n(?P<body>.*?)(?=\n##### |\Z)", block, re.S)
                if not bucket_match:
                    continue
                for item in finding_items(bucket_match.group("body")):
                    for label in ("Broken assumption:", "Failure scenario:", "Trigger condition:", "Impact:", "Proof needed:"):
                        if label not in item:
                            fail(f"round {index} reviewer {reviewer_name} missing {label} in {bucket} item")
                    for label in ("Broken assumption:", "Failure scenario:", "Trigger condition:", "Impact:", "Proof needed:"):
                        label_body = item.split(label, 1)[1].split("\n  - ", 1)[0].strip()
                        if is_thin(label_body):
                            fail(f"round {index} reviewer {reviewer_name} has thin {label} in {bucket} item")
            if not finding_items(section_body(block, "#####", "Blocking Findings")) and not finding_items(section_body(block, "#####", "Non-blocking Risks")):
                for label in ("Broken assumption:", "Failure scenario:", "Trigger condition:", "Impact:", "Proof needed:"):
                    if label in block:
                        fail(f"round {index} reviewer {reviewer_name} has adversarial labels outside a concrete finding")

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
    parsed_rows = []
    for row in response_rows:
        if len(row) >= 8 and row[3] in {"blocking", "major", "minor"} and row[4] in {"accept", "reject", "defer"}:
            parsed_rows.append({"severity": row[3], "decision": row[4], "followup": row[7], "counterexample": row[2]})
        elif row[2] in {"blocking", "major", "minor"} and row[3] in {"accept", "reject", "defer"}:
            parsed_rows.append({"severity": row[2], "decision": row[3], "followup": row[6], "counterexample": ""})
    if not parsed_rows:
        fail(f"round {index} has no populated main-agent response row")
    accepted_blocking_rows = [
        row for row in parsed_rows
        if row["severity"] == "blocking" and row["decision"] == "accept"
    ]
    for row in accepted_blocking_rows:
        if not re.search(r"Round \d+", row["followup"]):
            fail(f"round {index} accepted blocking row lacks follow-up round reference")
        if "#### Assumptions To Attack" in round_text and len(row.get("counterexample", "").strip()) < 12:
            fail(f"round {index} accepted blocking row lacks counterexample context")

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
    if accepted_blocking_rows:
        if "Blocking re-review completed: yes" not in closure:
            fail(f"round {index} missing completed blocking re-review")
        if "Blocking re-review passed: yes" not in closure:
            fail(f"round {index} missing passed blocking re-review")
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
        referenced_rounds = [
            int(match.group(1))
            for link in concrete_round_links
            for match in [re.search(r"Round (\d+)", link)]
            if match
        ]
        referenced_launch_rounds = [
            int(match.group(1))
            for link in concrete_launch_links
            for match in [re.search(r"Round (\d+)", link)]
            if match
        ]
        for referenced in referenced_rounds + referenced_launch_rounds:
            if referenced not in round_numbers:
                fail(f"round {index} references missing follow-up round {referenced}")
            if referenced <= index:
                fail(f"round {index} follow-up round {referenced} is not after the finding round")
    else:
        if not re.search(r"Blocking re-review completed: (yes|n/a)", closure, re.I):
            fail(f"round {index} missing no-blocking re-review completion status")
        if not re.search(r"Blocking re-review passed: (yes|n/a)", closure, re.I):
            fail(f"round {index} missing no-blocking re-review pass status")
PY
  done < <(find "$repo_root/vs_review" -type f -name '*.md' | sort)
fi

log "repository validation passed"
