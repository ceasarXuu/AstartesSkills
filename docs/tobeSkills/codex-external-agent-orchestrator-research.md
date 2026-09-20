# Codex 主控外部 Agent 协作 Skill 调研

> 调研日期：2026-09-20  
> 阶段：可行性研究，尚未进入正式 skill 设计与实现

## 1. 目标

研究一个由 Codex 作为主 Agent、其他本地 coding agent 作为从 Agent 的协作 skill。主 Agent 负责：

- 拆分和下发任务；
- 限定工作目录、权限与交付物；
- 接收并校验从 Agent 的结果；
- 保存从 Agent 的会话标识；
- 在同一上下文中继续追问；
- 决定是否采纳、修改或拒绝从 Agent 的产出。

本轮覆盖四种从 Agent：

1. DeepSeek Harness（`dsh`）
2. OpenCode（`opencode`）
3. Command Code（`command-code` / `cmd`）
4. Pi Coding Agent（`pi`）

## 2. 结论摘要

四种方案均可接入，但适配层不能假定它们具有相同的运行模型。

| 从 Agent | 推荐接入方式 | 结构化输出 | 指定会话续接 | 运行中追问 | 当前建议 |
| --- | --- | --- | --- | --- | --- |
| Command Code | Headless CLI | 稳定的 NDJSON 最终结果 | 支持 | 下次进程续接 | 首批支持 |
| Pi | stdio RPC；简单任务可用 JSON CLI | 完整事件流 | 支持 | 原生 `steer` / `follow_up` | 首批支持 |
| OpenCode | `run --format json` | JSONL 事件流 | 支持 | 下次进程续接；服务 API 可增强 | 首批支持，但需兼容检查 |
| DeepSeek Harness | Python SDK | `RunResult` + 通知 | 支持 | 复用 SDK 进程或相同会话 ID | 实验性支持 |

推荐采用“两类适配器”而不是一个固定命令模板：

- **短进程 CLI 适配器**：Command Code、OpenCode，以及 Pi 的简单调用。每轮启动一个进程，用显式 session id 续接。
- **驻留式适配器**：Pi RPC、DeepSeek Harness Python SDK。主 Agent 保持子进程，按事件协议发送追问并等待稳定完成状态。

不要用“继续最近会话”作为正式协议。并发执行时，`--continue` 可能指向错误会话；主 Agent 必须记录并传回明确的 session id。

## 3. 四种方案调研

### 3.1 DeepSeek Harness

官方定位是插件化 Agent runtime，目前仍处于 developer preview，并明确警告可能发生破坏性兼容变更。公开的直接运行入口主要是 Web UI；适合程序化主从调用的是 Python SDK，而不是把 `dsh web` 当作 headless CLI。

Python SDK 的关键能力：

- `DeepSeekHarness.run(prompt, session_id=...)` 返回包含 `final_response` 的结果；
- 同一 `dsh_home` 与 `session_id` 可延续持久会话；
- SDK 懒启动并复用内置 JSON-RPC 子进程；
- 会话日志保存在 `<dsh_home>/sessions`；
- 可通过通知与底层 API 获得更细粒度运行信息。

主要风险：

- `sdk-minimal` 默认没有 compaction、Web、subagent、本地 instruction discovery 等能力；
- `sdk-minimal` 默认 shell 是 `danger-full-access`，不会把访问限制在工作目录；
- 需要 Python 包、独立 `DSH_HOME`、DeepSeek-compatible endpoint 和凭据；
- 仍在 developer preview，适配器必须做版本探测，不能依赖未固定的内部文件格式。

建议：为它单独提供一个小型 Python adapter；默认要求隔离 checkout 或容器，不允许直接在高价值工作区中以默认权限执行写任务。

官方资料：

