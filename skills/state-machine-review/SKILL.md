---
name: state-machine-review
description: Review explicit and implicit state machines in code, PRs, and business workflows. Use to trace transition correctness, workflow completion, state ownership, blocking dependencies, unnecessary serialization, or event and retry loops.
---

# State Machine Review

Review the proposed or implemented lifecycle of a specific workflow or entity. Trace both layers where evidence exists. The code layer covers runtime state, persistence, callbacks, and side effects. The business layer covers the rules that determine who can move a case forward, when prerequisites are met, and when the outcome is complete. For a code-only or design-only input, assess the layer you can inspect and identify what would be needed to compare the two.

## Reconstruct the workflow

1. Name the workflow, the identity of one instance (such as order ID plus attempt ID), its entry points, and the reviewer’s scope. For a diff, trace unchanged callers, writers, or consumers when they can alter the changed lifecycle. Use approved requirements and established contracts for expected business behavior. Record missing or conflicting product rules as questions and trace what the implementation actually does under each relevant interpretation.
2. Identify the authoritative state and who may change it. Trace writes and decision reads through state fields, flag combinations, record presence, timestamps, locks, cache, queues, callbacks, timers, and administrative or recovery paths as relevant. A combination is an implicit state when it determines which action can happen next. Distinguish durable business facts from local execution states and derived views. Record which intermediate mismatches are allowed and what makes those views converge.
3. Trace the important transitions using `from → event or actor [guard] → to`, with the writer, side effects, and evidence. For cross-layer work, connect each business milestone to the code transition or durable fact that satisfies it. Mark the commit or acknowledgment boundary when failure between state persistence and a side effect changes the outcome. A short trace is enough for a narrow review. Use a table or small diagram when multiple writers or workflows make the path hard to follow.

## Review the paths

- **Implicit state machines.** Find state encoded in correlated fields, branch conditions, pending work, or side effects. Show a reachable combination and how it affects a decision. Check for contradictory combinations, multiple writers, and alternate paths that update only part of a state representation.
- **Missing closure.** Follow success, failure, timeout, cancellation, restart, and retry exhaustion where relevant. Define completion for the case or operation under review, including inside a long-running process. For each blocking state, find the actor or event that can advance it and what happens if that trigger fails or disappears. Include cleanup, compensation, and any acknowledgment required by another participant. An intentional human wait can be valid when the responsible actor and exit are defined.
- **Deadlock.** Trace who holds the resource or owns the event and who waits for it. Show the circular wait, including self-wait, and check whether a timeout, cancellation, or abort breaks it. A missing signal or stalled worker with no wait cycle belongs under missing closure or blocking.
- **Cross-module dependencies.** Trace who owns each business decision and whether another module depends on a stable API or event, an internal state value, a persistence detail, or callback ordering. Report the concrete breakage or coordination cost caused by the coupling.
- **Illegal transitions and ownership bypass (错误穿模).** Check both shortcuts that skip required business transitions or entry and exit effects, and writers that bypass the state owner’s transition rules. Trace the specific writer, the prerequisite it skips, and the invariant that fails.
- **One dependency blocks unrelated work.** Trace a slow or failed instance or dependency into shared locks, queues, executors, joins, or global readiness gates. Show which otherwise independent work is blocked and for how long, if the bound is known.
- **Unnecessary serial waits.** Identify the critical path and the data, ordering, capacity, or integrity constraint behind each wait. Flag serialization when independent work could safely make progress sooner, and quantify the delay when there is evidence for it.
- **Feedback loops and retry storms.** Follow state changes, subscriptions, callbacks, and retry layers back to the initiating action. Identify the re-entry condition or multiplicative retry path and the effective limit, deduplication, backoff, or termination rule. Check whether the loop advances business state or amplifies work without progress.

Also look for illegal or unreachable states, overlapping or missing guards, races and lost updates, duplicate or out-of-order events, stale completion from an earlier attempt, re-entrancy, leaked state across instances, and legacy records that cannot advance. Pick the shortest relevant counterexample. Read [failure traces](references/failure-traces.md) for concrete ways to check waits, asynchronous boundaries, and business-state mismatches.

## Report the findings

- Lead with actionable findings ordered by impact and scope. For each, give the expected rule, the shortest reachable trace from a valid starting state, the observed or inferred outcome, the impact, and the source locations or requirement references that support the claim. Include a focused correction or acceptance check when it follows from the evidence.
- Call out the condition that makes a trace feasible, such as an event delivery guarantee, transaction boundary, actor permission, lock ordering, or version check. Treat a static trace as sufficient when the evidence establishes reachability. Where a trace depends on an unverified premise, name it and the observation that would resolve it. Group symptoms that arise from one mechanism.
- Summarize the reviewed scope and any gaps that affect confidence. If there are no findings, say which paths were checked and which could still change the conclusion. A review-only request yields findings without changing code, data, or product rules.
