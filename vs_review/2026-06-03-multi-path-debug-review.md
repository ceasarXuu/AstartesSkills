# Subagent VS Review: multi-path-debug skill

- Created: 2026-06-03T20:24:00+08:00
- Updated: 2026-06-03T22:10:23+08:00
- Report schema: adversarial-v1
- Task: Add `multi-path-debug`, a root-cause-first bug investigation skill that separates root-cause confirmation from repair.
- Report path: `vs_review/2026-06-03-multi-path-debug-review.md`
- Review mode: fresh internal subagents
- Source session policy: no inherited main-agent context
- Status: passed

## Round 1: implemented skill package review

### Review Input

#### Objective
Review whether the new `multi-path-debug` skill satisfies the requested behavior: first perform light orientation and targeted context questions, then run independent root-cause research paths with user-approved external agents when available, synthesize by evidence weight, summarize cause and fix direction, and wait for user confirmation before repair.

#### Review Target
Skill package, metadata, registry and README integration, validation scripts, and operational notes.

#### Target Locations
- `skills/multi-path-debug/SKILL.md`
- `skills/multi-path-debug/agents/openai.yaml`
- `skills/multi-path-debug/markets/openai-compatible.json`
- `scripts/multi-path-debug-sanity.sh`
- `scripts/test-repo.sh`
- `scripts/validate-repo.sh`
- `registry/skills.json`
- `README.md`
- `README.zh-CN.md`
- `docs/runbooks/operational-notes.md`

#### Change Introduction
A new installable skill named `multi-path-debug` was added. It introduces a root-cause-first debug workflow, optional external-agent authorization, independent research-path synthesis, and an investigation artifact under `debug/multi-path/` or an existing stronger debug artifact convention.

#### Risk Focus
- The workflow may still allow repair before root-cause confirmation.
- External agents may be invoked without explicit user approval.
- Low-confidence hypotheses may be presented as repair-ready causes.
- The sanity script may protect words rather than the intended interaction contract.
- The repo validator may miss package drift between `skills/` and `registry/skills.json`.
- README, registry, market manifest, and default prompt may drift from the skill body.

#### User-Perspective Review Focus
- Whether a user can understand that the first deliverable is root-cause confirmation, not a fix.
- Whether external-agent authorization is clear, optional, and non-blocking.
- Whether low-confidence outcomes ask for more investigation instead of asking to repair.
- Whether final summaries are concise enough to support a repair decision.

#### Assumptions To Attack
- A default prompt that summarizes the skill will preserve the same permission gates as `SKILL.md`.
- Phrase-based sanity checks are enough to prevent workflow drift.
- The repo validator catches all installable skill packaging drift.
- A single repair confirmation template is safe for all confidence levels.
- External-agent discovery can be useful without becoming mandatory.

#### Adversarial Lenses
- requirements
- usability
- ease-of-use
- comprehension
- permission boundary
- testing
- observability
- maintenance

#### Verification Status
- Pre-review `./scripts/multi-path-debug-sanity.sh` passed.
- Pre-review `./scripts/test-repo.sh multi-path-debug` passed.
- Pre-review `./scripts/validate-repo.sh` passed.
- Primary reviewers were launched but became unavailable with `not_found`; replacement reviewers completed.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Return sections: Summary, Blocking Findings, Non-blocking Risks, User-Perspective Checks, Required Fixes, Missing Tests, Missing Logs / Observability, Evidence.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| complex | 5m primary wait, then replacement | none used | 2 | cannot pass until replacement or follow-up review closes accepted blockers |

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| workflow-adversary | The skill is a reusable agent workflow whose permission gates and phase ordering must survive fresh use. | root-cause flow, user approval, low-confidence branch |
| packaging-adversary | The change adds a new installable skill and validation surface. | registry, market metadata, smoke tests, repo validator |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| workflow-adversary | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8d6c-3489-7b63-80c0-32bbcac3c31b | spawn_agent tool result nickname Einstein | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |
| packaging-adversary | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8d6c-5c89-7b91-a271-fd926764bde1 | spawn_agent tool result nickname Aquinas | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |
| workflow-adversary | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8dbe-a08a-7801-b34c-dc4c7e5fecb7 | spawn_agent tool result nickname McClintock | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |
| packaging-adversary | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8dbe-cfd8-7a51-b347-c91035a30c96 | spawn_agent tool result nickname Laplace | fork_context=false | Round 1 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| workflow-primary | workflow-adversary | 1 | 019e8d6c-3489-7b63-80c0-32bbcac3c31b | 10m | lost | wait returned not_found for primary workflow reviewer | replacement spawned |
| packaging-primary | packaging-adversary | 1 | 019e8d6c-5c89-7b91-a271-fd926764bde1 | 10m | lost | wait returned not_found for primary packaging reviewer | replacement spawned |
| workflow-adversary-replacement | workflow-adversary | 2 | 019e8dbe-a08a-7801-b34c-dc4c7e5fecb7 | 4m | completed | replacement reviewer returned workflow findings | completed |
| packaging-adversary-replacement | packaging-adversary | 2 | 019e8dbe-cfd8-7a51-b347-c91035a30c96 | 5m | completed | replacement reviewer returned packaging findings | completed |

