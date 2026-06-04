# Subagent VS Review: bug-killer skill

- Created: 2026-06-05T04:05:44+08:00
- Updated: 2026-06-05T04:16:08+08:00
- Report schema: adversarial-v1
- Task: Add `bug-killer`, a new heavy debugging skill for medium and large bugs that fuses `/coe` case tracking, multi-path investigation, and a diagnostic evidence gate before repair design.
- Report path: `vs_review/2026-06-05-bug-killer-review.md`
- Review mode: fresh internal subagents
- Source session policy: no inherited main-agent context
- Status: passed

## Round 1: implemented skill package review

### Review Input

#### Objective
Review whether the new `bug-killer` skill package satisfies the requested behavior: create a new skill rather than patching `coe-debug` or `multi-path-debug`; reserve the workflow for medium and large bugs; combine `/coe` evidence tracking, independent multi-path root-cause investigation, and a hard diagnostic evidence gate before repair design.

#### Review Target
Skill package, metadata, registry/discovery entries, validation script, repository smoke-test integration, and design record.

#### Target Locations
- `skills/bug-killer/SKILL.md`
- `skills/bug-killer/agents/openai.yaml`
- `skills/bug-killer/markets/openai-compatible.json`
- `skills/bug-killer/templates/case-template.md`
- `skills/bug-killer/references/interaction-fixtures.md`
- `scripts/bug-killer-sanity.sh`
- `scripts/test-repo.sh`
- `scripts/validate-repo.sh`
- `registry/skills.json`
- `README.md`
- `README.zh-CN.md`
- `docs/plans/2026-06-05-bug-killer-skill.md`

#### Change Introduction
A new installable skill named `bug-killer` was added. It is a heavy debugging workflow for medium and large bugs only. The skill uses `/coe` case files with Problem, Hypothesis, and Evidence nodes; uses independent research paths to generate and challenge candidate root causes; requires diagnostic logs, probes, tests, runtime observations, telemetry, config facts, or user feedback to prove the candidate cause before repair design; and requires fix-validation evidence before marking a problem fixed.

#### Risk Focus
- The activation gate may be too broad, too narrow, or unclear.
- The diagnostic evidence gate may still allow a candidate cause to become a repair design without proof.
- The `/coe`, multi-path, and diagnostic-gate concepts may be listed but not integrated.
- Diagnostic instrumentation may be mixed with repair behavior.
- Metadata, registry, README, fixtures, or validation may drift from actual skill behavior.
- The sanity script may protect keywords rather than meaningful methodology.

#### Assumptions To Attack
- The activation gate prevents overuse on small deterministic bugs.
- The diagnostic evidence gate blocks repair design until root-cause proof exists.
- Two failed repair or user-feedback cycles is a useful threshold for escalating.
- Cross-module, production, customer-visible, data, security, release, flaky, or hard-to-reproduce symptoms justify the heavy flow.
- The skill can be followed by a fresh agent without hidden context.
- The validation is strong enough to prevent backsliding into guess-and-patch behavior.

#### Adversarial Lenses
- requirements
- documentation
- agent workflow
- debugging
- testing
- observability
- maintenance

