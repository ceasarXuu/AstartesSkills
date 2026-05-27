# Reviewer Selection

Choose reviewers based on the object under review and the risk profile. Use
1-3 reviewers per round.

## Reviewer Pool

`product-logic-adversary`
: Challenges user goals, product closure, ambiguous requirements, edge cases,
  interaction logic, and whether the proposed work solves the real problem.

`architecture-adversary`
: Challenges module boundaries, abstraction level, dependency direction,
  long-term maintainability, duplication, migration path, and short-term patch
  pressure.

`implementation-adversary`
: Challenges correctness, state flow, error handling, concurrency, data
  consistency, compatibility, and hidden edge cases in code.

`test-validity-adversary`
: Challenges self-deceptive tests, tests that only verify implementation
  details, missing black-box checks, regression gaps, and weak assertions.

`observability-adversary`
: Challenges whether logs, errors, metrics, traces, artifacts, and runbooks
  are enough to diagnose failures after the main agent is gone.

`security-adversary`
: Challenges auth, permissions, privacy, injection, secrets, supply chain,
  untrusted input, data leakage, and trust boundaries.

`release-ops-adversary`
: Challenges deployment, migration, packaging, upload, rollback, environment
  setup, operational sequencing, and recovery instructions.

`documentation-skill-adversary`
: Challenges docs, skills, prompts, and agent workflows for ambiguity,
  overfitting to the current context, missing trigger rules, missing validation,
  and inability to execute from a fresh session.

## Selection Rules

- Low-risk single-document review: use 1 reviewer.
- Medium-risk design, skill, workflow, or single-module code review: use 2
  reviewers.
- High-risk architecture, data, permissions, migration, release, or multi-module
  change: use 3 reviewers.
- Do not select reviewers just to be comprehensive. Each selected reviewer must
  have a specific risk focus.
- If the task is not code, do not force an implementation reviewer. Select the
  roles that fit the review target.

## Common Combinations

Product or design review:

- `product-logic-adversary`
- `architecture-adversary` when the design creates system commitments
- `documentation-skill-adversary` when the artifact must guide future agents

Skill, prompt, or agent workflow review:

- `documentation-skill-adversary`
- `product-logic-adversary`
- `test-validity-adversary` when validation or anti-self-deception matters

Code implementation review:

- `implementation-adversary`
- `architecture-adversary` when boundaries or long-term design are touched
- `test-validity-adversary` when validation quality is a risk

Release or operations review:

- `release-ops-adversary`
- `observability-adversary`
- `security-adversary` when data, secrets, credentials, or permissions are in
  scope

Security-sensitive review:

- `security-adversary`
- `implementation-adversary`
- `observability-adversary`