### Reviewer Outputs

#### workflow-adversary-replacement

##### Summary
- The package is integrated, but the reusable entrypoint and terminal branch were weaker than the main skill contract.

##### Blocking Findings
- `agents/openai.yaml` drops the external-agent authorization gate.
  - Broken assumption: the default prompt preserves the same permission boundary as the full skill body.
  - Failure scenario: a runtime starts from `default_prompt` and runs external research paths without first asking which optional external agents the user approves.
  - Trigger condition: use through a skill picker or agent runtime that reads `agents/openai.yaml` before loading the full body.
  - Impact: code, logs, or prompts may be sent to an external agent without explicit user authorization.
  - Proof needed: default prompt must explicitly discover optional external agents and ask approval before invoking them.
- The low-confidence branch still points toward repair authorization.
  - Broken assumption: the final repair confirmation template is safe for all confidence levels.
  - Failure scenario: the agent marks confidence `low` but still asks the user to start the fix, turning a hypothesis into a repair approval request.
  - Trigger condition: investigation has a plausible location but lacks reproduction, log proof, or falsified alternatives.
  - Impact: implementation can begin from an unconfirmed cause, defeating the skill's purpose.
  - Proof needed: low-confidence output must ask to continue investigation, not to repair.
- The sanity script proves section names and phrases, not realistic behavior.
  - Broken assumption: phrase presence protects the root-cause-before-repair contract.
  - Failure scenario: future edits retain checked phrases while moving repair confirmation into the low-confidence path or weakening external-agent approval.
  - Trigger condition: wording-preserving refactors to `SKILL.md`, fixtures, or prompt metadata.
  - Impact: smoke tests can pass after the product logic regresses.
  - Proof needed: scoped checks for low-confidence, repair-ready, external authorization, and fixture expected-versus-forbidden behavior.

##### Non-blocking Risks
- The maintainer README smoke-test example only names `clear-prd`.
  - Broken assumption: maintainers will discover the new skill-specific smoke path from scripts alone.
  - Failure scenario: a future maintainer updates `multi-path-debug` but only runs the default smoke test.
  - Trigger condition: README-guided maintenance.
  - Impact: skill-specific contract regressions may be missed locally.
  - Proof needed: README should show `./scripts/test-repo.sh multi-path-debug`.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `skills/multi-path-debug/agents/openai.yaml:4` initially omitted the external-agent authorization gate.
- `skills/multi-path-debug/SKILL.md:188` initially used an unconditional repair confirmation block.
- `scripts/multi-path-debug-sanity.sh:38` initially checked sections and phrases only.
- `README.md:252` initially showed only the default and `clear-prd` smoke examples.

#### packaging-adversary-replacement

##### Summary
- Packaging was mostly coherent, but repo validation missed an important registry coverage class and the skill smoke test was too string-driven.

##### Blocking Findings
- `validate-repo.sh` misses a real packaging-drift class.
  - Broken assumption: checking every registry path and every folder's required files is enough to prove package registration.
  - Failure scenario: an on-disk skill folder exists under `skills/` but is missing from `registry/skills.json`, and repository validation still passes.
  - Trigger condition: adding a skill directory without registering it.
  - Impact: a skill can exist in the repo but be undiscoverable and unexported.
  - Proof needed: compare skill directories and registry entries in both directions.
- `scripts/test-repo.sh multi-path-debug` does not prove the root-cause-before-repair contract in a meaningful way.
  - Broken assumption: package presence, export success, and string fragments prove the workflow contract.
  - Failure scenario: future edits keep required phrases while weakening low-confidence behavior, approval gating, or evidence-weighted synthesis.
  - Trigger condition: workflow edits that preserve exact strings.
  - Impact: smoke tests can report success after the skill stops enforcing its core product logic.
  - Proof needed: fixture-backed scoped sanity checks that bind to behavioral branches.