#### Verification Status
- Pre-review `./scripts/bug-killer-sanity.sh` passed.
- Pre-review `./scripts/test-repo.sh bug-killer` passed.
- Pre-review `./scripts/list-skills.sh` included `bug-killer`.
- Pre-review `git diff --check` passed.
- Pre-review `./scripts/validate-repo.sh` passed.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Return sections: Summary, Blocking Findings, Non-blocking Risks, Required Fixes, Missing Tests, Missing Logs / Observability, Evidence.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| normal | 12 minutes | none used | 2 | cannot pass if review is unavailable |

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| documentation-skill-adversary | The artifact is a distributable skill package future agents must follow from fresh context. | trigger rules, packaging, metadata, fresh-agent usability |
| test-validity-adversary | The task relies on sanity checks to keep the heavy activation gate and diagnostic proof gate from regressing. | validation quality, fixture coverage, smoke-test wiring |
| debugging-methodology-adversary | The core methodology changes root-cause and repair sequencing for future debugging work. | evidence gate, multi-path synthesis, diagnostic instrumentation, repair confirmation |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| documentation-skill-adversary | multi_agent_v1.spawn_agent critic | 019e943d-5992-7540-808c-1adc0aeef598 | spawn_agent response in current thread | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |
| test-validity-adversary | multi_agent_v1.spawn_agent test-engineer | 019e943d-946d-7521-8ca8-8e1bba59e446 | spawn_agent response in current thread | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |
| debugging-methodology-adversary | multi_agent_v1.spawn_agent code-reviewer | 019e943d-c66a-72a3-abbc-8507ca9cbf4b | spawn_agent response in current thread | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| documentation-skill-adversary | documentation-skill-adversary | 1 | 019e943d-5992-7540-808c-1adc0aeef598 | 4m | completed | reviewer returned package and metadata review | completed |
| test-validity-adversary | test-validity-adversary | 1 | 019e943d-946d-7521-8ca8-8e1bba59e446 | 2m | completed | reviewer returned validation review | completed |
| debugging-methodology-adversary | debugging-methodology-adversary | 1 | 019e943d-c66a-72a3-abbc-8507ca9cbf4b | 5m | completed | reviewer returned methodology review | completed |

### Reviewer Outputs

#### documentation-skill-adversary

##### Summary
The core `SKILL.md` integrated `/coe`, multi-path investigation, and the evidence gate, and no legacy debug skill was patched. The package still had metadata and template contradictions.

##### Blocking Findings
- Agent metadata did not preserve the heavy-only activation contract and explicit trigger aliases.
  - Broken assumption: package metadata matches the actual behavior and prevents overuse on small bugs.
  - Failure scenario: a fresh agent routes an ordinary typo task into Bug Killer or misses explicit `/coe` and evidence-gated aliases.
  - Trigger condition: routing from `agents/openai.yaml` before reading full `SKILL.md`.
  - Impact: the skill can over-trigger or under-trigger, breaking the heavy-process boundary.
  - Proof needed: align metadata with the full activation gate and add sanity coverage for heavy-only scope and aliases.
- Case template allowed repair design while the hypothesis was unverified and the evidence gate was pending.
  - Broken assumption: the diagnostic evidence gate blocks repair design until proof exists.
  - Failure scenario: a fresh agent creates a case from the template and selects `start repair design` before confirmation.
  - Trigger condition: template-driven case creation with `Status: unverified` and `Evidence gate: pending`.
  - Impact: the primary artifact contradicts the hard gate.
  - Proof needed: make the template gate-aware and sanity-check that pending hypotheses cannot flow to repair design.

##### Non-blocking Risks
- Multi-path fallback was underspecified when subagents or external agents are unavailable.
  - Broken assumption: `/coe`, multi-path investigation, and the evidence gate are operationally fused.
  - Failure scenario: one local code-reading pass plus one shallow log read is treated as multi-path work.
  - Trigger condition: runtimes without subagent support or cases where external agents are declined.
  - Impact: execution collapses into note-taking rather than independent evidence generation.
  - Proof needed: define a minimum local fallback path matrix and add a degraded-runtime fixture.
- Diagnostic log observability fields were not enforced in the template or sanity script.
  - Broken assumption: the observability contract is reusable by a fresh agent.
  - Failure scenario: ad-hoc diagnostic logs are added without stable event names, correlation IDs, or lifecycle decisions.
  - Trigger condition: any diagnostic-only instrumentation step.
  - Impact: evidence is harder to correlate and reuse across long incidents.
  - Proof needed: add template fields and fixture checks for event names, IDs, and removal or retention decisions.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `skills/bug-killer/agents/openai.yaml` initially had generic activation metadata.
