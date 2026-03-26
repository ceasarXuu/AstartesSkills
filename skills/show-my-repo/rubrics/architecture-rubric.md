# Architecture Rubric

Use this rubric to explain the system in an outward-facing way.

## Map

- Interface layer: app, web, CLI, API, desktop shell
- Core logic: services, orchestration, domain modules, agents, workflows
- State and storage: DB, files, caches, local persistence, queues
- Integration layer: third-party APIs, model providers, auth, billing, messaging
- Validation layer: tests, CI, scripts, health checks, demos

## Questions

1. What are the main system components?
2. What responsibilities are cleanly separated?
3. What is the primary user flow through the system?
4. Which technical decisions materially affect speed, privacy, reliability, or extensibility?
5. Which dependencies are essential versus incidental?

## Translation Pattern

Do not stop at naming tools.

Bad:
- Uses FastAPI, Redis, WebSocket, and SQLite.

Better:
- Uses a lightweight service layer and realtime feedback loop to reduce wait-time perception during interactive tasks, while local persistence keeps setup and data ownership simpler for single-user deployments.

## Guardrails

- Mention technologies only after stating why they matter
- Avoid internal jargon if the same idea can be explained with user-facing impact
- Separate implemented architecture from aspirational architecture