##### Non-blocking Risks
- Generated `dist` drift is not repo-validated.
  - Broken assumption: source manifest validation is enough for every generated artifact surface.
  - Failure scenario: a stale `dist/markets/openai-compatible/*.json` remains after a skill is removed or renamed.
  - Trigger condition: generated artifacts are committed or distributed without a clean export check.
  - Impact: downstream consumers may see stale marketplace data.
  - Proof needed: add a stale-dist guard if `dist/` becomes a committed release surface.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/validate-repo.sh:65` initially checked skill folders for required files.
- `scripts/validate-repo.sh:75` initially checked registry paths existed.
- `scripts/test-repo.sh:51` initially invoked the skill-specific sanity check with output suppressed.

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| workflow-adversary-replacement | `agents/openai.yaml` drops the external-agent authorization gate. | The default prompt could be used without the full skill body and skip explicit approval for external agents. | blocking | accept | The prompt was shorter than the permission contract in `SKILL.md`. | Strengthened `agents/openai.yaml` to require optional external-agent discovery, approval before invocation, evidence-weighted synthesis, and repair stop. | Round 2 and Round 4 |
| workflow-adversary-replacement | The low-confidence branch still points toward repair authorization. | A low-confidence hypothesis could still be turned into a request to start repair. | blocking | accept | The initial repair confirmation block was unconditional. | Split `SKILL.md` into repair-ready and low-confidence templates; low confidence now asks to continue investigation. | Round 2 and Round 4 |
| workflow-adversary-replacement | The sanity script proves section names and phrases, not realistic behavior. | Future edits could preserve phrases while moving repair confirmation or weakening authorization. | blocking | accept | The initial script checked section and phrase presence. | Added interaction fixtures, scoped template checks, fixture bucket checks, and later prompt order and contradiction checks. | Round 2, Round 3, and Round 4 |
| workflow-adversary-replacement | The maintainer README smoke-test example only names `clear-prd`. | Maintainers may miss the new skill-specific smoke path. | minor | accept | README examples omitted `multi-path-debug`. | Added `./scripts/test-repo.sh multi-path-debug` and updated explanatory text. | n/a |
| packaging-adversary-replacement | `validate-repo.sh` misses a real packaging-drift class. | A skill folder could exist without registry coverage. | blocking | accept | The validator did not compare actual skill folders to registry paths. | Added two-way skill registry coverage checks and count logging. | Round 2 and Round 4 |
| packaging-adversary-replacement | `scripts/test-repo.sh multi-path-debug` does not prove the root-cause-before-repair contract in a meaningful way. | String-based checks could pass after workflow semantics regress. | blocking | accept | This independently confirmed the workflow-adversary sanity finding. | Added fixtures and scoped sanity checks; subsequent rounds tightened low-confidence, fixture-bucket, and prompt validation. | Round 2, Round 3, and Round 4 |
| packaging-adversary-replacement | Generated `dist` drift is not repo-validated. | Stale generated marketplace outputs could survive if `dist/` becomes a committed release surface. | minor | defer | `dist/` is generated by `test-repo.sh`; current repo validation focuses on source manifests. | No immediate code change; kept as future release-surface hardening if `dist/` is committed. | n/a |
| packaging-adversary-replacement | Log discovered and registered skill counts during repository validation. | Validation output did not expose the compared sets. | minor | accept | The accepted registry coverage fix benefits from observable counts. | Added `registered skills` and `discovered skill folders` output. | n/a |
| packaging-adversary-replacement | Surface skill-specific sanity output from `test-repo.sh`. | Suppressed sanity output made failures harder to diagnose. | minor | accept | `test-repo.sh` used redirection for sanity scripts. | Removed redirection for skill-specific sanity scripts. | n/a |

### Closure Status

- Blocking findings found: yes
- Accepted blocking findings fixed: yes
- Blocking re-review completed: yes
- Blocking re-review passed: yes
- Blocking re-review round links:
  - Round 4: final prompt and fixture-scoped sanity closure for workflow-adversary external-agent finding
  - Round 4: final prompt and low-confidence closure for workflow-adversary low-confidence finding
  - Round 4: final scoped sanity closure for workflow-adversary sanity finding
  - Round 4: final registry coverage closure for packaging-adversary registry finding
  - Round 4: final scoped sanity closure for packaging-adversary smoke-test finding
- Blocking re-review launch records:
  - Round 4 Reviewer Launch Records: final-closure-review session 019e8dd0-51d6-72c2-8b71-1b90ca118879
  - Round 4 Reviewer Launch Records: final-closure-review session 019e8dd0-51d6-72c2-8b71-1b90ca118879
  - Round 4 Reviewer Launch Records: final-closure-review session 019e8dd0-51d6-72c2-8b71-1b90ca118879
  - Round 4 Reviewer Launch Records: final-closure-review session 019e8dd0-51d6-72c2-8b71-1b90ca118879
  - Round 4 Reviewer Launch Records: final-closure-review session 019e8dd0-51d6-72c2-8b71-1b90ca118879
- Rejected findings backed by evidence: n/a
- Deferred findings documented: yes
- Blocked reason: n/a
- Allowed to proceed: yes

## Round 2: accepted blocker closure review

### Review Input

#### Objective
Verify that the accepted Round 1 blockers were closed after strengthening the default prompt, splitting the low-confidence branch, adding interaction fixtures, improving sanity checks, updating README smoke docs, and adding two-way registry coverage validation.

#### Review Target
Post-fix closure review for the accepted Round 1 findings.

#### Target Locations
- `skills/multi-path-debug/SKILL.md`
- `skills/multi-path-debug/agents/openai.yaml`
- `skills/multi-path-debug/references/interaction-fixtures.md`
- `scripts/multi-path-debug-sanity.sh`
- `scripts/validate-repo.sh`
- `scripts/test-repo.sh`
- `README.md`

#### Change Introduction
The skill was updated with a stronger default prompt, a low-confidence continuation branch, interaction fixtures, fixture-aware sanity checks, README smoke-test examples, and two-way registry validation.

#### Risk Focus
- The sanity script may still be too phrase-driven.
- The default prompt may still not enforce the external-agent approval gate.
- The low-confidence branch may still ask to repair.
- Registry coverage validation may not catch missing entries.

#### User-Perspective Review Focus
- Whether low-confidence output clearly asks to continue investigation rather than repair.
- Whether external-agent approval is visible from the default prompt.
- Whether smoke failures are useful enough for maintainers.

#### Assumptions To Attack
- Fixture presence is enough to close the phrase-only validation gap.
- The low-confidence and repair-ready branches are now distinct.
- The repo validator now catches both missing registry entries and missing folders.
- The README accurately tells maintainers how to run the new skill-specific check.

#### Adversarial Lenses
- testing
- permission boundary
- usability
- comprehension
- maintenance
- observability

#### Verification Status
- `./scripts/multi-path-debug-sanity.sh` passed.
- `./scripts/test-repo.sh multi-path-debug` passed.
- `./scripts/validate-repo.sh` passed.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Explicitly pass or fail each accepted blocker.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| normal | 5m | none used | 2 | cannot pass if accepted blocker closure is unavailable |

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| closure-review | Accepted blocking findings require a fresh follow-up review. | blocker closure, validation adequacy |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| closure-review | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8dc6-02d6-72a3-b719-3a55b30331eb | spawn_agent tool result nickname Tesla | fork_context=false | Round 2 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| closure-review | closure-review | 1 | 019e8dc6-02d6-72a3-b719-3a55b30331eb | 4m | completed | reviewer returned closure review and failed one blocker | completed |

### Reviewer Outputs

#### closure-review

##### Summary
- Three accepted blockers were fixed, but the sanity gate still relied too heavily on phrase presence rather than scoped behavioral validation.

##### Blocking Findings
- `scripts/multi-path-debug-sanity.sh` remains phrase-driven rather than behavior-scoped.
  - Broken assumption: adding fixture files and more required phrases is enough to close the phrase-only test gap.
  - Failure scenario: Fixture 3 could contain the repair confirmation phrase under expected behavior or forbidden behavior and still satisfy raw substring checks.
  - Trigger condition: future edits that move checked phrases into the wrong branch or bucket.
  - Impact: the sanity script may pass while low-confidence repair prevention regresses.
  - Proof needed: parse low-confidence and repair-ready template blocks, and validate fixture expected and forbidden buckets separately.

##### Non-blocking Risks
- `README.md` is stale relative to validator behavior.
  - Broken assumption: README's required file list and validation checklist still describe current enforcement.
  - Failure scenario: a maintainer treats `agents/openai.yaml` as optional even though validation requires it.
  - Trigger condition: maintainer follows README rather than scripts.
  - Impact: local packaging expectations are unclear.
  - Proof needed: align README required files and validation checklist with scripts.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/multi-path-debug-sanity.sh:42` still used a generic phrase helper.
