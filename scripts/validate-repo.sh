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
import re
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
    assert re.fullmatch(r"\d+\.\d+\.\d+", release["version"]), f"registry release version must be semver x.y.z for {skill_id}: {release['version']}"
    assert re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}", release["published_at"]), f"registry published_at must be ISO 8601 local time with timezone for {skill_id}: {release['published_at']}"

    manifest_relpath = skill.get("markets", {}).get("openai-compatible", {}).get("manifest")
    if not manifest_relpath:
        continue
    manifest_path = repo_root / manifest_relpath
    with manifest_path.open("r", encoding="utf-8") as handle:
        manifest = json.load(handle)
    manifest_release = manifest.get("release")
    assert isinstance(manifest_release, dict), f"missing manifest release metadata for {skill_id}"
    assert re.fullmatch(r"\d+\.\d+\.\d+", manifest_release.get("version", "")), f"manifest release version must be semver x.y.z for {skill_id}: {manifest_release.get('version')}"
    assert re.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}", manifest_release.get("published_at", "")), f"manifest published_at must be ISO 8601 local time with timezone for {skill_id}: {manifest_release.get('published_at')}"
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

log "checking skill registry coverage"
"$repo_root/scripts/validate-skill-registry-coverage.py" "$registry_file" "$repo_root"

log "checking skill-specific sanity scripts"
for sanity_script in "$repo_root/scripts/bug-killer-sanity.sh" "$repo_root/scripts/clear-prd-sanity.sh" "$repo_root/scripts/multi-path-debug-sanity.sh" "$repo_root/scripts/plan-report-sanity.sh" "$repo_root/scripts/se-good-plan-sanity.sh"; do
  [[ -x "$sanity_script" ]] || fail "missing executable sanity script: ${sanity_script#$repo_root/}"
  "$sanity_script"
done

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
header_dates = re.findall(r"(?mi)^-\s*(?:Created|Updated):\s*(\d{4}-\d{2}-\d{2})", text)
requires_adversarial_contract = (
    "Report schema: adversarial-v1" in text
    or bool(date_match and date_match.group(1) >= "2026-05-28")
)
requires_timeout_contract = bool(
    date_match and date_match.group(1) >= "2026-05-30"
    or any(date >= "2026-05-30" for date in header_dates)
)

def fail(message: str) -> None:
    raise AssertionError(f"review report {relpath} {message}")

def section_body(source: str, level: str, heading: str) -> str:
    match = re.search(rf"(?m)^{re.escape(level)} {re.escape(heading)}\n(?P<body>.*?)(?=^#{{2,5}} |\Z)", source, re.S)
    return match.group("body").strip() if match else ""

def is_thin(body: str) -> bool:
    normalized = re.sub(r"[\s`*_|<>-]+", " ", body).strip().lower()
    return len(normalized) < 12 or normalized in {"none", "n a", "todo", "pending", "to be recorded", "will be recorded"}

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

def require_bulleted_or_none(body: str, context: str) -> None:
    if is_none_bucket(body):
        return
    for line in body.splitlines():
        stripped = line.strip()
        if stripped and not line.startswith("- "):
            fail(f"{context} contains non-bulleted actionable text")

if not text.strip():
    fail("is empty")

required = ("### Review Input", "### Reviewer Selection", "### Reviewer Launch Records", "### Reviewer Outputs", "### Main Agent Response", "### Closure Status", "## Final Conclusion")
for section in required:
    if section not in text:
        fail(f"missing section: {section}")

header = text.split("## Round ", 1)[0].lower()
if "status: open" in header:
    fail("is not closed; status is open")