- `skills/bug-killer/templates/case-template.md` initially listed `start repair design` under an unverified hypothesis.
- `git diff --name-only -- skills/coe-debug skills/multi-path-debug` returned empty.

#### test-validity-adversary

##### Summary
Validation was wired but not strong enough: it missed the low-confidence branch, did not assert repo-wide wiring, and was mostly positive substring checking.

##### Blocking Findings
- Low-confidence branch was not actually enforced by sanity.
  - Broken assumption: `./scripts/bug-killer-sanity.sh` catches low-confidence behavior regressions.
  - Failure scenario: the low-confidence block weakens or asks to fix while the repair-ready confirmation string remains.
  - Trigger condition: any edit that weakens the low-confidence block while preserving the earlier confirmation text.
  - Impact: a core acceptance criterion regresses without test failure.
  - Proof needed: assert the low-confidence fenced block unconditionally and forbid repair confirmation inside it.
- Repo-wide validate-repo wiring was not asserted by bug-killer sanity.
  - Broken assumption: `./scripts/validate-repo.sh` always runs the bug-killer sanity check.
  - Failure scenario: a future repo-wide sanity loop refactor removes `bug-killer-sanity.sh` but the bug-killer sanity still passes.
  - Trigger condition: validation script refactor.
  - Impact: repo-wide validation silently stops protecting the skill.
  - Proof needed: explicitly assert the `validate-repo.sh` hook or derive sanity execution from registry metadata.
- Sanity was mostly presence-only and did not reject contradictory repair-before-proof guidance.
  - Broken assumption: sanity catches critical methodology regressions.
  - Failure scenario: conflicting text says to go ahead and fix when the cause seems obvious while required phrases remain.
  - Trigger condition: future copy edits that append contradictory guidance.
  - Impact: green validation on a self-contradictory heavy-debug skill.
  - Proof needed: add negative and branch-specific checks for no repair before evidence, no low-confidence repair confirmation, and no diagnostic-plus-repair mixing.