- `scripts/multi-path-debug-sanity.sh:103` checked fixture sections by raw phrase presence.
- `README.md:181` still treated `agents/openai.yaml` as strongly recommended.

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| closure-review | `scripts/multi-path-debug-sanity.sh` remains phrase-driven rather than behavior-scoped. | The fixture and template checks could pass after moving required phrases into the wrong branch or bucket. | blocking | accept | The reviewer showed that raw substring checks did not prove low-confidence and repair-ready behavior. | Added fenced-block checks for low-confidence versus repair-ready summaries and expected-versus-forbidden fixture bucket validation. | Round 4 |
| closure-review | `README.md` is stale relative to validator behavior. | Maintainers could treat files as optional even when validation requires them. | minor | accept | README still called `agents/openai.yaml` strongly recommended. | Updated README required files and validation checklist. | n/a |
| closure-review | Replace phrase-presence checks with scoped assertions for low-confidence template, repair-ready template, fixture expected buckets, and fixture forbidden buckets. | Required fix for the accepted blocking sanity gap. | minor | accept | Same counterexample as the blocking finding. | Added `fenced_block_after`, fixture bucket parsing, positive and negative bucket assertions. | n/a |
| closure-review | Surface sanity script failure reasons in smoke output. | Suppressed sanity output made failures less diagnosable. | minor | accept | `test-repo.sh` redirected skill-specific sanity output. | Removed output suppression for skill-specific sanity scripts. | n/a |

