# Subagent VS Review: vs-review effectiveness benchmark

- Created: 2026-05-29T00:00:00+08:00
- Updated: 2026-05-29T00:00:00+08:00
- Report schema: adversarial-v1
- Task: Add a lightweight isolated effectiveness benchmark for `subagent-vs-review`.
- Report path: `vs_review/2026-05-29-vs-review-effectiveness-benchmark-review.md`
- Review mode: fresh internal subagents
- Source session policy: no inherited main-agent context
- Status: passed

## Round 1: Benchmark asset review

### Review Input

#### Objective

Verify the new lightweight effectiveness benchmark for `subagent-vs-review`.

#### Review Target

Benchmark fixtures, oracle, packet template, sanity script, and `test-repo.sh` integration.

#### Target Locations

- `scripts/vs-review-effectiveness-sanity.sh`
- `scripts/test-repo.sh`
- `tests/vs-review-effectiveness/README.md`
- `tests/vs-review-effectiveness/fixtures/code/subscription.ts`
- `tests/vs-review-effectiveness/fixtures/code/subscription.test.ts`
- `tests/vs-review-effectiveness/fixtures/design/remote-terminal-reconnect.md`
- `tests/vs-review-effectiveness/fixtures/skill/quick-review-skill.md`
- `tests/vs-review-effectiveness/oracles/seeded-defects.md`
- `tests/vs-review-effectiveness/templates/review-packet.md`

#### Change Introduction

A small tracked benchmark was added with code, design, and skill/workflow fixtures, a seeded-defect oracle, a reviewer packet template, and an asset-sanity script. `scripts/test-repo.sh subagent-vs-review` runs the benchmark asset sanity check.

#### Risk Focus

- Fixture/oracle leakage.
- False confidence from shell checks that do not run internal subagents.
- Unsafe runtime instructions.
- Overclaiming automation.
- Missing isolation guardrails.

#### Assumptions To Attack

- Shell sanity is enough for baseline asset integrity.
- Fixtures do not reveal oracle answers.
- Packet template prevents agent behavior spillover.
- Benchmark can be useful even though subagent review is manual/runtime-driven.

#### Adversarial Lenses

- testing
- isolation
- observability
- maintenance
- agent workflow
- failure

#### Verification Status

- `./scripts/vs-review-effectiveness-sanity.sh` passed.
- `./scripts/test-repo.sh subagent-vs-review` passed.

#### Reviewer Instructions

- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Focus on whether the benchmark can detect regressions without leaking oracle answers or causing agent behavior to spill into the real repo.

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| benchmark-assets-adversary | The change adds a testing harness and benchmark workflow. | Asset integrity, oracle leakage, isolation, and overclaimed automation. |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| benchmark-assets-adversary | `multi_agent_v1.spawn_agent` with `critic` role | `019e7460-d57b-7e63-a1a8-59b12fcb9ab6` | tool call response and subagent notification in current Codex thread | no (`fork_context=false`) | Round 1 Review Input | main-agent conversation history, hidden reasoning, oracle answers, drafts, and conclusions | yes |

### Reviewer Outputs

#### benchmark-assets-adversary

##### Summary

The benchmark is directionally useful as a lightweight manual harness, but not yet trustworthy as a regression detector. The reviewer found two blocking gaps: the code-case oracle was broader than reviewer-visible scope, and isolation pass criteria were asserted without an auditable canary/launch-record layer.

##### Blocking Findings

- The code-case scoring contract is inconsistent with the reviewer-visible inputs.
  - Broken assumption: A reviewer can recover all seeded code findings from one target file path.
  - Failure scenario: A reviewer inspects only `subscription.ts` and cannot legitimately report the oracle's happy-path-only test gap because `subscription.test.ts` was not exposed.
  - Trigger condition: Using a single-file `Review target` flow while the oracle expects a test-file finding.
  - Impact: Recall becomes operator-dependent, so misses can reflect packet ambiguity rather than reviewer regression.
  - Proof needed: Change the benchmark contract to explicit target locations including both code files, or remove the test-gap oracle.
