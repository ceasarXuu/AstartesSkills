# PRD：Claude Code + DeepSeek Provider Package

- Status: Ready for implementation
- Created: 2026-07-31
- Updated: 2026-07-31
- Owner / requester: ceasarXuu
- Source request: 参考 DeepSeek 官方 Claude Code 接入文档，在 `provider-switch` 中新增可在本机验证的 Claude Code + DeepSeek 方案。

## Requester Review Summary

- Key decisions: 作为独立临时配置安装；通过专用 `--settings` 文件和 `claude-ds` 启动器生效；不修改 Claude Code 全局配置和登录状态；缺少 API Key 时安装完成后自动打开配置；专用入口默认启用 `--dangerously-skip-permissions`。
- Important exceptions: 真实请求会向 DeepSeek 发送提示词并产生 Token 费用；默认测试先覆盖离线与本地 mock，真实烟测仅在本机已有凭据时执行最小请求。
- Must-confirm before implementation: 无阻塞项；请求已明确指定官方方案、收纳位置和本机实测。
- Status reason: 用户目标、范围、安全边界和验收方式均已明确。

## 1. Background And Product Intent

`provider-switch` 已支持 Codex + DeepSeek，但尚无 Claude Code + DeepSeek 组合。使用者需要在保留 Claude Code 原有 claude.ai 登录和配置的前提下，通过一个明确命令临时使用 DeepSeek。

## 2. Goals And Success Criteria

- 新增可发现、可安装、可更新、可回滚的 `claude-code-deepseek` catalog 条目。
- 安装后通过 `claude-ds` 启动 DeepSeek 会话，不影响普通 `claude` 命令。
- 保留已有非占位 DeepSeek API Key，日志不输出密钥。
- 完成安装幂等性、失败原子性、参数透传、本地 mock 请求和登录状态回归验证。

## 3. Users And Usage Context

目标用户是已经安装 Claude Code，希望在同一台机器上临时使用 DeepSeek、同时继续保留 claude.ai OAuth 登录的开发者。

## 4. Scope

### In Scope

- macOS/Linux Claude Code CLI。
- DeepSeek Anthropic 兼容端点。
- DeepSeek V4 Pro、V4 Flash 及子代理模型映射。
- 独立 settings、启动器、安装器、备份、恢复和测试说明。

### Out Of Scope

- 修改全局 `~/.claude/settings.json`。
- Windows PowerShell 启动器。
- 自动创建或购买 DeepSeek API Key。
- 将 Anthropic 官方支持承诺扩展到非 Claude 模型。

## 5. Core User Journey

1. 用户选择 `claude-code-deepseek` 组合并阅读对应 reference。
2. 用户运行确定性安装器。
3. 安装器检查 Claude Code 版本，创建专用 settings 和 `claude-ds`，必要时备份旧文件并保留已有密钥。
4. 如果仍缺少 DeepSeek API Key，安装器自动打开专用配置，用户填入 Key；也可提前通过环境变量提供。
5. 用户运行 `claude-ds`；普通 `claude` 仍使用原配置和登录。
6. 用户可根据备份恢复或移走新增文件完成回滚。

## 6. Interaction And Information Design

- 所有操作日志使用 `[provider-switch]` 前缀和稳定 action 名称。
- 启动日志只显示 Agent、Provider、模型、scope 和认证边界，不显示凭据。
- 缺少 CLI、配置或密钥时给出可执行错误提示并返回非零状态。

## 7. Product Rules And State Logic

- 默认 scope 为 `temporary-profile`。
- 专用 credential 替代当前进程中的 claude.ai 订阅认证，但不得删除或改写已保存登录。
- 更新托管文件前必须创建可恢复备份；同内容重复安装不得制造备份噪声。
- `claude-ds` 默认启用 Claude Code bypass permissions，并在启动日志中显示 `mode=yolo`；普通 `claude` 不受影响。
- 专用配置仍含 Key 占位符时默认打开编辑器；已有真实 Key 时不打开；自动化可显式禁用打开动作。

## 8. Edge Cases, Errors, And Recovery

- Claude Code 版本不满足最低已验证版本：安装前停止。
- settings JSON 无效：安装前停止或启动时报错，不触碰全局配置。
- 已有真实密钥：更新时保留且不得进入日志。
- 文件内容变化：备份后原子替换。
- mock 或真实请求失败：保留诊断证据，并再次确认 Claude 登录状态未变化。

## 9. Content And Terminology

- 组合 id：`claude-code-deepseek`
- 启动命令：`claude-ds`
- 主模型：`deepseek-v4-pro[1m]`
- 快速/子代理模型：`deepseek-v4-flash`

## 10. Acceptance Criteria

- Given 已安装受支持版本 Claude Code，when 首次运行安装器，then 专用 settings 与启动器以限制性权限创建。
- Given 已存在真实 DeepSeek Key，when 再次安装，then 密钥被保留且日志不包含密钥。
- Given 安装输入不变，when 重复安装，then 文件报告 `unchanged` 且不创建新备份。
- Given 启动器接收包含空格的参数，when 调用 `claude-ds`，then 默认追加 `--dangerously-skip-permissions`，且用户参数边界和顺序保持不变。
- Given 首次安装后配置仍是 Key 占位符，when 安装完成，then 自动打开专用配置文件，且 `complete` 日志先于打开动作。
- Given 已有真实 Key 或传入 `--no-open-editor`，when 安装完成，then 不启动编辑器。
- Given 本地 Anthropic 协议 mock，when Claude Code 发起最小请求，then mock 收到带认证的 Messages API 请求且响应成功。
- Given 测试前存在 claude.ai OAuth 登录，when mock 和真实烟测结束，then `claude auth status` 仍为已登录且 provider 为 first-party。

## 11. Review Checklist And Sign-off Questions

- 启动命令是否清晰区分于普通 `claude`？
- 回滚是否无需重新登录 Claude Code？
- 真实烟测是否只发送无仓库内容的最小提示词？

## 12. Clarification Decision Log

| Topic | Decision | Rationale | Source Round |
|---|---|---|---|
| 配置范围 | 独立临时 settings | 避免污染全局 Claude 配置 | 初始请求与现有 skill 契约 |
| 权限模式 | 保留默认审批 | DeepSeek 官方方案未要求 YOLO | 官方文档核验 |
| 测试边界 | 离线 + mock + 最小真实请求 | 同时覆盖可重复回归与真实兼容性 | 本机实测要求 |

## 13. Open Questions And Risks

- Anthropic 官方不支持通过 gateway 运行非 Claude 模型；该组合依赖 DeepSeek 提供的 Anthropic 协议兼容层。
- Claude Code 和 DeepSeek 的环境变量、模型名与协议可能变化，每次安装前需重新核对官方文档。

## 14. Implementation Notes

- 所有 credential 文件使用 `0600`，启动器使用 `0755`。
- 真实烟测提示词不得包含仓库源码或用户数据，并设置最低可行预算上限。