##### Non-blocking Risks
- Fixture coverage remained prose-heavy and missed several methodology expectations.
  - Broken assumption: fixtures fully protect the requested behavior.
  - Failure scenario: light orientation, stable event naming, repair-ready summary fields, or resolution basis regress without sanity failure.
  - Trigger condition: fixture or skill edits that preserve broad keywords but remove specific expectations.
  - Impact: validation becomes less useful as a guardrail for future skill evolution.
  - Proof needed: assert those fixture expectations in the sanity script.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/bug-killer-sanity.sh` initially checked the low-confidence block only under the wrong ordering condition.
- `scripts/bug-killer-sanity.sh` initially read `scripts/test-repo.sh` but did not read `scripts/validate-repo.sh`.
- The initial script relied mainly on raw substring presence checks.

#### debugging-methodology-adversary

##### Summary
The package and integration looked sound, but two methodology gaps weakened the promised hard diagnostic evidence gate.

##### Blocking Findings
- Evidence gate was not auditable against predeclared predictions.
  - Broken assumption: candidate root causes remain hypotheses until diagnostic evidence is captured against stated predictions.
  - Failure scenario: an agent reads existing logs opportunistically and records support without showing which predicted signal matched.
  - Trigger condition: any case using existing logs, ad-hoc probes, or user feedback after drafting a hypothesis.
  - Impact: hindsight fitting becomes indistinguishable from real confirmation.
  - Proof needed: require each `Evidence` node to reference the exact prediction or evidence-plan clause it supports or refutes.
- Neutral research packet instruction could cause illegal free-form headings in `/coe` cases.
  - Broken assumption: diagnostic packet handling is clearly separated from the strict `/coe` schema.
  - Failure scenario: an agent follows the instruction literally and adds a `Research Packet` section to `/coe`.
  - Trigger condition: repo-backed investigations that need to persist the packet.
  - Impact: the source-of-truth artifact becomes schema-inconsistent.
  - Proof needed: forbid packet storage as extra headings or specify the existing fields that carry it.

##### Non-blocking Risks
- Activation gate under-covered deterministic single-subsystem but deeply stateful bugs.
  - Broken assumption: the gate catches common medium and large bugs.
  - Failure scenario: a reproducible state-machine or data-mutation bug in one subsystem is routed to a lightweight loop.
  - Trigger condition: deep one-module bugs with no broad impact and no prior failed fix.
  - Impact: the skill may be skipped on medium but non-obvious cases.
  - Proof needed: add an activation example and fixture for deep single-subsystem bugs.
- Diagnostic observability lifecycle fields were underspecified.
  - Broken assumption: diagnostic logging and feedback evidence are reusable and auditable.
  - Failure scenario: instrumentation is added without recording correlation keys, true and false expected signals, or removal and retention decisions.
  - Trigger condition: diagnostic-only logs, telemetry, probes, or user feedback.
  - Impact: the evidence trail is weaker and cleanup decisions are ambiguous.
  - Proof needed: add template fields and sanity coverage for those details.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- Initial `SKILL.md` allowed a neutral packet in the case file without a schema-safe mapping.
- Initial `templates/case-template.md` lacked prediction or plan linkage fields on `Evidence` nodes.
- Initial activation fixtures did not cover deep single-subsystem bugs.

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| documentation-skill-adversary | Agent metadata did not preserve the heavy-only activation contract and explicit trigger aliases. | Metadata could over-trigger small bugs or miss explicit `/coe` and evidence-gated aliases. | blocking | accept | `agents/openai.yaml` was too generic for the heavy-only contract. | Updated `short_description` and `default_prompt` with heavy-only scope and explicit aliases. | Round 2 closure review |
| documentation-skill-adversary | Case template allowed repair design while the hypothesis was unverified and the evidence gate was pending. | Template offered repair design before confirmation and evidence-gate satisfaction. | blocking | accept | `templates/case-template.md` listed `start repair design` in the generic unverified hypothesis. | Replaced it with `Repair design readiness: blocked until Status is confirmed and Evidence gate is satisfied`; sanity now rejects `start repair design`. | Round 2 closure review |
| documentation-skill-adversary | Multi-path fallback was underspecified when subagents or external agents are unavailable. | A single local investigation could be mislabeled as multi-path. | major | accept | The initial workflow did not define degraded-runtime path separation. | Added local evidence-path fallback rules and a subagents-unavailable fixture. | Round 2 closure review |
| documentation-skill-adversary | Diagnostic log observability fields were not enforced in the template or sanity script. | Ad-hoc logs could lack event names, IDs, and lifecycle decisions. | major | accept | The template only had coarse instrumentation status. | Added event marker, correlation keys, and instrumentation lifecycle fields plus sanity assertions. | Round 2 closure review |
| test-validity-adversary | Low-confidence branch was not actually enforced by sanity. | The low-confidence block could ask to fix without failing validation. | blocking | accept | The original assertion was guarded by the wrong ordering condition. | Parsed repair-ready and low-confidence fenced blocks directly; required blocked repair status and forbade repair confirmation in the low-confidence block. | Round 2 closure review |
| test-validity-adversary | Repo-wide validate-repo wiring was not asserted by bug-killer sanity. | Repo-wide validation could drop the new sanity script silently. | blocking | accept | The script initially loaded only `scripts/test-repo.sh`. | Added `validate-repo.sh` loading and asserted `scripts/bug-killer-sanity.sh` is in the repo-wide loop. | Round 2 closure review |
| test-validity-adversary | Sanity was mostly presence-only and did not reject contradictory repair-before-proof guidance. | Contradictory guidance could pass while required phrases remained. | blocking | accept | The original checks were mostly positive substring checks. | Added negative checks, branch-specific fenced-block checks, fixture forbidden-bucket checks, and template heading validation. | Round 2 closure review |
| test-validity-adversary | Fixture coverage remained prose-heavy and missed several methodology expectations. | Fixture expectations could regress without sanity failure. | major | accept | Several expectations were not asserted by the first script. | Added checks for activation, deep stateful bugs, instrumentation, subagent fallback, repair-ready summary, and fix validation. | Round 2 closure review |
| debugging-methodology-adversary | Evidence gate was not auditable against predeclared predictions. | Evidence could be hindsight-fit to a hypothesis after reading logs or feedback. | blocking | accept | Evidence nodes lacked a required prediction or plan link. | Required prediction or plan clause links in workflow, template, metadata, fixtures, and sanity. | Round 2 closure review |
| debugging-methodology-adversary | Neutral research packet instruction could cause illegal free-form headings in `/coe` cases. | A `Research Packet` heading could violate the Problem/Hypothesis/Evidence schema. | blocking | accept | The original wording allowed packet storage in the case file without schema mapping. | Restricted packets to response or existing case fields; forbade free-form headings; sanity whitelists template headings. | Round 2 closure review |
| debugging-methodology-adversary | Activation gate under-covered deterministic single-subsystem but deeply stateful bugs. | Deep one-module state bugs could be routed to lightweight debug incorrectly. | major | accept | The initial gate emphasized breadth, repeat failures, and production impact. | Added deep state machine, data mutation, cache lifecycle, concurrency, and history-dependent activation criteria plus fixture. | Round 2 closure review |
| debugging-methodology-adversary | Diagnostic observability lifecycle fields were underspecified. | Diagnostic instrumentation cleanup or retention could be ambiguous. | major | accept | The template did not require lifecycle recording. | Added instrumentation lifecycle and correlation fields to template and sanity coverage. | Round 2 closure review |

### Closure Status

- Blocking findings found: yes
- Accepted blocking findings fixed: yes
- Blocking re-review completed: yes
- Blocking re-review passed: yes
- Blocking re-review round links:
  - Round 2: metadata activation contract closure
  - Round 2: template evidence-gate closure
  - Round 2: low-confidence branch closure
  - Round 2: repo-wide wiring closure
  - Round 2: contradictory guidance guard closure
  - Round 2: evidence-to-prediction linkage closure
  - Round 2: schema-safe packet closure
- Blocking re-review launch records:
  - Round 2 Reviewer Launch Records: documentation-skill-adversary closure reviewer 019e9444-316a-7061-ae64-0fe2972e1d29
  - Round 2 Reviewer Launch Records: documentation-skill-adversary closure reviewer 019e9444-316a-7061-ae64-0fe2972e1d29
  - Round 2 Reviewer Launch Records: test-validity-adversary closure reviewer 019e9444-6b37-78f1-96b2-652fa080e367
  - Round 2 Reviewer Launch Records: test-validity-adversary closure reviewer 019e9444-6b37-78f1-96b2-652fa080e367
  - Round 2 Reviewer Launch Records: test-validity-adversary closure reviewer 019e9444-6b37-78f1-96b2-652fa080e367
  - Round 2 Reviewer Launch Records: documentation-skill-adversary closure reviewer 019e9444-316a-7061-ae64-0fe2972e1d29
  - Round 2 Reviewer Launch Records: documentation-skill-adversary closure reviewer 019e9444-316a-7061-ae64-0fe2972e1d29
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Blocked reason: n/a
- Allowed to proceed: yes

## Round 2: accepted blocking closure review

### Review Input

#### Objective
Verify closure of accepted Round 1 blocking findings for the new `bug-killer` skill.

#### Review Target
Post-fix skill package, validation script, metadata, case template, fixtures, smoke-test wiring, and repo-wide validation wiring.

#### Target Locations
- `skills/bug-killer/SKILL.md`
- `skills/bug-killer/agents/openai.yaml`
- `skills/bug-killer/templates/case-template.md`
- `skills/bug-killer/references/interaction-fixtures.md`
- `scripts/bug-killer-sanity.sh`
- `scripts/test-repo.sh`
- `scripts/validate-repo.sh`
- `registry/skills.json`
- `README.md`
- `docs/plans/2026-06-05-bug-killer-skill.md`

#### Change Introduction
Accepted Round 1 findings were addressed by strengthening metadata, making the case template gate-aware, linking evidence to predeclared predictions or evidence-plan clauses, forbidding free-form packet headings in `/coe`, adding local multi-path fallback rules, covering deep single-subsystem bugs, and expanding `bug-killer-sanity.sh` with branch-specific and negative checks.

#### Risk Focus
- Accepted blocking findings may remain open.
- New checks may still be too superficial.
- Report closure may mask a real validation failure.

#### Assumptions To Attack
- Heavy-only metadata now matches the full activation gate.
- Low-confidence behavior cannot ask for repair.
- Evidence must link to predictions or diagnostic-plan clauses.
- Research packet details cannot create illegal `/coe` headings.
- The sanity script is wired into both `test-repo.sh` and `validate-repo.sh`.
- `validate-repo.sh` failure before closure is only caused by this open report.

#### Adversarial Lenses
- documentation
- testing
- validation
- debugging methodology
- observability
- maintenance

#### Verification Status
- Post-fix `./scripts/bug-killer-sanity.sh` passed.
- Post-fix `./scripts/test-repo.sh bug-killer` passed.
- Post-fix `bash -n scripts/bug-killer-sanity.sh scripts/test-repo.sh scripts/validate-repo.sh` passed.
- Post-fix JSON parse checks passed.
- Post-fix `git diff --check` passed.
- Post-fix `./scripts/validate-repo.sh` failed only because this review report was still `Status: open`.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Return closure verdict and any remaining blockers.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| normal | 12 minutes | none used | 2 | cannot pass if review is unavailable |

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| documentation-skill-adversary | Round 1 included documentation, metadata, schema, and fresh-agent usability blockers. | metadata activation, case template, schema-safe packet handling |
| test-validity-adversary | Round 1 included validation wiring and weak sanity-script blockers. | low-confidence branch, repo-wide wiring, negative checks, fixture coverage |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| documentation-skill-adversary | multi_agent_v1.spawn_agent critic | 019e9444-316a-7061-ae64-0fe2972e1d29 | spawn_agent response in current thread | fork_context=false | Round 2 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |
| test-validity-adversary | multi_agent_v1.spawn_agent test-engineer | 019e9444-6b37-78f1-96b2-652fa080e367 | spawn_agent response in current thread | fork_context=false | Round 2 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| documentation-skill-adversary | documentation-skill-adversary | 1 | 019e9444-316a-7061-ae64-0fe2972e1d29 | 5m | completed | reviewer returned closure verdict | completed |
| test-validity-adversary | test-validity-adversary | 1 | 019e9444-6b37-78f1-96b2-652fa080e367 | 3m | completed | reviewer returned closure verdict | completed |

### Reviewer Outputs

#### documentation-skill-adversary

##### Summary
The accepted Round 1 blockers appear closed. Metadata preserves the heavy-only trigger contract, the case schema blocks repair-before-proof, low-confidence behavior is separately enforced, evidence links to predeclared predictions, free-form `/coe` headings are forbidden, and both single-skill and repo-wide validation wiring exist.

##### Blocking Findings
- none

##### Non-blocking Risks
- Sanity remains primarily phrase-based and could miss future semantic backsliding with different wording.
  - Broken assumption: targeted static checks can catch every future semantic contradiction.
  - Failure scenario: a future edit weakens the methodology using wording not covered by current forbidden phrases.
  - Trigger condition: semantic copy changes that preserve required phrases and avoid current forbidden strings.
  - Impact: a future regression could still pass static contract checks.
  - Proof needed: future behavior-level runner tests or broader semantic review if the skill evolves.
- Repo-wide validation was red until the review report was closed.
  - Broken assumption: validation failure implied unresolved bug-killer package issues.
  - Failure scenario: `validate-repo.sh` fails while the only failing condition is this report's open status.
  - Trigger condition: running full validation before closing the review report.
  - Impact: validation cannot go green until the review artifact is finalized.
  - Proof needed: close the report and rerun `./scripts/validate-repo.sh`.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `skills/bug-killer/agents/openai.yaml` now states heavy-only activation and explicit aliases.
- `skills/bug-killer/templates/case-template.md` now blocks repair design until status is confirmed and the evidence gate is satisfied.
- `scripts/bug-killer-sanity.sh` now asserts repo-wide wiring and negative checks.
- Direct post-fix validation passed except for this report being open.

#### test-validity-adversary

##### Summary
Round 1's accepted blocking findings appear closed. The current package enforces the low-confidence branch, single-skill and repo-wide wiring, negative checks, metadata contract, template gate, prediction-linked evidence, schema-safe packet handling, and fixture coverage.

##### Blocking Findings
- none

##### Non-blocking Risks
- Static contract checks cannot prove runtime skill-runner behavior.
  - Broken assumption: static sanity checks are equivalent to runtime behavior simulation.
  - Failure scenario: a downstream agent reads the skill but fails to follow it despite the text contract being valid.
  - Trigger condition: actual skill execution by a model or runtime outside static repository checks.
  - Impact: validation proves package contract integrity, not runtime compliance.
  - Proof needed: future behavior simulation if this skill gets a runner or benchmark harness.
- Marketplace manifest lacks structured alias fields beyond the agent prompt.
  - Broken assumption: every trigger alias is machine-readable in marketplace metadata.
  - Failure scenario: a tool reads only the market manifest and ignores `agents/openai.yaml`.
  - Trigger condition: external tooling that does not use the agent prompt as routing context.
  - Impact: aliases may be less discoverable outside the OpenAI-compatible agent surface.
  - Proof needed: add structured alias support if the manifest schema later supports it.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `./scripts/bug-killer-sanity.sh` passed after fixes.
- `./scripts/test-repo.sh bug-killer` passed after fixes.
- `bash -n scripts/bug-killer-sanity.sh scripts/test-repo.sh scripts/validate-repo.sh` passed after fixes.
- `./scripts/validate-repo.sh` failed only because this report was still open.

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| documentation-skill-adversary | Sanity remains primarily phrase-based and could miss future semantic backsliding with different wording. | Static checks cannot catch every possible future semantic contradiction. | minor | defer | Closure reviewers agreed this is residual test-rigor risk, not an open blocker. | Documented as residual risk in this report. | Future behavior-level tests if a runner harness is added |
| documentation-skill-adversary | Repo-wide validation was red until the review report was closed. | Full validation could not pass while this report status was open. | minor | accept | The failure output named this report's open status as the blocker. | Closing this report and rerunning validation. | Final validation after report closure |
| test-validity-adversary | Static contract checks cannot prove runtime skill-runner behavior. | Package validation is not the same as observing a model follow the skill. | minor | defer | No runtime behavior harness exists in this repo for skills. | Documented as residual risk. | Future behavior simulation if a runner or benchmark is introduced |
| test-validity-adversary | Marketplace manifest lacks structured alias fields beyond the agent prompt. | External tools that ignore `agents/openai.yaml` may not see aliases. | minor | defer | Current manifest schema in this repo does not include structured aliases. | Kept aliases in `agents/openai.yaml` and documented residual risk. | Add manifest aliases if schema support appears |

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
- Deferred findings documented: yes
- Blocked reason: n/a
- Allowed to proceed: yes

## Final Conclusion

The new `bug-killer` skill may proceed. Round 1 found accepted blocking issues in metadata, template gating, sanity coverage, evidence linkage, and `/coe` schema handling. Those were fixed and verified by Round 2 fresh internal subagents. Remaining risks are non-blocking residual limits of static validation and current marketplace metadata shape.