- Isolation is asserted but not measurable from the benchmark assets.
  - Broken assumption: `fork_context=false` and canary isolation can be verified by prose alone.
  - Failure scenario: Runtime starts inheriting main-agent context or an operator leaks hints, yet the benchmark appears to pass because no canary scan or launch metadata is required.
  - Trigger condition: Running the manual flow with the current packet and no runtime report evidence.
  - Impact: False confidence on the benchmark's core isolation purpose.
  - Proof needed: Add canary setup, reviewer-output scan steps, session/job IDs, `fork_context=false` capture, and a temp `vs_review/` artifact.

##### Non-blocking Risks

- Temp-root safety is procedural only.
  - Broken assumption: Operators will always copy into ignored `tmp/` before launching reviewers.
  - Failure scenario: `<tmp-root>` points at the live repo or another tracked path.
  - Trigger condition: Manual packet filling without a bootstrap guard.
  - Impact: Repo pollution and reduced trust in isolated review runs.
  - Proof needed: A bootstrap script that creates `tmp/vs-review-effectiveness/current` or a run directory and rejects non-`tmp/` roots.
- `scripts/test-repo.sh` can be over-read as effectiveness coverage.
  - Broken assumption: Downstream readers will distinguish asset sanity from runtime effectiveness.
  - Failure scenario: A green smoke test is cited as benchmark success even though no subagent was run.
  - Trigger condition: Relying on the generic `test-repo.sh` pass line.
  - Impact: Overclaiming automation and missing runtime regressions.
  - Proof needed: Rename the check/result to `asset sanity` or require a recorded runtime report before claiming effectiveness.
- Oracle/leakage drift is weakly guarded.
  - Broken assumption: A lower-bound seed count plus a short denylist preserves benchmark difficulty.
  - Failure scenario: Oracle count or semantic hints drift while sanity still passes.
  - Trigger condition: Future edits to benchmark assets.
  - Impact: Poorer repeatability and silent answer leakage.
  - Proof needed: Pin exact seed inventory and strengthen fixture/oracle separation checks.

##### Required Fixes

- Change the code benchmark contract to explicit target locations and include both subscription files.
- Add canary, launch-record, and runtime-report isolation verification.
- Add a bootstrap/guard script for ignored runtime roots.
- Label `test-repo.sh` coverage as asset sanity.
- Pin oracle inventory more tightly.

##### Missing Tests

- Negative test for code case with only `subscription.ts` exposed.
- Negative runtime test for inherited canary.
- Guard test rejecting temp roots outside `tmp/`.
- Regression test for exact seeded-defect count by case.

##### Missing Logs / Observability

- No per-run artifact with temp root, copied fixtures, reviewer role, session id, `fork_context`, canary hash, scan result, and output path.
- No per-case scoring log with oracle hits and misses.
- No spill check recording whether writes occurred outside the ignored temp workspace.

##### Evidence

