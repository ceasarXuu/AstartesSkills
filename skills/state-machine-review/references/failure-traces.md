# Failure Traces

Use the traces that match the workflow. Start with one real instance and a reachable state. Add a second actor or instance only when the mechanism depends on interaction.

## Waits, dependencies, and feedback

| Condition | Trace to reconstruct | Evidence to check |
| --- | --- | --- |
| Deadlock | A retains a lock or executor slot while waiting for B. B needs that same resource to emit the completion A awaits. | Acquisition and release, callback execution context, queue or pool capacity, and whether any alternative signal, timeout, or abort can release the wait. Check that all waits in the cycle can coexist. [PostgreSQL deadlock example](https://www.postgresql.org/docs/current/explicit-locking.html#LOCKING-DEADLOCKS) |
| Missing closure | A records `pending`. Its only callback is lost, or arrives before the consumer is ready and is discarded. No later event or reconciliation advances A. | Registration and durability of the signal, matching keys, retry expiry, timeout handling, and any recovery owner. |
| One failure blocks unrelated work | One stuck case holds a global worker slot or a queue head. Other cases share the same gate although their business data is independent. | Scope and capacity of the gate, queue ordering, shared resource occupancy, and behavior after one failure or timeout. |
| Avoidable serialization | One branch completes before the next starts, even though the latter needs only data already available at entry. | Dependencies between the actual reads and writes, commit precedence, concurrency limits, and the cost on the critical path. A join can be required even when its branches can run independently. [W3C SCXML parallel-state completion](https://www.w3.org/TR/scxml/#parallel) |
| Livelock or starvation | Workers repeatedly yield and retry on collision without committing, or one case repeatedly loses access while others keep advancing. | Progress per cycle, contender selection, fairness, timing, and which cases actually advance. |
| Feedback storm | A listener writes an unchanged value, the write republishes the event, and a consumer causes the same write. Or multiple layers retry one failing call and multiply the attempts. | Handler filters, event IDs, deduplication window, fan-out, retry owners and limits, and whether the cause eventually clears. Separate repeated churn from amplification. [AWS on retry amplification](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/) |

## State and side effects

- **Duplicate, reordered, or late messages.** Deliver success twice, deliver cancellation before success, or deliver attempt 1’s success during attempt 2. Check identity, event version, guard evaluation, and whether a retry can repeat an external effect. Verify that guard checks and writes are atomic where simultaneous writers can both pass.
- **Partial progress and recovery.** Interrupt the flow immediately before and after each relevant durable write, publish, or external side effect. Check what a restart can distinguish, whether replay can safely repair the gap, and how compensation itself completes or escalates. A compensating action may need to preserve work from another actor or account for an irreversible step. [Azure Compensating Transaction pattern](https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction)
- **Illegal, ambiguous, or unreachable states.** For an illegal or ambiguous transition, find a valid initial state and the event/guard sequence that reaches the disputed edge. For a supposedly unreachable outcome, check the incoming transitions and show why none can fire within scope. Check overlapping guards and their precedence, omitted events, and terminal-state re-entry. Start from persisted legacy records when migrations or mixed-version workers change the allowed combinations.
- **Hidden or conflicting state.** If multiple fields, replicas, or local views seem authoritative, identify which reads drive a decision and which writers update each representation. Check whether lag is within the workflow’s contract or whether a stale read can authorize an irreversible transition.

## Example across the two layers

Consider an order where the approved rule requires inventory reservation before shipment. Payment is a separate workflow. An order handler derives `readyToShip` from `paymentCapturedAt != null && canceledAt == null`. A warehouse consumer ships on that flag, while reservation finishes via a separate callback.

- The state is implicit because the field combination enables a new action. A reachable trace is `order placed → payment captured → warehouse ships → reservation fails`. The shipping guard has no evidence of the required reservation.
- If the warehouse also writes `shippedAt` directly, trace who owns that transition and whether the direct write skips the owning workflow’s checks. Treat the guard defect and the direct writer as separate findings only when each has an independently reachable path.
- If the warehouse instead verifies the relevant committed reservation before shipping, that check can prevent the cited trace. Establish which source it reads and whether the reservation matches the current order and attempt before drawing a conclusion.
