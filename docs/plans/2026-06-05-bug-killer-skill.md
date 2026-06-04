# Bug Killer Skill Design Record

- Status: Ready for implementation
- Created: 2026-06-05
- Updated: 2026-06-05
- Owner / requester: user
- Source request: Create a new `bug-killer` skill that fuses `coe-debug`,
  `multi-path-debug`, and a mandatory diagnostic proof step before repair
  design, without patching the old skills.

## Requester Review Summary

- Key decisions:
  - Create a new installable `bug-killer` skill.
  - Do not modify `skills/coe-debug` or `skills/multi-path-debug`.
  - Treat Bug Killer as a heavy process for medium and large bugs, not a
    default path for small obvious defects.
  - Use `/coe` as the durable case artifact and source of truth.
  - Use multi-path investigation as the evidence-generation strategy.
  - Add a hard candidate-root-cause evidence gate before repair design.
  - Require evidence to link back to a predeclared prediction or diagnostic
    evidence-plan clause so the gate is auditable instead of narrative.
  - Keep `/coe` case files schema-safe; no free-form research-packet headings.
- Important exceptions:
  - Diagnostic-only instrumentation may be added before repair only when it is
    explicitly labeled as diagnostic and kept separate from repair behavior.
- Must-confirm before implementation:
  - None. The user explicitly requested the new skill and named its core
    methodology.
- Status reason:
  - The behavior, non-goals, artifact model, and acceptance criteria are clear
    enough to implement without another question.

## Goals

- Give future agents one unified debugging method instead of choosing between
  disconnected debug skills.
- Stop the pattern where a plausible candidate cause immediately turns into a
  repair plan.
- Make logs, probes, tests, runtime checks, or user feedback the bridge from
  candidate cause to repair design.
- Preserve evidence and reviewability across long debugging sessions.

## Scope

### In Scope

- New `skills/bug-killer` package with `SKILL.md`, `agents/openai.yaml`,
  `markets/openai-compatible.json`, a case template, and interaction fixtures.
- Registry and README discovery entries.
- Repository smoke and sanity validation.
- Adversarial review report under `vs_review/`.

### Out Of Scope

- Editing `skills/coe-debug`.
- Editing `skills/multi-path-debug`.
- Removing or deprecating the old skills.
- Implementing a runtime tool beyond the skill methodology and validation
  script.

## Acceptance Criteria

- `bug-killer` is installable through the registry.
- The skill states an activation gate and tells agents to avoid the heavy flow
  for small deterministic one-file bugs unless the user explicitly requests it.
- The skill states that repair design is forbidden until diagnostic evidence
  confirms the root-cause mechanism.
- The skill uses `/coe` case files with only Problem, Hypothesis, and Evidence
  nodes.
- The skill requires independent research paths for non-trivial bugs when
  available.
- The skill requires diagnostic-only instrumentation to stay separate from
  repair behavior.
- The skill requires diagnostic evidence to reference the prediction or
  evidence-plan clause it tested.
- The skill requires user confirmation before repair implementation.
- The skill requires fix-validation evidence before marking a problem fixed.
- `./scripts/bug-killer-sanity.sh`, `./scripts/test-repo.sh bug-killer`, and
  `./scripts/validate-repo.sh` pass.