- `tests/vs-review-effectiveness/README.md`
- `tests/vs-review-effectiveness/templates/review-packet.md`
- `tests/vs-review-effectiveness/oracles/seeded-defects.md`
- `tests/vs-review-effectiveness/fixtures/code/subscription.test.ts`
- `scripts/vs-review-effectiveness-sanity.sh`
- `scripts/test-repo.sh`

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| benchmark-assets-adversary | Code-case scoring contract inconsistent with visible inputs. | The oracle expected a test gap while the packet could expose only one code file. | blocking | accept | The code fixture includes both implementation and test, but the packet template used singular `Review target`. | Changed benchmark docs and packet template to use `Target locations`; runtime report includes both `subscription.ts` and `subscription.test.ts`. | Round 2 closure review. |
| benchmark-assets-adversary | Isolation asserted but not measurable. | `fork_context=false` and canary isolation were prose claims without runtime artifacts. | blocking | accept | No bootstrap, canary scan, or launch-record template existed. | Added bootstrap and scan scripts, runtime report template, canary hash, launch rows, and scan instructions. | Round 2 closure review. |
| benchmark-assets-adversary | Temp-root safety procedural only. | Operators could point the benchmark at tracked paths. | major | accept | No bootstrap guard existed. | Added a runtime bootstrap script under ignored `tmp/vs-review-effectiveness/runs/`. | Round 2 closure review. |
| benchmark-assets-adversary | `test-repo.sh` can overclaim effectiveness. | Asset sanity can be mistaken for runtime subagent effectiveness. | major | accept | `test-repo.sh` had a generic pass line. | Changed wording to `benchmark asset sanity`; README states the shell check is not runtime effectiveness. | Final validation. |
| benchmark-assets-adversary | Oracle inventory weakly guarded. | Lower-bound seed count allows drift. | major | accept | Sanity checked only at least 10 seeds. | Pinned case counts to 4/4/5 and total 13. | Round 2 closure review. |

### Closure Status

- Blocking findings found: yes
- Accepted blocking findings fixed: yes
- Blocking re-review completed: yes
- Blocking re-review passed: yes
- Blocking re-review round links:
  - Round 2: rechecked visible inputs and isolation auditability.
  - Round 2: rechecked runtime root and oracle inventory guardrails.
- Blocking re-review launch records:
  - Round 2 Reviewer Launch Records: benchmark-closure-adversary fresh internal subagent.
  - Round 2 Reviewer Launch Records: benchmark-closure-adversary fresh internal subagent.
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Allowed to proceed: yes

## Round 2: Benchmark closure review

### Review Input

#### Objective

Verify the fixes for Round 1 benchmark blockers.

#### Review Target

Benchmark scripts, docs, fixtures, oracle, and packet template after adding bootstrap, canary scan, target locations, and asset-sanity wording.

#### Target Locations

- `scripts/vs-review-effectiveness-sanity.sh`
- `scripts/vs-review-effectiveness-bootstrap.sh`
- `scripts/vs-review-effectiveness-scan.sh`
- `scripts/test-repo.sh`
- `tests/vs-review-effectiveness/README.md`
- `tests/vs-review-effectiveness/templates/review-packet.md`
- `tests/vs-review-effectiveness/fixtures/code/subscription.ts`
- `tests/vs-review-effectiveness/fixtures/code/subscription.test.ts`
- `tests/vs-review-effectiveness/oracles/seeded-defects.md`

#### Change Introduction

The benchmark was revised to use explicit target locations, generate an ignored runtime copy, add canary scan tooling, add launch metadata, label the repo test as asset sanity, and pin oracle inventory counts.

#### Risk Focus

- Remaining paper-isolation.
- Overclaimed effectiveness.
- Unreachable oracle expectations.
- Unsafe temp writes.
- Weak sanity script.

#### Assumptions To Attack

- Bootstrap and scan make isolation auditable.
- Packet template prevents oracle/canary leakage.
- Asset sanity cannot be confused with runtime effectiveness.
- Runtime root guard keeps writes inside ignored `tmp/`.

#### Adversarial Lenses

- testing
- isolation
- agent workflow
- observability
- maintenance

#### Verification Status

- `./scripts/vs-review-effectiveness-sanity.sh` passed.
- `./scripts/test-repo.sh subagent-vs-review` passed.
- Bootstrap plus scan passed on an ignored temp run.

#### Reviewer Instructions

- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Focus on whether prior blocking findings are actually closed.

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| benchmark-closure-adversary | Round 1 accepted blocking findings require fresh closure review. | Oracle leakage, temp-root safety, and isolation auditability. |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| benchmark-closure-adversary | `multi_agent_v1.spawn_agent` with `critic` role | `019e7466-15c8-7f83-8902-2e343e3f11bd` | tool call response and subagent notification in current Codex thread | no (`fork_context=false`) | Round 2 Review Input | main-agent conversation history, hidden reasoning, drafts, failed attempts, conclusions, and oracle answers | yes |

