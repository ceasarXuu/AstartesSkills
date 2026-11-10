# DeepSeek Harness Desktop

Use the CLI bundled inside the official macOS app with bundle ID `com.deepseek.dsh`. The app name can differ between installs. AgentCommander `check --provider deepseek-harness --desktop-app <absolute .app path>` reports the exact executable and version. Pass the same app path to `run` and `follow-up`. This was checked on Desktop `0.2.2-rc.1`.

Start in the intended absolute `--cwd`. For a follow-up, preserve the adapter's session ID, workspace, and selected installation. Start a new session to change workspaces. Use `--access read-only` for inspection and `--access execute` for authorized work. A resumed session can retain its earlier sandbox. The official CLI examples below describe model configuration, while AgentCommander supplies its own credential and read-only overlays for delegated work.

## Select a model for an official CLI invocation

AgentCommander `--provider deepseek-harness` selects the **agent adapter**. The official CLI selects its **model provider, model, and reasoning effort** through an invocation-scoped `--patch`. The current AgentCommander adapter does not expose these fields as invocation arguments.

For an already configured DeepSeek API-key route, a model-only patch can contain:

```yaml
- id: agent-default-model
  config:
    provider: deepseek-official
    model: deepseek-flash
    reasoningEffort: high
```

Use the provider route and model ID registered by the installed Harness profile, and an effort supported by that route. The `deepseek-official` API-key route and `deepseek-account` saved-account route use different credentials. Keep credentials out of the model patch.

```sh
# Run from the intended workspace. Set dsh to the bundled executable.
"$dsh" --profile headless --json --patch "$model_patch" "$task"
"$dsh" --profile headless --json --patch "$model_patch" --session-id "$session_id" "$follow_up"
```

In `0.2.2-rc.1`, headless applies the current invocation's model selection when resuming. Reapply the same patch if the model should stay fixed. If the configured provider and model match the stored selection and the invocation omits effort, the release can retain the session's previous effort.

Use `"$dsh" --profile headless --patch "$model_patch" --dump-config` to inspect the effective `agent-default-model` block before any model call. Keep the full configuration dump local. On the tested release this confirmed the three fields were applied. It verifies configuration merging; provider authentication and a successful model response require a separate authorized invocation.

- [Official CLI and patch options](https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.2.2-rc.1/apps/cli/README.zh.md)
- [Default model configuration](https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.2.2-rc.1/packages/core/agent-default-model/README.md)
- [Headless resume behavior](https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.2.2-rc.1/packages/bundle/headless/src/index.ts#L365-L395)
- [DeepSeek provider routes and credentials](https://github.com/deepseek-ai/deepseek-harness/blob/dsh-v0.2.2-rc.1/packages/llm/llm-deepseek/README.zh.md)