- [DeepSeek Harness 仓库](https://github.com/deepseek-ai/deepseek-harness)
- [Python SDK 入门](https://deepseek-harness.github.io/deepseek-harness/en/guide/python-sdk)
- [Session 子系统](https://deepseek-harness.github.io/deepseek-harness/en/reference/subsystems/session)

### 3.2 OpenCode

OpenCode 提供直接适合主从调用的非交互接口：

```text
opencode run --format json "<task>"
opencode run --session <session-id> --format json "<follow-up>"
```

关键能力：

- `run` 面向脚本和 CI；
- `--format json` 输出逐行 JSON 事件；
- 每条 JSON 事件包含 `sessionID`，可由首条事件提取；
- `--session/-s` 可精确续接，`--fork` 可分叉；
- `--dir` 可固定工作目录；
- 还可通过后台服务 API 显式创建、查询和驱动 session。

主要风险：

- `--continue` 在并发场景下不可靠，必须使用明确的 `sessionID`；
- 官方 issue 曾记录部分版本在复杂续接会话中漏发 JSON 文本或最终事件，不能只以“进程退出码为 0”判断结果完整；
- 本机已安装版本为 `1.18.4`，正式实现应针对实际版本做一次真实但隔离的 smoke test；
- `--auto` 会自动批准未显式拒绝的权限，skill 不应默认添加。

建议：首批支持。适配器读取所有 JSONL 行，提取 `sessionID` 和文本事件；若没有完整文本，则通过官方 session export/API 验证会话结果，而不是读取内部 SQLite schema。

官方资料：

- [OpenCode CLI 命令](https://opencode.ai/v2/docs/cli/commands/)
- [OpenCode run 实现](https://github.com/anomalyco/opencode/blob/dev/packages/opencode/src/cli/cmd/run.ts)
- [续接会话 JSON 输出问题示例](https://github.com/anomalyco/opencode/issues/31482)

### 3.3 Command Code

Command Code 的 headless 模式最接近本 skill 所需的“调用—返回—继续追问”协议：

```text
command-code --no-auto-update -p "<task>" --output-format json
command-code --no-auto-update -p --resume <session-id> "<follow-up>" --output-format json
```

关键能力：

- NDJSON 事件流最后固定输出一条 result；
- result 包含 `subtype`、`finalText`、usage、duration，以及成功建立会话后的 `sessionId`；
- `--resume <id>` 可精确续接 headless 会话；
- 明确的退出码可区分权限、认证、限流、网络、max-turns 等错误；
- headless 默认阻止写文件、编辑和 shell，适合安全的只读委派。

主要风险：

- `--yolo` 会跳过权限，应禁止作为 skill 默认值；
- `sessionId` 在认证或输入等早期失败时可能缺失；
- CLI 默认可能自动更新。本次只执行 `--help` 时，本机版本已从 `1.57.0` 自动更新到 `1.58.0`，自动化调用必须统一添加 `--no-auto-update`；
- `cmd` 在 Windows 是系统 shell 名称，跨平台实现应优先调用 `command-code`，Windows 可使用 `cmdc`。

建议：作为首选 CLI 适配器。其最终结果结构最适合稳定映射为统一回传协议。

官方资料：

- [Command Code CLI Reference](https://commandcode.ai/docs/reference/cli)
- [Command Code Headless Mode](https://commandcode.ai/docs/headless)
- [Command Code Sessions](https://commandcode.ai/docs/sessions)

### 3.4 Pi Coding Agent

Pi 同时提供 print、JSON、RPC 和 SDK。对于需要 Codex 多次追问、运行中纠偏的主从关系，RPC 是四种方案里最贴近需求的原生协议：

```text
pi --mode rpc
```

RPC 通过 stdin/stdout 传输逐行 JSON。主 Agent 可发送：

- `prompt`：开始一轮任务；
- `steer`：当前运行期间改变方向；
- `follow_up`：当前任务稳定结束后自动继续追问；
- `abort`：中止；
- `get_last_assistant_text`：读取最终回复；
- `get_entries`：按稳定 entry id 增量读取会话；
- `clone` / `fork`：复制或分叉会话。

应以 `agent_settled` 而不是较早的 `agent_end` 作为本轮真正结束信号，因为后者之后仍可能发生重试、压缩或队列续接。

简单的一次性任务也可使用：

```text
pi --mode json -p "<task>"
pi --session <path-or-id> --mode json -p "<follow-up>"
```

主要风险：

- Pi 官方明确说明没有内建文件系统、进程、网络或凭据权限系统，默认继承启动进程全部权限；
- RPC 客户端必须严格按 LF 分帧，并正确处理异步事件；
- 持久 RPC 进程需要生命周期管理、超时、中断和崩溃恢复；
- 本机安装的是 `@mariozechner/pi-coding-agent 0.73.1`，当前上游仓库已经迁移到 `earendil-works/pi`，实现时应以本机 CLI 行为和版本为准。

建议：首批支持，但写任务必须由 Codex 先提供外部沙箱或隔离 worktree；只读任务应限制 Pi 的工具集。

官方资料：

- [Pi 仓库](https://github.com/earendil-works/pi)
- [Pi RPC Protocol](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/rpc.md)
- [Pi JSON Event Stream](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/json.md)

## 4. 建议的统一主从协议

Skill 不应只告诉 Codex“执行某条命令”，而应规定一个稳定的委派契约。

### 4.1 主 Agent 下发包

```json
{
  "task_id": "stable-local-id",
  "objective": "单一、可验证的目标",
  "context": ["只包含从 Agent 完成任务所需的事实"],
  "working_directory": "/absolute/path",
  "allowed_paths": ["/absolute/path/subtree"],
  "mutation_mode": "read-only | write",
  "acceptance_checks": ["必须满足的验证条件"],
  "deliverables": ["回复、补丁或文件"],
  "stop_conditions": ["需要返回主 Agent 决策的情况"]
}
```

### 4.2 从 Agent 回传包

适配器应把各家事件流归一化为：

```json
{
  "status": "completed | needs_input | partial | failed",
  "session_ref": {
    "provider": "pi | opencode | command-code | deepseek-harness",
    "id": "provider-session-id"
  },
  "summary": "从 Agent 的最终说明",
  "files_changed": [],
  "commands_run": [],
  "checks": [],
  "questions": [],
  "raw_artifact": "可选的原始 JSONL 日志路径"
}
```

`session_ref` 是继续追问的唯一依据。禁止从“最近一次会话”、标题或工作目录猜测会话。

### 4.3 权限与控制边界

- Codex 始终是最终决策者，从 Agent 的建议和修改不是自动可信结果。
- 默认只读委派；只有用户任务已授权修改，且主 Agent 明确把本次子任务设为 `write` 时才允许写。
- 同一工作树同一时间最多一个写入型从 Agent；并行写任务使用相互隔离的 worktree，并由主 Agent合并。
- 不把主 Agent 的完整隐藏历史传给从 Agent，只发送最小任务包。
- 从 Agent 不得自行扩大范围、创建 PR、提交、push、发布或调用第三个 Agent，除非任务包明确授权。
- 认证、付费调用、外部消息发送和危险权限仍受当前用户授权边界约束。
- 超时、认证失败、权限拒绝、输出缺失必须显式返回失败，不得静默切换到另一家 Agent。

## 5. Skill 结构建议

建议 skill 名称：`external-agent-delegator`。

```text
skills/external-agent-delegator/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── delegation-contract.md
│   ├── deepseek-harness.md
│   ├── opencode.md
│   ├── command-code.md
│   └── pi.md
└── scripts/
    └── delegate_agent.py
```

职责边界：

- `SKILL.md`：判断何时值得委派、选择哪个从 Agent、规定授权与验收闭环；
- provider reference：保存版本相关的命令、事件、会话恢复和故障语义；
- `delegate_agent.py`：只做进程启动、事件解析、超时、中断和统一回传，不承担任务拆分决策；
- DeepSeek Harness adapter 可先作为脚本中的可选 provider，依赖缺失时明确报告 unavailable。

不建议把该 skill 与现有 `subagent-vs-review` 合并。后者是“对抗性审查”流程；本研究对象是通用外部 Agent 委派，覆盖实现、分析、测试和追问，产品边界不同。未来 `subagent-vs-review` 可以把本 skill 作为经用户授权的外部执行后端之一。

## 6. 建议的实现阶段

### 阶段 A：契约与只读 MVP

- 支持 Command Code、OpenCode、Pi；
- 仅允许只读任务；
- 输出统一回传包；
- 支持显式 session id 续接；
- 对缺失 CLI、认证失败、超时和不完整输出给出确定错误。

### 阶段 B：写入型委派

- 引入路径范围与隔离 worktree；
- 记录修改文件和验证命令；
- 由 Codex 复核 diff 后决定是否保留；
- 不默认开启 `--yolo`、`--auto` 或同类危险权限。

### 阶段 C：驻留会话与 DeepSeek Harness

- 实现 Pi RPC 生命周期；
- 增加运行中 `steer` 和完成后 `follow_up`；
- 增加 DeepSeek Harness Python SDK adapter；
- 为 developer-preview 版本建立兼容性探测和 smoke test。

## 7. 尚需用户确认的产品决策

正式编写 skill 前，需要确认以下边界：

1. 从 Agent 是否允许直接修改主工作树，还是写任务一律隔离到 worktree；
2. 首版是否只做“Codex 主控”，还是把协议写成 Claude、OpenCode 等主 Agent 也可复用；
3. 是否允许自动选择从 Agent，还是必须由用户指定；
4. 是否允许从 Agent 使用已有账户订阅/额度，还是每次付费调用前都需要提示；
5. 是否需要支持并发从 Agent，还是首版只保证串行主从协作。

## 8. 当前推荐决策

建议先实现以下最小版本：

- 仅以 Codex 为主 Agent；
- 用户可指定从 Agent，未指定时由 Codex依据能力和可用性选择并说明；
- 默认只读；写任务使用隔离 worktree；
- 首版串行，避免多个外部 Agent 争用同一目录和“最近会话”；
- 首批正式支持 Command Code、OpenCode、Pi；
- DeepSeek Harness 标记为 experimental，待真实 SDK smoke test 通过后升级；
- 所有追问都使用明确 session id；
- 主 Agent 始终复核从 Agent 的证据和改动，不把“成功退出”视为任务完成。
