# subagent-vs-review Effectiveness Benchmark

This directory contains a small isolated benchmark for checking whether
`subagent-vs-review` produces useful adversarial findings.

It is intentionally not a fully automated subagent test. Internal subagent
spawning is a runtime capability, not a shell API. The assets here make the
manual/runtime check repeatable without mixing benchmark data into real review
targets.

## Cases

- `fixtures/code/subscription.ts` and `fixtures/code/subscription.test.ts`:
  payment renewal code with seeded billing and test-coverage risks.
- `fixtures/design/remote-terminal-reconnect.md`: reconnect design with seeded
  state, retry, and observability gaps.
- `fixtures/skill/quick-review-skill.md`: weak review workflow with seeded
  isolation and closure gaps.

Expected seeded findings are recorded in `oracles/seeded-defects.md`.

## Isolation Rules

1. Create an ignored runtime copy:

   ```bash
   ./scripts/vs-review-effectiveness-bootstrap.sh
   ```

   The script creates a run under `tmp/vs-review-effectiveness/runs/`, copies
   only reviewer-facing fixtures/templates, initializes a temp
   `vs_review/runtime-report.md`, and prints a canary value that must stay in
   the main-agent context only. Oracle files are intentionally not copied into
   the runtime tree.
2. Spawn fresh internal subagents with `fork_context=false`.
3. Give each reviewer only:
   - the temporary target locations
   - neutral objective and risk focus
   - assumptions to attack
   - adversarial lenses
   - read-only instructions
4. Do not send oracle content to reviewers.
5. Do not send the canary value to reviewers.
6. Record reviewer launch rows in the temp `vs_review/runtime-report.md`.
7. After reviewer outputs are recorded, scan for canary leakage:

   ```bash
   ./scripts/vs-review-effectiveness-scan.sh <run-dir> <canary>
   ```

8. Do not let reviewers inspect any file outside the named target locations,
   including other files inside the copied runtime tree.
9. Write runtime reports under the copied temp project's `vs_review/`.

## Pass Criteria

For a basic effectiveness smoke check:

- all 3 cases run with fresh internal subagents
- no reviewer output includes hidden main-agent context canaries
- at least 2 of 3 cases hit a seeded blocking defect
- total seeded-defect recall is at least 50%
- every blocking or major finding includes broken assumption, failure scenario,
  trigger condition, impact, and proof needed
- no writes occur outside the ignored temp workspace

## Sanity Check

Run:

```bash
./scripts/vs-review-effectiveness-sanity.sh
```

This checks that the benchmark assets exist and do not leak oracle language into
the reviewer-facing fixture files. This is asset sanity only. It does not mean
the runtime effectiveness benchmark has been executed.
