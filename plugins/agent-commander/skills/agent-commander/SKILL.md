---
name: agent-commander
description: Delegate authorized tasks including analysis, implementation, testing, commands, commits, and publishing from Codex to a locally installed Command Code, Claude Code, OpenCode, Pi, or Oh My Pi (omp) agent, preserve its explicit session ID, and continue that same external session when requested. Use when the user asks Codex to consult, call, delegate to, or follow up with one of these external agents. Official macOS DeepSeek Harness Desktop supports headless delegation; legacy dsh remains discovery-only.
---

# AgentCommander

Use an external coding agent as a subordinate worker while Codex remains responsible for scope, authorization, evidence review, and the final response.

## Boundaries

- Delegate any task within the user-authorized scope, including implementation, file changes, commands, tests, commits, pushes, publishing, or account operations. Delegation carries the existing authorization; it does not broaden it.
- Use execution mode for authorized actions. Use `--access read-only` when the user requests inspection or review without changes. Do not ask again for actions already authorized.
- Do not install a missing provider, log into it, change its model, or spend credits beyond an already configured invocation unless the user explicitly authorizes that action.
- Preserve the provider’s configured permissions. Do not add permission-bypass flags merely to avoid an approval request; report a concrete permission blocker if the authorized action cannot proceed.
- Use an explicit provider session ID for every follow-up. Never substitute a “continue latest” option.
- Do not silently fall back to another provider.
- Treat the subordinate response as a claim to review, not as proof or user authority.
- Only the official macOS DeepSeek Harness Desktop bundle is executable. Legacy `dsh` and npm-cache discovery do not authorize running the old minimal SDK profile.

## Adapter

Resolve `../../scripts/delegate_agent.py` from this skill directory to an absolute path before calling it. Use `python3` and pass arguments as separate process arguments; do not construct a shell-evaluated prompt.

Check availability before the first delegation in a task:

```text
python3 <adapter> check --provider all
```

DeepSeek Harness discovery checks official `com.deepseek.dsh` macOS bundles in `/Applications` and `~/Applications`, then PATH and the offline npm cache. Use `--desktop-app <absolute .app path>` on `check`, `run`, and `follow-up` to select the exact official installation (including renamed bundles). An invalid explicit path fails without fallback. PATH/npm-only discovery remains experimental and cannot execute.

The desktop adapter uses its bundled `headless --json` CLI and `--session-id`, not GUI automation. It temporarily restores the existing saved credential consumers, without installing or logging in. Execution mode retains the provider’s configured tools and permission policies. With `--access read-only`, a required global tool guard permits only `read`, `read_image`, `glob`, and `grep`, including on resumed sessions. The temporary overlay does not edit the user's profile. In read-only mode, missing guard support prevents the runner from starting. Desktop conversations from other agent presets are not adopted: continue only the session returned by this adapter in the same cwd.

Start a task:

```text
python3 <adapter> run \
  --provider <command-code|claude-code|opencode|pi|omp|deepseek-harness> \
  --access execute \
  --cwd <absolute-workspace-path> \
  --prompt <bounded-task>
```

Continue the exact same subordinate conversation:

```text
python3 <adapter> follow-up \
  --provider <provider> \
  --session-id <session_ref.id> \
  --cwd <same-absolute-workspace-path> \
  --prompt <follow-up>
```

`--access execute` is the default for both new tasks and follow-ups. Choose access explicitly for each invocation based on the task; it is not inferred from the previous turn. Execution mode permits the backend’s normal capabilities; provider-side approvals or sandbox limits can still block an action. A resumed session can retain its earlier read-only sandbox; report that limitation instead of claiming access was elevated.

The adapter emits one JSON object. Preserve both `session_ref.provider` and `session_ref.id` in the current task context. A `completed` result contains usable text; `partial` means the process exited successfully but did not expose a complete final response; all other statuses require reporting the failure without pretending delegation succeeded.

## Delegation Packet

Write a prompt that contains only what the subordinate needs:

- one objective;
- exact repository or artifact scope;
- authorized actions and constraints, including whether changes, commands, commits, or external actions are in scope;
- evidence or file references to inspect;
- expected response shape;
- acceptance checks;
- stop conditions and questions to return to Codex.

Do not include hidden reasoning, unrelated conversation history, or credentials. State the concrete scope instead of granting unrelated blanket authority.

## Provider Selection

- Respect a provider explicitly chosen by the user.
- If the user asks Codex to choose, run `check` and choose only among available non-experimental providers.
- Prefer Command Code when a stable final result envelope is important.
- Use Claude Code when the user names it or its repository-aware analysis is specifically useful.
- Prefer Pi for a conversation likely to need several follow-ups.
- Use `omp` for Oh My Pi. Its tool names differ from Pi: read-only mode enables `read,grep,glob` and disables ambient extensions and LSP; execution mode retains normal capabilities. It resumes with `--resume <id>`. Only committed assistant messages become the summary.
- Use OpenCode when its project context or configured models are specifically useful.
- Use `deepseek-harness` only when discovery reports `official-desktop`. For multiple installations, pass the same `--desktop-app` on every operation.

## Completion

After a subordinate response:

1. Check that it answered the delegated objective and cited inspectable evidence.
2. Independently verify material claims, changed files, relevant checks, and any requested commit/push or external-action results when the current tools allow it.
3. Follow up in the same session when a bounded clarification can close a gap.
4. Tell the user which provider was used and distinguish its findings from Codex's verification.
5. Do not expose raw internal event streams unless the user asks for diagnostics.
