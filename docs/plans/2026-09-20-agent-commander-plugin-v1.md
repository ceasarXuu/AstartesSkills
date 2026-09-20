# PRD：AgentCommander Plugin v0.2

- Status: Draft
- Created: 2026-09-20
- Updated: 2026-09-20
- Owner / requester: 仓库维护者
- Source request: 将 Codex 主控外部 coding agent 的协作能力开发为第一版 Plugin。
- Product Authority: Confirmed Product Decisions section

## Requester Review Summary

- Key decisions: 第一版交付形态为 Codex Plugin。
- Important exceptions: DeepSeek Harness 的最小 SDK 默认提供高权限 shell，v0.2 不自动执行它。
- Must-confirm before implementation: v0.2 之后是否支持写入、并发和仓库 marketplace 分发。
- Status reason: 可实现安全的只读原型，但后续写入与分发规则仍需确认。

## 1. Background And Product Intent

Codex 需要把边界明确的分析、审查或代码理解任务交给本机其他 coding agent，并在获得结果后使用同一会话继续追问。当前五个目标后端使用不同的 CLI、事件流和会话模型，需要一个可安装、可发现且返回结构稳定的本地协调能力。

## 2. Goals And Success Criteria

- 以 Plugin 形式提供，不把能力绑定到单一仓库的全局指令中。
- 检测 DeepSeek Harness、OpenCode、Command Code、Claude Code 和 Pi 的本机可用性。
- 对首批可执行后端提供只读任务启动与精确会话续接。
- 将不同输出归一化为稳定 JSON，使 Codex 能复核结果。
- 失败时明确区分后端缺失、不支持、超时、非零退出和无有效回复。

## 3. Users And Usage Context

首版面向在 Codex 本地工作区中工作的开发者。目标后端及其账户、模型与凭据由用户自行安装和配置；Plugin 不接管密钥。

## 4. Scope

### In Scope

- 标准 Plugin 清单和 Codex 兼容清单。
- 一个可被 Codex 调用的编排 Skill。
- 一个标准库 Python 适配器。
- `check`、`run`、`follow-up` 三类操作。
- Command Code、Claude Code、OpenCode、Pi 的只读调用。
- DeepSeek Harness 的探测与 experimental 状态说明。
- 单元测试、Plugin 校验和仓库校验。

### Out Of Scope

- 自动启用危险权限或直接执行写任务。
- 多个外部 Agent 并发修改同一工作树。
- 自动安装、登录或购买外部 Agent 服务。
- 公共 HTTPS MCP 服务。
- GUI、远端任务队列、跨机器会话恢复。

## 5. Core User Journey

1. Codex 根据任务判断外部委派是否有实际收益。
2. Codex 运行 `check`，确认用户指定或候选后端可用。
3. Codex 生成最小、只读、可验证的任务描述并调用 `run`。
4. 适配器启动后端，解析事件流并返回统一 JSON 和 `session_ref`。
5. Codex 复核回复；必要时用 `follow-up` 和同一个 `session_ref.id` 追问。
6. Codex 向用户报告从 Agent 结论与自己的复核结论，不把子 Agent 回复视为事实证明。

## 6. Interaction And Information Design

Plugin 通过自然语言 Skill 被发现。适配脚本的 stdout 仅输出一个 JSON 对象；诊断信息进入结果的 `error`/`stderr` 字段或进程 stderr，不混入正常结果。

## 7. Product Rules And State Logic

- v0.2 委派固定为只读。
- 会话续接必须使用明确 session id，禁止依赖“最近会话”。
- 不自动切换后端；指定后端失败即返回失败。
- 不自动附加 `--yolo`、`--auto` 或等价危险参数。
- Command Code 调用固定附加 `--no-auto-update`。
- Claude Code 调用固定使用 `plan` 权限模式、`Read,Glob,Grep` 工具白名单并关闭启动时自动更新。
- DeepSeek Harness v0.2 返回 experimental/unavailable-to-run，不静默执行高权限 shell。

## 8. Edge Cases, Errors, And Recovery

