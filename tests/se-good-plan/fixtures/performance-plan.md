# Fixture: Performance Optimization Plan

## Input

Write a plan to reduce p95 latency for the order search API. The current
baseline and bottleneck are not yet known.

## Expected Behavior

- Require baseline collection before implementation.
- Require a bottleneck hypothesis before choosing optimization work.
- Include p50, p95, and p99 latency, QPS or throughput, error rate, CPU,
  memory, IO, database slow queries, and cache hit rate when relevant.
- Include load-test comparison and production observation.
- Include benefit validation for latency, throughput, cost, or resource usage.
- Include logging or tracing for request ingress, bottleneck link, downstream
  call, timeout, retry, success, failure, and failure reason.
- Avoid claiming a target improvement until a baseline is known.

## Forbidden Behavior

- Start with implementation before measuring the baseline.
- Promise a specific latency target without provided data.
- Treat local unit tests as sufficient proof of performance improvement.
- List latency metrics without a chain-state logging design.
