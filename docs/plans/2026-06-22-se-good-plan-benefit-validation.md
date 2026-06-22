# se-good-plan Benefit Validation Update

- Date: 2026-06-22
- Status: Implemented
- Skill id: `se-good-plan`
- Release: `1.2.0`

## Intent

Engineering plans should not only describe what will be built and how to avoid
bugs. They should also state the expected benefit and define how that benefit
will be verified.

This update makes benefit validation a first-class acceptance requirement.

## Contract Changes

- Goals must state expected benefits in addition to deliverables.
- Acceptance must separate correctness validation from benefit validation.
- Correctness validation proves the change works without regressions,
  compatibility failures, data issues, or security failures.
- Benefit validation proves the expected outcome improved, such as speed,
  accuracy, reliability, cost, conversion, or operational-toil improvement.
- Benefit validation must include metric, baseline, target, measurement method,
  data source, observation window, and pass/fail threshold when relevant.
- Unknown baselines or targets must be marked `Unknown` and discovered early,
  not invented.

## Validation Assets

- `scripts/se-good-plan-benefit-sanity.sh`
- `tests/se-good-plan/fixtures/benefit-validation-plan.md`
- Updated `tests/se-good-plan/fixtures/performance-plan.md`
- Updated `tests/se-good-plan/exemplars/full-plan-shape.md`

`scripts/se-good-plan-sanity.sh` invokes the benefit sanity script so the normal
skill smoke and repository validation paths cover the new contract.