### Closure Status

- Blocking findings found: yes
- Accepted blocking findings fixed: yes
- Blocking re-review completed: yes
- Blocking re-review passed: yes
- Blocking re-review round links:
  - Round 4: final scoped sanity closure after Round 2 blocker
- Blocking re-review launch records:
  - Round 4 Reviewer Launch Records: final-closure-review session 019e8dd0-51d6-72c2-8b71-1b90ca118879
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Blocked reason: n/a
- Allowed to proceed: yes

## Round 3: prompt validation closure review

### Review Input

#### Objective
Verify whether the remaining sanity-script blocker is closed after adding scoped low-confidence, repair-ready, and fixture bucket checks.

#### Review Target
Second closure review for `scripts/multi-path-debug-sanity.sh`, plus smoke output and README alignment.

#### Target Locations
- `scripts/multi-path-debug-sanity.sh`
- `skills/multi-path-debug/SKILL.md`
- `skills/multi-path-debug/references/interaction-fixtures.md`
- `skills/multi-path-debug/agents/openai.yaml`
- `scripts/test-repo.sh`
- `README.md`

#### Change Introduction
The sanity script now parses fenced summary blocks, validates low-confidence and repair-ready behavior separately, validates fixture expected and forbidden buckets separately, and exposes sanity output through `test-repo.sh`.

#### Risk Focus
- Prompt validation may still be a loose full-file substring check.
- The sanity script may not reject contradictory prompt wording.
- README manifest requirements may still be imprecise.

#### User-Perspective Review Focus
- Whether the default prompt preserves user approval before external-agent use.
- Whether the default prompt prevents repair requests when confidence is low.
- Whether maintainers can understand smoke-test failures.

#### Assumptions To Attack
- Template and fixture scoped checks are enough to close the full phrase-only validation gap.
- The default prompt cannot contradict the skill body while still passing sanity.
- README wording matches `test-repo.sh` expectations.

#### Adversarial Lenses
- testing
- permission boundary
- prompt contract
- maintenance
- observability

#### Verification Status
- `./scripts/multi-path-debug-sanity.sh` passed.
- `./scripts/test-repo.sh multi-path-debug` passed.
- `./scripts/validate-repo.sh` passed.
- Two temporary negative mutations for low-confidence and fixture bucket placement failed as expected.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Pass or fail the remaining blocker.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| normal | 5m | none used | 2 | cannot pass if prompt validation remains phrase-only |

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| prompt-closure-review | The last open risk is validation of the default prompt contract. | prompt validation, permission ordering |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| prompt-closure-review | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8dc9-9b8b-77b0-bfbb-cbe4b156006a | spawn_agent tool result nickname Volta | fork_context=false | Round 3 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| prompt-closure-review | prompt-closure-review | 1 | 019e8dc9-9b8b-77b0-bfbb-cbe4b156006a | 4m | completed | reviewer returned prompt validation closure review and failed one blocker | completed |

### Reviewer Outputs

#### prompt-closure-review

##### Summary
- Template and fixture bucket checks improved, but `agents/openai.yaml` validation was still too shallow.