### Reviewer Outputs

#### benchmark-closure-adversary

##### Summary

Closure was not ready. The code case now exposed both code files, `test-repo.sh` only claimed asset sanity, and oracle inventory was count-pinned. Remaining blockers were benchmark-integrity issues: bootstrap still copied the oracle into the reviewer-visible runtime root, and the temp-root guard was vulnerable to `..` traversal.

##### Blocking Findings

- Oracle isolation is still paper-only.
  - Broken assumption: Bootstrap, packet, and scan make reviewer isolation auditable.
  - Failure scenario: A reviewer opens `<tmp-root>/oracles/seeded-defects.md`, reproduces seeded findings, and appears effective without genuine discovery.
  - Trigger condition: Any reviewer inspects non-target files inside the copied temp project.
  - Impact: The benchmark can overclaim effectiveness because oracle contamination is undetectable.
  - Proof needed: Exclude `oracles/` from the copied runtime tree, or add auditable access evidence proving reviewers never touched oracle paths.
- Temp-root safety is not guarded against path traversal.
  - Broken assumption: Raw string prefix checks keep runtime writes and scans under `tmp/vs-review-effectiveness/runs/`.
  - Failure scenario: A crafted `run_id` like `../../../../outside` resolves outside the intended temp tree.
  - Trigger condition: Caller supplies `run_id` or `run_dir` containing `..` traversal.
  - Impact: Unsafe writes or reads outside the benchmark temp root.
  - Proof needed: Canonicalize resolved paths before comparison, or reject unsafe run ids and run dirs.

##### Non-blocking Risks

- Canary auditing is narrow.
  - Broken assumption: The scan is enough to make isolation auditable.
  - Failure scenario: A reviewer reads excluded context but does not emit the literal canary string into `vs_review/`.
  - Trigger condition: Contamination happens without exact-string reuse inside the report directory.
  - Impact: Clean scan despite isolation violation.
  - Proof needed: Scan the whole runtime artifact set and record reviewer trace evidence.
- Sanity is still phrase-based.
  - Broken assumption: A short fixed regex catches meaningful oracle leakage.
  - Failure scenario: A fixture paraphrases seeded answers without using the banned phrases.
  - Trigger condition: Future fixture edits leak oracle semantics differently.
  - Impact: Benchmark hints drift back into fixtures.
  - Proof needed: Add stronger separation checks or manual review gates.

##### Required Fixes

- Copy only reviewer-facing fixtures and templates into runtime; do not copy oracle files.
- Harden bootstrap and scan path validation against traversal.
- Expand the audit so oracle isolation is observable.

##### Missing Tests

- Negative tests for traversal inputs in bootstrap and scan.
- Runtime-copy test asserting `oracles/` is excluded.
- Audit failure test for forbidden oracle-access evidence if that contract is adopted.

##### Missing Logs / Observability

- No artifact proves actual file access.
- No script validates that temp runtime report is fully populated for a completed run.
- No oracle-contamination scan beyond canary grep.

##### Evidence

- `scripts/vs-review-effectiveness-bootstrap.sh`
- `scripts/vs-review-effectiveness-scan.sh`
- `tests/vs-review-effectiveness/templates/review-packet.md`
- `tests/vs-review-effectiveness/oracles/seeded-defects.md`

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| benchmark-closure-adversary | Oracle isolation paper-only. | Runtime copy included `oracles/`, so reviewer could read answers. | blocking | accept | Bootstrap copied the full benchmark tree. | Changed bootstrap to copy only `README.md`, `fixtures/`, and `templates/`; scan now fails if runtime `oracles/` exists. | Round 3 closure review. |
| benchmark-closure-adversary | Temp-root guard vulnerable to traversal. | Raw prefix checks can be bypassed with `..` segments. | blocking | accept | Bootstrap and scan used raw string prefix checks. | Added run-id allowlist, rejected `..`, canonicalized run paths under runs root, and added negative traversal checks in sanity. | Round 3 closure review. |
| benchmark-closure-adversary | Canary auditing narrow. | Canary scan only inspected `vs_review/` content. | major | accept | Scan did not cover whole runtime tree. | Expanded scan to all runtime artifacts and later to artifact paths. | Round 3 closure review. |
| benchmark-closure-adversary | Sanity phrase-based. | Oracle leakage can be paraphrased. | major | accept | Sanity used a small denylist. | Added exact oracle SHA-256 pinning in addition to counts and leakage denylist. | Final validation. |

