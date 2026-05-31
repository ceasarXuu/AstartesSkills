# Reviewer Selection

Choose reviewers based on the object under review and the risk profile. Use
1-3 reviewers per round.

## Reviewer Pool

`product-logic-adversary`
: Challenges user goals, product closure, ambiguous requirements, edge cases,
  interaction logic, hidden constraints, and whether the proposed work solves
  the real problem rather than only the stated happy path.

`user-experience-adversary`
: Challenges usability, ease of use, ease of understanding, onboarding, labels,
  defaults, feedback, recovery paths, and whether a realistic user can complete
  the intended flow without hidden context. Acts like a confused but reasonable
  user trying to map the artifact to a real goal.

`architecture-adversary`
: Challenges module boundaries, abstraction level, dependency direction,
  long-term maintainability, duplication, migration path, and short-term patch
  pressure. Acts like a future maintainer extending the system under change.

`implementation-adversary`
: Challenges correctness, state flow, error handling, concurrency, data
  consistency, compatibility, invalid inputs, partial success, retries, and
  hidden edge cases in code.

`test-validity-adversary`
: Challenges self-deceptive tests, tests that only verify implementation
  details, missing black-box checks, missing failure-path checks, regression
  gaps, and weak assertions.

`observability-adversary`
: Challenges whether logs, errors, metrics, traces, artifacts, and runbooks
  are enough to diagnose failures after the main agent is gone. Acts like the
  incident responder reading logs during an outage.

`security-adversary`
: Challenges auth, permissions, privacy, injection, secrets, supply chain,
  untrusted input, data leakage, and trust boundaries. Acts like a hostile user
  trying to bypass assumptions.

`release-ops-adversary`
: Challenges deployment, migration, packaging, upload, rollback, environment
  setup, operational sequencing, partial rollout, and recovery instructions.

`documentation-skill-adversary`
: Challenges docs, skills, prompts, and agent workflows for ambiguity,
  overfitting to the current context, missing trigger rules, missing validation,
  and inability to execute from a fresh session. Acts like a future fresh agent
  trying to follow the artifact without hidden context.

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
- Select `user-experience-adversary` whenever the target changes a user-facing
  workflow, UI, documentation path, skill usage path, prompt behavior, or
  operator procedure where usability or comprehension can make the work fail.
- Each selected reviewer must use an adversarial lens: try to falsify at least
  one assumption, happy path, failure path, security boundary, maintenance claim,
  user-comprehension claim, validation claim, or operational claim.

## Common Combinations

Product or design review:

- `product-logic-adversary`
- `user-experience-adversary` when the user flow, wording, defaults, or
  onboarding path can affect success
- `architecture-adversary` when the design creates system commitments
- `documentation-skill-adversary` when the artifact must guide future agents

Skill, prompt, or agent workflow review:

- `documentation-skill-adversary`
- `user-experience-adversary`
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
