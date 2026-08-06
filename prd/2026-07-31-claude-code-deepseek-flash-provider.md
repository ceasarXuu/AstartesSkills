# PRD：Claude Code + DeepSeek V4 Flash Profile

- Status: Ready for implementation
- Created: 2026-07-31
- Updated: 2026-08-07
- Owner / requester: ceasarXuu
- Source request: 新增 `claude-ds-flash`，将 Claude Code 主模型和子代理模型全部切换为 DeepSeek V4 Flash。

## Requester Review Summary

- Key decisions: 保留现有 `claude-ds`；新增独立 `claude-ds-flash`；所有 Claude 模型映射和子代理模型均为 `deepseek-v4-flash`；两个 DeepSeek 专用入口默认启用 `--dangerously-skip-permissions`，并固定关闭非必要流量、按 70 万 token 有效窗口计算自动压缩。
- Important exceptions: 该 profile 是用户指定的全 Flash 变体，不替代 DeepSeek 官方推荐的 Pro 主模型配置。
- Must-confirm before implementation: 无阻塞项。
- Status reason: 命令名、模型选择、共存关系和本机实测目标均已明确。

## 1. Background And Product Intent

现有 `claude-ds` 使用 V4 Pro 作为主模型、V4 Flash 作为快速和子代理模型。用户需要一个响应更快、成本边界更统一的独立入口，让主会话和子代理都固定使用 V4 Flash。

## 2. Goals And Success Criteria

- 安装后同时保留 `claude-ds` 与 `claude-ds-flash`。
- `claude-ds-flash` 的主模型、Opus/Sonnet/Haiku 映射和子代理模型全部是 `deepseek-v4-flash`。
- 两个 profile 使用独立 settings，互不覆盖。
- 新 profile 可安全复用同一 DeepSeek Provider 的已有 Key。
- 完成离线安装、参数透传、mock 请求、真实最小请求和 OAuth 隔离验证。

## 3. Users And Usage Context

目标用户是已使用 `claude-ds`，并希望通过单独命令选择全 Flash 运行模式的开发者。

## 4. Scope

### In Scope

- macOS/Linux Claude Code CLI。
- 独立 `claude-ds-flash` launcher 和 settings。
- V4 Flash 全模型映射。
- 同 Provider credential 复用、备份、回滚与验证。

### Out Of Scope

- 修改或删除现有 `claude-ds`。
- 改写 Claude Code 全局 settings 或 OAuth 存储。
- 自动选择 Pro/Flash 或根据任务动态路由。
- Windows PowerShell launcher。

## 5. Core User Journey

1. 用户安装 `claude-code-deepseek-flash` package。
2. 安装器创建独立 Flash settings 和 `claude-ds-flash`。
3. 如果已有 `claude-ds` 的真实 DeepSeek Key，安装器在不打印 Key 的前提下复用；否则打开 Flash settings 供填写。
4. 用户执行 `claude-ds-flash`，所有模型路径均使用 V4 Flash。
5. 用户仍可执行 `claude-ds` 使用原 Pro/Flash 混合 profile。

## 6. Interaction And Information Design

- 启动日志明确显示 `model=deepseek-v4-flash`、`fast_model=deepseek-v4-flash` 和 `mode=yolo`。
- 安装日志区分 `import credential=sibling-profile`、`preserve`、`create`、`unchanged` 和 `backup`，不输出凭据。
- 缺 Key 时自动打开对应 Flash settings；自动化可禁用编辑器。

## 7. Product Rules And State Logic

- Flash profile id：`claude-code-deepseek-flash`。
- settings：`~/.claude/provider-switch/deepseek-flash.settings.json`。
- launcher：`~/.local/bin/claude-ds-flash`。
- 所有 `ANTHROPIC_*_MODEL` 和 `CLAUDE_CODE_SUBAGENT_MODEL` 均为 `deepseek-v4-flash`。
- 专用 settings 固定包含 `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` 与 `CLAUDE_CODE_AUTO_COMPACT_WINDOW=700000`。
- 目标 profile 已有 Key 优先，其次复用同 Provider 兄弟 profile Key，再次读取显式环境变量，最后保留占位符。

## 8. Edge Cases, Errors, And Recovery

- 兄弟 profile 缺失或只有占位符：不视为错误，进入正常填 Key 流程。
- Flash settings 已有真实 Key：更新时优先保留自身 Key。
- 任一现有 settings JSON 无效：只在需要读取该文件时报告错误，不修改目标文件。
- 回滚只需恢复备份或安全移走 Flash profile 的两个新增文件，不影响 `claude-ds`。

## 9. Content And Terminology

- 展示名称：Claude Code + DeepSeek V4 Flash
- 命令：`claude-ds-flash`
- 主模型：`deepseek-v4-flash`
- 快速模型：`deepseek-v4-flash`
- 子代理模型：`deepseek-v4-flash`

## 10. Acceptance Criteria

- Given 已有 `claude-ds`，when 安装 Flash profile，then 原命令和 settings 不变，新命令与新 settings 被创建。
- Given Pro profile 存在真实 Key，when 首次安装 Flash profile，then Key 被安全复用且日志不含其值。
- Given 执行 `claude-ds-flash`，when Claude Code 发起请求，then传输模型为 `deepseek-v4-flash`，且不请求扩展上下文 beta。
- Given 参数包含空格，when 通过 Flash launcher 传递，then 默认追加 `--dangerously-skip-permissions`，且参数边界和顺序不变。
- Given 安装或升级 Flash profile，when 读取其 settings，then 两个上下文保护变量均以指定字符串值存在。
- Given mock 与真实最小请求结束，when 查询 `claude auth status`，then claude.ai OAuth 仍为 first-party。

## 11. Review Checklist And Sign-off Questions

- `claude-ds` 与 `claude-ds-flash` 是否能清晰区分？
- 全部模型字段是否均为 Flash，且没有残留 Pro 映射？
- Key 复用是否只发生在同一个 DeepSeek Provider 内？

## 12. Clarification Decision Log

| Topic | Decision | Rationale | Source Round |
|---|---|---|---|
| 共存关系 | 新增命令，不替换旧命令 | 用户明确要求“新建” | 初始请求 |
| 模型范围 | 主模型与所有子/别名模型均为 Flash | 用户明确要求全部改为 V4 Flash | 初始请求 |
| Credential | 复用同 Provider 已有 Key | 减少重复配置且不扩大 Provider 边界 | 实现前需求固化 |
| 上下文保护 | 非必要流量设为 `1`，自动压缩有效窗口设为 `700000` | 降低长会话接近上下文上限时的不可用风险 | 2026-08-07 追加需求 |

## 13. Open Questions And Risks

- DeepSeek 官方示例仍推荐主模型使用 V4 Pro；全 Flash profile 的复杂任务质量与 Pro profile 可能不同。
- 模型名称和 Claude Code 环境变量可能变化，需要用 mock 与真实请求持续验证。

## 14. Implementation Notes

- 两个 profile 共享安装、备份、日志和 mock 验证代码，profile 差异由声明式配置承载。
- 真实烟测使用固定无业务提示词、无工具、单轮、无会话持久化和预算上限。