### Closure Status

- Blocking findings found: yes
- Accepted blocking findings fixed: yes
- Blocking re-review completed: yes
- Blocking re-review passed: yes
- Blocking re-review round links:
  - Round 3: rechecked oracle exclusion from runtime and path traversal guards.
  - Round 3: rechecked canary scan scope and asset-sanity wording.
- Blocking re-review launch records:
  - Round 3 Reviewer Launch Records: benchmark-final-closure-adversary fresh internal subagent.
  - Round 3 Reviewer Launch Records: benchmark-final-closure-adversary fresh internal subagent.
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Allowed to proceed: yes

## Round 3: Final benchmark closure review

### Review Input

#### Objective

Final closure-review the benchmark fixes after Round 2 found oracle copying and path traversal blockers.

#### Review Target

Benchmark scripts, docs, packet template, fixtures, and oracle after runtime-copy and path-hardening fixes.

#### Target Locations

- `scripts/vs-review-effectiveness-sanity.sh`
- `scripts/vs-review-effectiveness-bootstrap.sh`
- `scripts/vs-review-effectiveness-scan.sh`
- `scripts/test-repo.sh`
- `tests/vs-review-effectiveness/README.md`
- `tests/vs-review-effectiveness/templates/review-packet.md`
- `tests/vs-review-effectiveness/fixtures/code/subscription.ts`
- `tests/vs-review-effectiveness/fixtures/code/subscription.test.ts`
- `tests/vs-review-effectiveness/oracles/seeded-defects.md`

#### Change Introduction

The runtime copy now excludes oracle files, path validation rejects traversal and canonicalizes run paths, canary scan covers runtime artifacts and artifact paths, and oracle content is SHA-256 pinned.

#### Risk Focus

- Remaining oracle leakage.
- Path traversal.
- Paper-isolation.
- Overclaimed effectiveness.
- Weak sanity script.

#### Assumptions To Attack

- Runtime copy is now safe.
- Scan is broad enough for basic canary leakage.
- Run id and run dir validation block traversal.
- Benchmark remains lightweight and repeatable.

#### Adversarial Lenses

- testing
- isolation
- agent workflow
- observability
- maintenance

#### Verification Status

- `./scripts/vs-review-effectiveness-sanity.sh` passed.
- `./scripts/test-repo.sh subagent-vs-review` passed.
- Bootstrap plus scan passed.
- Manual negative traversal checks passed.

#### Reviewer Instructions

- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Focus on whether Round 2 blockers are closed.

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| benchmark-final-closure-adversary | Round 2 accepted blocking findings require fresh closure review. | Oracle exclusion, traversal safety, scan coverage, and benchmark repeatability. |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| benchmark-final-closure-adversary | `multi_agent_v1.spawn_agent` with `critic` role | `019e746a-88ff-7e82-8558-74ce1984d3ed` | tool call response and subagent notification in current Codex thread | no (`fork_context=false`) | Round 3 Review Input | main-agent conversation history, hidden reasoning, drafts, failed attempts, conclusions, and oracle answers | yes |

### Reviewer Outputs

#### benchmark-final-closure-adversary

##### Summary

No closure blocker was found. Runtime bootstrap omits `oracles/`, traversal probes are rejected in bootstrap and scan, canary scan covers runtime file contents, the bootstrapped code case lists both code files, `test-repo.sh` only claims benchmark asset sanity, and oracle inventory is pinned at 4/4/5. Remaining findings are non-blocking hardening gaps.