- CLI 不存在：返回 `unavailable` 和候选命令名。
- 超时：终止子进程并返回 `timeout`。
- 非零退出：返回 `failed`、退出码和截断后的 stderr。
- JSONL 含未知事件：忽略未知类型，继续寻找会话和最终文本。
- 成功退出但无有效文本：返回 `partial`，保留 session id 供后续检查。
- 续接没有 session id：参数校验失败，不退回 `--continue`。

## 9. Content And Terminology

- 主 Agent：Codex。
- 从 Agent：由 Plugin 启动的外部 coding agent。
- provider：`command-code`、`claude-code`、`opencode`、`pi`、`deepseek-harness`。
- session ref：由 provider 和 provider session id 组成的稳定续接标识。

## 10. Acceptance Criteria

- Given 五个 CLI 均未安装，when 执行 `check`，then 返回五个 provider 的结构化不可用状态且不崩溃。
- Given 一个受支持的假 CLI，when 执行 `run`，then 使用只读参数启动并返回归一化文本与 session id。
- Given 一个有效 session id，when 执行 `follow-up`，then 命令包含该精确 id，不使用最近会话选项。
- Given Claude Code，when 执行或续接只读任务，then 使用安全参数、解析 `result` JSON，并保留精确 `session_id`。
- Given DeepSeek Harness，when 请求执行，then v0.2 明确拒绝并说明 experimental 安全边界。
- Given 后端输出未知 JSON 事件，when 解析，then 已知最终结果仍可返回。
- Given 完成实现，when 运行 Plugin 和仓库校验，then 全部通过。

## 11. Review Checklist And Sign-off Questions

- 是否接受 v0.2 仅执行只读任务？
- 后续写任务是否一律使用隔离 worktree？
- 是否将本 Plugin 加入仓库级 marketplace？
- 是否需要把 DeepSeek Harness 执行能力列入 v0.3？

## Confirmed Product Decisions

> PROTECTED USER-AUTHORITY SECTION
> Rows in this section MUST NOT be created, modified, deleted, reinterpreted,
> or superseded without explicit user approval for that specific decision change.
> Agent self-approval is forbidden.

| ID | Confirmed Decision | Must Do | Must Not Do | Rationale | Violation Signal | Confirmation | Status |
|---|---|---|---|---|---|---|---|
| PD1 | 第一版交付为 Codex Plugin。 | 提供可被 Codex 安装和发现的 Plugin 包。 | 只交付散落的提示词或单独脚本。 | 用户明确要求尝试开发第一版 Plugin。 | 交付物没有 Plugin manifest。 | user-confirmed-direct: “尝试开发成第一版 plugin” | active |
| PD2 | Plugin 的展示名称为 `AgentCommander`，标准包 ID 为 `agent-commander`。 | 清单、目录和内含 Skill 使用统一名称。 | 保留旧包 ID 或显示名称造成双重身份。 | 用户明确要求重命名。 | 任一活动清单仍声明旧包 ID。 | user-confirmed-direct: “改为 AgentCommander” | active |
| PD3 | AgentCommander 支持 Claude Code 的只读委派和精确会话续接。 | 使用 Claude Code 的安全只读参数并保存其 session id。 | 使用危险权限跳过参数或“继续最近会话”。 | 用户明确要求加入 Claude Code 支持。 | provider 列表缺少 `claude-code`，或续接未使用明确 session id。 | user-confirmed-direct: “把 claude code 的支持也加入进去” | active |

## 12. Open Questions And Risks

- 写入权限、worktree 策略、并发和 marketplace 位置尚未获得直接确认。
- OpenCode 不同版本的 JSONL 完整性存在已知差异。
- 外部 Agent 的订阅、限流、模型和登录状态不由 Plugin 控制。
- Agent Plugins 已形成开放规范并被 Codex采用，但不能宣称所有 Agent 产品已统一支持。

## 13. Implementation Notes

- 首版使用无第三方运行依赖的 Python 标准库适配器。
- 根目录 `plugin.json` 表达可移植 Agent Plugin 包；`.codex-plugin/plugin.json` 保持 Codex 兼容。
- 只读限制通过后端自身安全默认、只读 agent 或工具白名单尽量强制；无法可靠限制的 DSH 首版不执行。