##### Blocking Findings
- `agents/openai.yaml` is still validated by loose substring presence rather than scoped behavioral assertions.
  - Broken assumption: checking phrases in the lowercased YAML file is enough to prove the default prompt preserves approval order and low-confidence behavior.
  - Failure scenario: the prompt keeps expected phrases but tells the agent to run research paths before asking approval, or adds a contradiction that asks to fix even if confidence is low.
  - Trigger condition: prompt edits that preserve required substrings but reverse order or add contradictory instructions.
  - Impact: the default entrypoint can leak the external-agent permission boundary or undermine low-confidence safety.
  - Proof needed: parse `default_prompt`, enforce approval before external research, enforce low-confidence continuation before repair confirmation, and reject explicit contradictory phrases.

##### Non-blocking Risks
- README slightly understates the manifest requirement for smoke-tested skills.
  - Broken assumption: marketplace manifest metadata is only generally recommended.
  - Failure scenario: a smoke-tested skill lacks `markets/openai-compatible.json` and `test-repo.sh` fails despite README implying it is optional.
  - Trigger condition: adding or maintaining a smoke-tested skill.
  - Impact: maintainer confusion about required package shape.
  - Proof needed: clarify README wording for smoke-tested or marketplace-exported skills.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/multi-path-debug-sanity.sh:127` still checked phrases in the whole YAML content.
- `skills/multi-path-debug/agents/openai.yaml:4` is the actual default prompt field that needed scoped validation.
- `README.md:182` still needed clearer manifest wording.

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| prompt-closure-review | `agents/openai.yaml` is still validated by loose substring presence rather than scoped behavioral assertions. | The default prompt could keep phrases while reversing approval order or adding low-confidence repair contradiction. | blocking | accept | The reviewer identified an unclosed prompt-specific variant of the phrase-only gap. | Added `default_prompt` extraction, order checks, and explicit contradictory-phrase rejection; validated with two negative prompt mutations. | Round 4 |
| prompt-closure-review | README slightly understates the manifest requirement for smoke-tested skills. | Maintainers could assume market manifests are optional for smoke-tested packages even though `test-repo.sh` requires one. | minor | accept | README wording did not match smoke-test enforcement. | Changed README wording to `Required for smoke-tested or marketplace-exported skills`. | n/a |
| prompt-closure-review | Add a negative prompt-order mutation showing approval must precede external research. | Missing test for prompt order. | minor | accept | Same counterexample as the blocking prompt finding. | Ran a temporary mutation where research preceded approval; sanity failed with an order violation. | n/a |
| prompt-closure-review | Add a negative prompt-contradiction mutation showing low-confidence repair contradiction fails. | Missing test for contradictory prompt wording. | minor | accept | Same counterexample as the blocking prompt finding. | Ran a temporary mutation adding `Ask to fix even if confidence is low`; sanity rejected it. | n/a |

### Closure Status

- Blocking findings found: yes
- Accepted blocking findings fixed: yes
- Blocking re-review completed: yes
- Blocking re-review passed: yes
- Blocking re-review round links:
  - Round 4: final default-prompt scoped validation closure
- Blocking re-review launch records:
  - Round 4 Reviewer Launch Records: final-closure-review session 019e8dd0-51d6-72c2-8b71-1b90ca118879
- Rejected findings backed by evidence: n/a
- Deferred findings documented: n/a
- Blocked reason: n/a
- Allowed to proceed: yes

## Round 4: final accepted blocking closure review

### Review Input

#### Objective
Verify final closure of the remaining prompt-validation blocker after `scripts/multi-path-debug-sanity.sh` was updated to parse `default_prompt`, enforce prompt ordering, and reject contradictory prompt phrases.

#### Review Target
Final closure review for `multi-path-debug` sanity validation and README wording.

#### Target Locations
- `scripts/multi-path-debug-sanity.sh`
- `skills/multi-path-debug/agents/openai.yaml`
- `skills/multi-path-debug/SKILL.md`
- `skills/multi-path-debug/references/interaction-fixtures.md`
- `scripts/test-repo.sh`
- `README.md`

#### Change Introduction
The sanity script now extracts `default_prompt`, checks that external-agent approval precedes independent research paths, checks that low-confidence continuation precedes repair confirmation, rejects explicit contradictory phrases, and README wording now treats market manifests as required for smoke-tested or marketplace-exported skills.

#### Risk Focus
- The prompt validation may still be too loose.
- README wording may still not match smoke behavior.
- The final review chain may still have unclosed accepted blockers.

#### User-Perspective Review Focus
- Whether user approval is preserved before external-agent use.
- Whether low-confidence results do not ask for repair.
- Whether maintainers get actionable smoke output.

#### Assumptions To Attack
- Parsing `default_prompt` plus order and contradiction checks closes the remaining blocker.
- The README now accurately describes required package files for smoke-tested skills.
- Negative prompt mutations are sufficient evidence for the targeted regression family.

#### Adversarial Lenses
- testing
- prompt contract
- permission boundary
- maintenance
- observability

#### Verification Status
- `./scripts/multi-path-debug-sanity.sh` passed.
- `./scripts/test-repo.sh multi-path-debug` passed.
- `./scripts/validate-repo.sh` passed.
- Negative prompt order mutation failed as expected.
- Negative prompt contradiction mutation failed as expected.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Pass or fail the final blocker.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| normal | 5m | none used | 2 | final report cannot pass if this closure review finds a blocker |

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| final-closure-review | Accepted blocking findings require final fresh review after all fixes. | prompt validation, closure evidence |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| final-closure-review | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8dd0-51d6-72c2-8b71-1b90ca118879 | spawn_agent tool result nickname Maxwell | fork_context=false | Round 4 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| final-closure-review | final-closure-review | 1 | 019e8dd0-51d6-72c2-8b71-1b90ca118879 | 4m | completed | reviewer returned final closure pass | completed |

### Reviewer Outputs

#### final-closure-review

##### Summary
- The final blocker is closed. The sanity check now extracts `default_prompt`, enforces approval before external-agent research, enforces low-confidence continuation before repair confirmation, and rejects explicit contradictory prompt phrases.

##### Blocking Findings
- none

##### Non-blocking Risks
- Regex-based YAML value extraction is format-sensitive.
  - Broken assumption: `default_prompt` will remain a simple one-line scalar.
  - Failure scenario: a future block-scalar or escaped YAML value may not be parsed correctly.
  - Trigger condition: changing `agents/openai.yaml` formatting without updating the sanity script.
  - Impact: validation can fail or miss prompt content after a format change.
  - Proof needed: use a YAML parser or keep the one-line prompt convention.
- Contradiction rejection is intentionally narrow.
  - Broken assumption: the current forbidden phrases cover every possible contradictory wording.
  - Failure scenario: semantically equivalent contradictory wording bypasses the exact phrase list.
  - Trigger condition: prompt edits using different wording for the same bad behavior.
  - Impact: a future prompt regression could require another fixture expansion.
  - Proof needed: add more negative prompt fixtures when new bad patterns appear.

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/multi-path-debug-sanity.sh:139` extracts and validates `default_prompt`.
- `scripts/multi-path-debug-sanity.sh:153` enforces approval before external-agent research.
- `scripts/multi-path-debug-sanity.sh:159` enforces low-confidence continuation before repair confirmation.
- `scripts/multi-path-debug-sanity.sh:165` rejects explicit contradictory prompt phrases.
- `skills/multi-path-debug/agents/openai.yaml:4` contains the strengthened default prompt.
- `README.md:182` aligns manifest wording with smoke-test behavior.
- `scripts/test-repo.sh:51` dispatches to `multi-path-debug-sanity.sh` without suppressing output.

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| final-closure-review | Regex-based YAML value extraction is format-sensitive. | A future block-scalar prompt could require parser support. | minor | defer | Current `default_prompt` is a simple one-line scalar and the reviewer did not classify this as blocking. | Documented residual risk in review report; no code change required for current package. | n/a |
| final-closure-review | Contradiction rejection is intentionally narrow. | Semantically equivalent wording could require future fixture expansion. | minor | defer | Current known bad mutations fail and the reviewer did not classify this as blocking. | Documented residual risk in review report; future bad patterns should be added as fixtures. | n/a |
| final-closure-review | Add future negative cases for multiline `default_prompt` if the YAML format changes. | Missing future-proofing test for a format not used by the current package. | minor | defer | The current file uses a one-line scalar. | No current change; defer until YAML format changes. | n/a |
| final-closure-review | Add future negative prompt fixtures if new contradictory wording patterns appear. | Missing future-proofing for unknown wording variants. | minor | defer | Current known prompt-order and contradiction mutations fail. | No current change; defer until a new bad pattern is observed. | n/a |

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