##### Blocking Findings

- none

##### Non-blocking Risks

- Paper-isolation wording is still looser than the intended named-target boundary.
  - Broken assumption: The packet restricts the reviewer to only listed fixture files.
  - Failure scenario: A reviewer inspects `<tmp-root>/README.md` or runtime report metadata.
  - Trigger condition: Reviewer explores temp root instead of staying on named targets.
  - Impact: Benchmark harness metadata can bias behavior even without oracle copying.
  - Proof needed: Tighten packet wording to forbid reading any temp-project file outside named target locations.
- Canary scanning does not cover artifact names or paths.
  - Broken assumption: `grep -RIn "$canary" "$run_dir"` covers all runtime artifacts.
  - Failure scenario: Canary appears in a filename or directory name and scan passes.
  - Trigger condition: Tool or human writes canary into artifact names.
  - Impact: False-negative leakage result.
  - Proof needed: Extend scan to include path/name checks.
- Oracle inventory is pinned by count, not exact content.
  - Broken assumption: Count pinning fully preserves the oracle.
  - Failure scenario: Oracle text or severity semantics drift while counts remain 4/4/5.
  - Trigger condition: Future edits change oracle wording without changing item counts.
  - Impact: Benchmark ground truth drifts unnoticed.
  - Proof needed: Add exact-content or digest check over `oracles/seeded-defects.md`.

##### Required Fixes

- None for closure of prior blocking findings.
- Optionally tighten packet scope, canary path scanning, and oracle content pinning.

##### Missing Tests

- Regression test for canary in artifact path.
- Isolation wording regression for named-target-only scope.
- Oracle-integrity regression that fails on unchanged-count text drift.

##### Missing Logs / Observability

- Runtime report does not record reviewer-visible file hashes.
- Negative traversal probes are verified by terminal output, not persisted into the runtime report.

##### Evidence

- `scripts/vs-review-effectiveness-sanity.sh`
- `scripts/vs-review-effectiveness-bootstrap.sh`
- `scripts/vs-review-effectiveness-scan.sh`
- `scripts/test-repo.sh`
- `tests/vs-review-effectiveness/README.md`
- `tests/vs-review-effectiveness/templates/review-packet.md`
- `tests/vs-review-effectiveness/oracles/seeded-defects.md`

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| benchmark-final-closure-adversary | Paper-isolation wording looser than named-target boundary. | Reviewer could inspect non-target temp files. | minor | accept | Packet wording only excluded real repo content outside temp project. | Tightened packet and README wording to forbid reading any file outside named target locations, including other temp files. | Final validation. |
| benchmark-final-closure-adversary | Canary scan misses artifact names or paths. | Canary in filename can bypass content grep. | minor | accept | Scan only used content grep. | Added `find "$run_dir" -print | grep -F "$canary"` path scanning and sanity negative test. | Final validation. |
| benchmark-final-closure-adversary | Oracle inventory pinned by count, not exact content. | Oracle text can drift while counts remain stable. | minor | accept | Sanity counted seeds only. | Added SHA-256 oracle content pinning. | Final validation. |

### Closure Status

- Blocking findings found: no
- Accepted blocking findings fixed: n/a
- Blocking re-review completed: n/a
- Blocking re-review passed: n/a
- Blocking re-review round links:
  - n/a
- Blocking re-review launch records:
  - n/a
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Allowed to proceed: yes

## Final Conclusion

Passed. The benchmark now has tracked fixtures, oracle, packet template, bootstrap, scan, and asset-sanity scripts. Runtime copies exclude oracle files, stay under ignored `tmp/vs-review-effectiveness/runs/`, reject traversal inputs, scan content and artifact paths for canary leakage, pin oracle content, and clearly distinguish asset sanity from runtime effectiveness. Final validation and smoke tests passed before commit.