status_match = re.search(r"(?mi)^-\s*Status:\s*([A-Za-z_-]+)", text)
report_status = status_match.group(1).lower() if status_match else "passed"
if report_status not in {"passed", "blocked", "accepted-risk"}:
    fail(f"has unsupported status: {report_status}")

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

    launch_section = round_text.split("### Reviewer Launch Records", 1)[1]
    for launch_end in ("### Reviewer Timeout Records", "### Reviewer Outputs"):
        if launch_end in launch_section:
            launch_section = launch_section.split(launch_end, 1)[0]
            break
    if "Session / Job ID" not in launch_section or "Trace Source" not in launch_section or "Context Forked" not in launch_section:
        fail(f"round {index} launch records missing required columns")

    launch_rows = [line for line in launch_section.splitlines() if line.startswith("|") and "|---" not in line and "Reviewer |" not in line]
    if not launch_rows:
        fail(f"round {index} has no reviewer launch rows")
    launched_reviewers = []
    launched_session_ids = set()
    launch_roles_by_session = {}
    for row in launch_rows:
        cells = [cell.strip() for cell in row.strip("|").split("|")]
        if len(cells) < 8:
            fail(f"round {index} has incomplete launch row")
        launched_reviewers.append(cells[0])
        launched_session_ids.add(cells[2])
        launch_roles_by_session.setdefault(cells[2], set()).add(cells[0])
        if not cells[2] or cells[2].lower() in {"pending", "to be recorded after spawn"}:
            fail(f"round {index} launch row missing session id")
        if is_thin(cells[3]):
            fail(f"round {index} launch row missing trace source")
        context_forked = cells[4].lower().replace(" ", "")
        if "fork_context=false" not in context_forked and context_forked not in {"no", "false"}:
            fail(f"round {index} launch row does not prove context isolation")

    timeout_no_output, timeout_output_required, timeout_roles = set(), set(), set()
    timeout_roles_with_no_output, timeout_seen_attempts = set(), set()
    timeout_failed_attempts, timeout_attempts_by_role = {}, {}
    timeout_sessions_by_role_attempt = {}
    timeout_had_duplicate = False
    timeout_output_statuses = {"completed", "completed_after_extension", "late_result"}
    timeout_no_output_statuses = {"timed_out", "lost", "superseded", "degraded", "blocked_due_to_review_unavailable"}
    timeout_allowed_statuses = timeout_output_statuses | timeout_no_output_statuses
    timeout_allowed_actions = {"completed", "extended", "replacement_spawned", "user_decision_required"}
    timeout_action_by_status = {"completed": {"completed"}, "completed_after_extension": {"extended"}, "late_result": {"completed"}, "timed_out": {"extended", "replacement_spawned", "user_decision_required"}, "lost": {"replacement_spawned", "user_decision_required"}, "superseded": {"completed", "replacement_spawned"}, "degraded": {"user_decision_required"}, "blocked_due_to_review_unavailable": {"user_decision_required"}}
    if requires_timeout_contract and "### Reviewer Timeout Records" not in round_text:
        fail(f"round {index} missing reviewer timeout records")
    if requires_timeout_contract:
        policy = section_body(round_text, "###", "Reviewer Timeout Policy")
        if is_thin(policy):
            fail(f"round {index} missing reviewer timeout policy")
    if "### Reviewer Timeout Records" in round_text:
        timeout_section = round_text.split("### Reviewer Timeout Records", 1)[1].split("### Reviewer Outputs", 1)[0]
        timeout_rows = [line for line in timeout_section.splitlines() if line.startswith("|") and "|---" not in line and "Reviewer Output Key" not in line]
        if requires_timeout_contract and not timeout_rows:
            fail(f"round {index} has empty reviewer timeout records")
        for row in timeout_rows:
            cells = [cell.strip() for cell in row.strip("|").split("|")]
            if len(cells) < 8:
                continue
            reviewer_key = cells[0]
            reviewer_role = cells[1]
            attempt = cells[2]
            session_id = cells[3]
            waited = cells[4]
            status = cells[5].lower().replace(" ", "_")
            reason = cells[6]
            action = cells[7]
            action_key = action.lower().replace(" ", "_").replace("-", "_")
            if not reviewer_key or reviewer_key.lower() in {"pending", "n/a", "none"}:
                fail(f"round {index} timeout record missing reviewer output key")
            if not reviewer_role or reviewer_role.lower() in {"pending", "n/a", "none"}:
                fail(f"round {index} timeout record {reviewer_key} missing reviewer role")
            if attempt not in {"1", "2"}:
                fail(f"round {index} timeout record {reviewer_key} has invalid attempt")
            if not session_id or session_id.lower() in {"pending", "n/a", "none"}:
                fail(f"round {index} timeout record {reviewer_key} missing session id")
            if requires_timeout_contract and session_id not in launched_session_ids:
                fail(f"round {index} timeout record {reviewer_key} session id is not in launch records")
            if requires_timeout_contract and reviewer_role not in launch_roles_by_session.get(session_id, set()):
                fail(f"round {index} timeout record {reviewer_key} session id does not match reviewer role")
            if not waited or waited.lower() in {"pending", "n/a", "none"}:
                fail(f"round {index} timeout record {reviewer_key} missing waited duration")
            if status not in timeout_allowed_statuses:
                fail(f"round {index} timeout record {reviewer_key} has invalid status")
            if not reason or reason.lower() in {"pending", "n/a", "none"}:
                fail(f"round {index} timeout record {reviewer_key} missing reason")
            if not action or action.lower() in {"pending", "n/a", "none"}:
                fail(f"round {index} timeout record {reviewer_key} missing action")
            if action_key not in timeout_allowed_actions:
                fail(f"round {index} timeout record {reviewer_key} has invalid action")
            if action_key not in timeout_action_by_status[status]:
                fail(f"round {index} timeout record {reviewer_key} action does not match status")
            timeout_roles.add(reviewer_role)
            timeout_attempts_by_role.setdefault(reviewer_role, set()).add(attempt)
            timeout_sessions_by_role_attempt[(reviewer_role, attempt)] = session_id
            attempt_identity = (reviewer_role, attempt)
            if attempt_identity in timeout_seen_attempts:
                timeout_had_duplicate = True
            timeout_seen_attempts.add(attempt_identity)
            if status in timeout_output_statuses:
                timeout_output_required.add(reviewer_key)
            elif status in timeout_no_output_statuses:
                timeout_no_output.add(reviewer_key)
                timeout_roles_with_no_output.add(reviewer_role)
                timeout_failed_attempts.setdefault(reviewer_role, set()).add(attempt)
        if timeout_had_duplicate:
            fail(f"round {index} has duplicate timeout attempt records")
        for reviewer_role, attempts in timeout_attempts_by_role.items():
            if "2" in attempts and "1" not in attempts:
                fail(f"round {index} timeout record for {reviewer_role} has attempt 2 without attempt 1")
            if {"1", "2"}.issubset(attempts) and timeout_sessions_by_role_attempt[(reviewer_role, "1")] == timeout_sessions_by_role_attempt[(reviewer_role, "2")]:
                fail(f"round {index} replacement attempt for {reviewer_role} reuses primary session id")
        if requires_timeout_contract and not set(launched_reviewers).issubset(timeout_roles):
            fail(f"round {index} timeout records do not cover every launched reviewer")

    reviewer_outputs = round_text.split("### Reviewer Outputs", 1)[1].split("### Main Agent Response", 1)[0]
    reviewer_block_matches = list(re.finditer(r"(?m)^#### ([^\n]+)", reviewer_outputs))
    missing_output_allowed = bool(
        report_status in {"blocked", "accepted-risk"}
        and timeout_no_output
        and not timeout_output_required
        and set(launched_reviewers).issubset(timeout_roles_with_no_output)
    )
    if not reviewer_block_matches:
        if not missing_output_allowed and (
            not launched_reviewers
            or any(reviewer not in timeout_no_output and reviewer not in timeout_roles for reviewer in launched_reviewers)
        ):
            fail(f"round {index} has no reviewer output blocks")
    reviewer_names = [match.group(1).strip() for match in reviewer_block_matches]
    for reviewer_key in timeout_no_output:
        if reviewer_key in reviewer_names:
            fail(f"round {index} no-output timeout record {reviewer_key} must not also have reviewer output")
    if timeout_output_required:
        for reviewer_key in timeout_output_required:
            if reviewer_key not in reviewer_names:
                fail(f"round {index} missing reviewer output for {reviewer_key}")
    for reviewer in launched_reviewers:
        if reviewer in timeout_roles:
            continue
        if reviewer not in reviewer_names:
            fail(f"round {index} missing reviewer output for {reviewer}")
    reviewer_findings = []
    for position, match in enumerate(reviewer_block_matches):
        block_start = match.end()
        block_end = reviewer_block_matches[position + 1].start() if position + 1 < len(reviewer_block_matches) else len(reviewer_outputs)
        block = reviewer_outputs[block_start:block_end]
        required_buckets = ("Summary", "Blocking Findings", "Non-blocking Risks", "Required Fixes", "Missing Tests", "Missing Logs / Observability", "Evidence")
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
                items = finding_items(bucket_match.group("body"))
                if requires_timeout_contract:
                    severity = "blocking" if bucket == "Blocking Findings" else "minor"
                    for item in items:
                        first_line = item.splitlines()[0].lstrip("- ").strip()
                        reviewer_findings.append({
                            "reviewer": reviewer_name,
                            "severity": severity,
                            "finding": first_line,
                        })
                for item in items:
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
            if requires_timeout_contract:
                for bucket in ("Required Fixes", "Missing Tests", "Missing Logs / Observability"):
                    bucket_body = section_body(block, "#####", bucket)
                    require_bulleted_or_none(bucket_body, f"round {index} reviewer {reviewer_name} {bucket}")
                    for item in finding_items(bucket_body):
                        first_line = item.splitlines()[0].lstrip("- ").strip()
                        reviewer_findings.append({"reviewer": reviewer_name, "severity": "minor", "finding": first_line})

    response = round_text.split("### Main Agent Response", 1)[1].split("### Closure Status", 1)[0]
    response_lines = [line for line in response.splitlines() if line.startswith("|") and "|---" not in line and "Reviewer | Finding" not in line]
    response_rows = []
    for line in response_lines:
        cells = [cell.strip() for cell in line.strip("|").split("|")]
        if len(cells) >= 7:
            response_rows.append(cells)
    parsed_rows = []
    for row in response_rows:
        if len(row) >= 8 and row[3] in {"blocking", "major", "minor"} and row[4] in {"accept", "reject", "defer"}:
            parsed_rows.append({"reviewer": row[0], "finding": row[1], "severity": row[3], "decision": row[4], "followup": row[7], "counterexample": row[2]})
        elif row[2] in {"blocking", "major", "minor"} and row[3] in {"accept", "reject", "defer"}:
            parsed_rows.append({"reviewer": row[0], "finding": row[1], "severity": row[2], "decision": row[3], "followup": row[6], "counterexample": ""})
    user_decision = section_body(round_text, "###", "User Decision After Failed Review")
    needs_user_decision = any({"1", "2"}.issubset(attempts) for attempts in timeout_failed_attempts.values())
    if needs_user_decision:
        if is_thin(user_decision) or "Decision:" not in user_decision or "User-visible reason:" not in user_decision:
            fail(f"round {index} missing user decision after failed review")
        decision_match = re.search(r"(?mi)^-\s*Decision:\s*([A-Za-z -]+)\s*$", user_decision)
        if not decision_match:
            fail(f"round {index} missing explicit failed-review decision")
        decision = decision_match.group(1).strip().lower().replace(" ", "-")
        if decision not in {"retry", "narrow-scope", "change-reviewer-type", "accept-risk", "blocked"}:
            fail(f"round {index} has invalid failed-review decision")
        if decision == "accept-risk" and "user" not in user_decision.lower():
            fail(f"round {index} accepted risk without user reference")
    if not parsed_rows and not missing_output_allowed:
        fail(f"round {index} has no populated main-agent response row")
    if requires_timeout_contract and reviewer_findings:
        response_keys = {(row["reviewer"].strip(), row["finding"].strip()) for row in parsed_rows}
        for finding in reviewer_findings:
            finding_key = (finding["reviewer"], finding["finding"])
            if finding_key not in response_keys:
                fail(f"round {index} reviewer finding lacks main-agent response: {finding['reviewer']} / {finding['finding']}")
    accepted_blocking_rows = [row for row in parsed_rows if row["severity"] == "blocking" and row["decision"] == "accept"]
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
        "findings found: pending",
        "accepted blocking findings fixed: pending",
        "rejected findings backed by evidence: pending",
        "deferred findings documented: pending",
    ):
        if forbidden in lower_closure:
            fail(f"round {index} closure is not closed; found '{forbidden}'")
    allowed_yes = "Allowed to proceed: yes" in closure
    allowed_no = "Allowed to proceed: no" in closure
    if report_status == "passed" and not allowed_yes:
        fail(f"round {index} is not allowed to proceed")
    if report_status == "blocked" and not allowed_no:
        fail(f"round {index} blocked report does not mark the round blocked")
    blocked_reason = re.search(r"(?mi)^-\s*Blocked reason:\s*(.+)$", closure)
    if accepted_blocking_rows:
        if report_status == "passed":
            if "Blocking re-review completed: yes" not in closure:
                fail(f"round {index} missing completed blocking re-review")
            if "Blocking re-review passed: yes" not in closure:
                fail(f"round {index} missing passed blocking re-review")
        elif report_status == "blocked":
            if not blocked_reason or is_thin(blocked_reason.group(1)):
                fail(f"round {index} blocked accepted finding lacks blocked reason")
        if not re.search(r"Blocking re-review round links:\n(?:  - Round \d+: .+\n)+", closure):
            if report_status == "passed":
                fail(f"round {index} accepted blocking findings lack concrete follow-up round links")
        if not re.search(r"Blocking re-review launch records:\n(?:  - Round \d+ Reviewer Launch Records: .+\n)+", closure):
            if report_status == "passed":
                fail(f"round {index} accepted blocking findings lack concrete launch-record links")
        concrete_round_links = re.findall(r"(?m)^  - Round \d+: .+", closure)
        concrete_launch_links = re.findall(r"(?m)^  - Round \d+ Reviewer Launch Records: .+", closure)
        if report_status == "passed":
            if len(concrete_round_links) < len(accepted_blocking_rows):
                fail(f"round {index} has fewer follow-up round links than accepted blocking findings")
            if len(concrete_launch_links) < len(accepted_blocking_rows):
                fail(f"round {index} has fewer launch-record links than accepted blocking findings")
        referenced_rounds = [int(match.group(1)) for link in concrete_round_links for match in [re.search(r"Round (\d+)", link)] if match]
        referenced_launch_rounds = [int(match.group(1)) for link in concrete_launch_links for match in [re.search(r"Round (\d+)", link)] if match]
        for referenced in referenced_rounds + referenced_launch_rounds:
            if referenced not in round_numbers:
                fail(f"round {index} references missing follow-up round {referenced}")
            if referenced <= index:
                fail(f"round {index} follow-up round {referenced} is not after the finding round")
    else:
        if not re.search(r"Blocking re-review completed: (yes|no|n/a)", closure, re.I):
            fail(f"round {index} missing no-blocking re-review completion status")
        if not re.search(r"Blocking re-review passed: (yes|no|n/a)", closure, re.I):
            fail(f"round {index} missing no-blocking re-review pass status")
PY
  done < <(find "$repo_root/vs_review" -type f -name '*.md' | sort)
fi

log "repository validation passed"