## Round 5: post-review validator split review

### Review Input

#### Objective
Verify that splitting the registry coverage check out of `scripts/validate-repo.sh` into a helper script preserved behavior and restored compliance with the repository's 500-line code-file rule.

#### Review Target
Post-review code split for the repository validator.

#### Target Locations
- `scripts/validate-repo.sh`
- `scripts/validate-skill-registry-coverage.py`
- `vs_review/2026-06-03-multi-path-debug-review.md`

#### Change Introduction
After Round 4 passed, `scripts/validate-repo.sh` exceeded the repository line-limit rule. The new registry coverage logic was extracted to `scripts/validate-skill-registry-coverage.py`, and `validate-repo.sh` now delegates to that helper.

#### Risk Focus
- The extraction could weaken registry coverage validation.
- The helper may not be executable or portable.
- The review report may no longer reflect the final implementation surface.
- The line-limit issue may remain unresolved.

#### User-Perspective Review Focus
- Maintainers should still get clear validation output and actionable failure reasons.
- The repository should remain consistent with its own contribution rules.

#### Assumptions To Attack
- A mechanical extraction preserved behavior.
- Direct helper invocation is portable enough for this repo.
- Existing validation commands are sufficient evidence for the split.
- The existing review report still supports closure after the helper extraction.

