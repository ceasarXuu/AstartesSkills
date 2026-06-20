# Reviewer Selection

Choose one reviewer based on the object under review and the highest-value risk
profile. Use exactly 1 reviewer per round.

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

`implementation-completeness-adversary`
: Challenges whether planned code actually landed in production paths. Compares
  plans, claimed changes, target files, entry points, tests, logs, and runtime
  evidence to detect protocol-only, interface-only, schema-only, entry-only,
  scaffold-only, mock-only, fake-data-only, demo-script-only, or test-only
  wiring that is being counted as completed implementation.

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

- Every review round uses exactly 1 reviewer.
- Select the reviewer with the strongest fit for the highest-value risk in the
  current target.
- Do not add reviewers just to be comprehensive. The selected reviewer must have
  a specific risk focus.
- If the task is not code, do not force an implementation reviewer. Select the
  role that fits the review target.
- Select `user-experience-adversary` whenever the target changes a user-facing
  workflow, UI, documentation path, skill usage path, prompt behavior, or
  operator procedure where usability or comprehension can make the work fail.
- Each selected reviewer must use an adversarial lens: try to falsify at least
  one assumption, happy path, failure path, security boundary, maintenance claim,
  user-comprehension claim, implementation-completeness claim, validation claim,
  or operational claim.
- Select `implementation-completeness-adversary` whenever the target claims a
  plan, phase, or implementation is done and the highest risk is incomplete
  code landing, scaffold-only work, mock-only behavior, or missing production
  integration.

## Common Combinations

Product or design review:

- Prefer `product-logic-adversary`.
- Use `user-experience-adversary` when the user flow, wording, defaults, or
  onboarding path can affect success.
- Use `architecture-adversary` when the design creates system commitments.
- Use `documentation-skill-adversary` when the artifact must guide future agents.

Skill, prompt, or agent workflow review:

- Prefer `documentation-skill-adversary`.
- Use `user-experience-adversary` when usability or comprehension can make the
  workflow fail.
- Use `product-logic-adversary` when requirement fit or product closure is the
  highest risk.
- Use `test-validity-adversary` when validation or anti-self-deception matters
  most.

Tie-break examples:

- Documentation artifact with usability risk: choose `user-experience-adversary`
  when a real user's ability to understand or complete the workflow is the
  highest risk; choose `documentation-skill-adversary` when hidden context,
  missing triggers, or fresh-session executability is the highest risk.
- Skill workflow with validation risk: choose `test-validity-adversary` when the
  main concern is self-deceptive validation; choose `documentation-skill-adversary`
  when the main concern is whether a fresh agent can execute the workflow at all.

Code implementation review:

- Prefer `implementation-adversary`.
- Use `implementation-completeness-adversary` when the key question is whether
  every planned item is fully wired into production code paths rather than only
  protocols, scaffolding, entry points, mocks, fake data, demo scripts, or
  test-only wiring.
- Use `architecture-adversary` when boundaries or long-term design are the
  highest risk.
- Use `test-validity-adversary` when validation quality is the highest risk.

Release or operations review:

- Prefer `release-ops-adversary`.
- Use `observability-adversary` when diagnosis after failure is the highest risk.
- Use `security-adversary` when data, secrets, credentials, or permissions are
  the highest risk.

Security-sensitive review:

- Prefer `security-adversary`.
- Use `implementation-adversary` when correctness and failure handling are the
  highest risk.
- Use `observability-adversary` when post-incident diagnosis is the highest risk.