#### Adversarial Lenses
- testing
- maintenance
- portability
- observability
- documentation

#### Verification Status
- `./scripts/multi-path-debug-sanity.sh` passed.
- `./scripts/test-repo.sh multi-path-debug` passed.
- `./scripts/validate-repo.sh` passed.
- `git diff --check` passed.
- Line counts: `scripts/validate-repo.sh` 493 lines; `scripts/validate-skill-registry-coverage.py` 56 lines.

#### Reviewer Instructions
- Fresh internal subagent session.
- No inherited main-agent context.
- Read target files directly.
- Do not modify files.
- Cite evidence paths and line numbers when possible.
- Return final pass or fail for the split.

### Reviewer Timeout Policy

| Complexity | Initial Wait | Extension | Max Attempts Per Role | Blocking Closure Behavior |
|---|---:|---:|---:|---|
| simple | 5m | none used | 2 | final report cannot pass if the split breaks validation behavior |

### Reviewer Selection

| Reviewer | Reason Selected | Risk Area |
|---|---|---|
| validator-split-review | The only new change after closure was a validator extraction. | behavior preservation, line limit, script portability |

### Reviewer Launch Records

| Reviewer | Internal Mechanism | Session / Job ID | Trace Source | Context Forked | Input Packet | Context Explicitly Excluded | Read-only |
|---|---|---|---|---|---|---|---|
| validator-split-review | multi_agent_v1.spawn_agent gpt-5.4 medium | 019e8dd8-9a2e-7080-bf9e-c5548e7a049f | spawn_agent tool result nickname Hilbert | fork_context=false | Round 5 Review Input | main-agent history, reasoning, drafts, conclusions, full diff unless needed | yes |

### Reviewer Timeout Records

| Reviewer Output Key | Reviewer Role | Attempt | Session / Job ID | Waited | Status | Reason | Action |
|---|---|---:|---|---:|---|---|---|
| validator-split-review | validator-split-review | 1 | 019e8dd8-9a2e-7080-bf9e-c5548e7a049f | 3m | completed | reviewer returned pass for validator split | completed |

### Reviewer Outputs

#### validator-split-review

##### Summary
- The split is behavior-preserving. `validate-repo.sh` now delegates registry coverage validation to the helper, and the helper still enforces non-empty ids and paths, id/path consistency, duplicate detection, two-way folder and registry coverage, and observable count logging.

##### Blocking Findings
- none

##### Non-blocking Risks
- none

##### Required Fixes
- none

##### Missing Tests
- none

##### Missing Logs / Observability
- none

##### Evidence
- `scripts/validate-repo.sh:75` delegates to `scripts/validate-skill-registry-coverage.py`.
- `scripts/validate-skill-registry-coverage.py:22` preserves the registry coverage checks.
- `scripts/validate-skill-registry-coverage.py:48` preserves the registered/discovered count log.
- `vs_review/2026-06-03-multi-path-debug-review.md:1` remains marked `Status: passed`.

### Main Agent Response

| Reviewer | Finding | Broken Assumption / Failure Scenario | Severity | Decision | Evidence / Reason | Action Taken | Follow-up |
|---|---|---|---|---|---|---|---|
| validator-split-review | Final pass for validator split. | The behavior-preserving extraction could have broken registry coverage validation or line-limit compliance. | minor | accept | Reviewer found no blocking issues and confirmed the helper preserves the closure conditions. | Kept the helper extraction and recorded the review in Round 5. | n/a |

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
- Blocked reason: n/a
- Allowed to proceed: yes

## Final Conclusion

The `multi-path-debug` skill package may proceed. Initial review found real blocking issues in default prompt permissions, low-confidence repair flow, semantic sanity coverage, and registry coverage. Those blockers were accepted, fixed, and re-reviewed through fresh sessions. The final closure review passed with no blocking findings. A later validator helper extraction was also reviewed and passed. Residual risks are limited to future YAML formatting and future contradictory wording variants, both documented as non-blocking maintenance concerns.
