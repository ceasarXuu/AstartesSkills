# Provider Switch Skill 设计记录

- Status: Ready for implementation
- Created: 2026-07-31
- Updated: 2026-07-31
- Owner / requester: user
- Source request: 创建 `provider-switch` skill，在 AstartesSkills 中统一收纳和维护多个 Agent 与 Provider 的配置，并以 Codex 接入 DeepSeek 为首个实例。

## Requester Review Summary

- Key decisions:
  - 新增可安装的 `provider-switch` skill，不把能力限定为 Codex 或 DeepSeek。
  - 用统一 catalog 发现已维护的 Agent/Provider 组合。
  - 把跨 Provider 的工作流保留在 `SKILL.md`，把具体组合拆到独立 reference 和脚本。
  - 首个组合为 `codex-deepseek-flash`，复用已验证的临时侧载和 provider Bearer 鉴权经验。
  - 默认保护现有 Agent 全局登录、主配置和密钥，不允许切换动作静默登出或打印 secret。
- Important exceptions:
  - 只有用户明确要求永久切换时，才允许修改 Agent 的默认全局配置。
  - Provider 官方配置与 Agent CLI 行为会变化，执行前必须核对官方文档和本机版本。
- Must-confirm before implementation:
  - None. 用户已明确 skill 名称、仓库、扩展方向和首个配置实例。
- Status reason:
  - 核心用户旅程、边界、安全规则和验收标准已足够实施。

## 1. Background And Product Intent

不同 Agent 对 Provider、认证、模型目录和临时 profile 的配置方式不同。零散的一次性命令容易污染主配置、覆盖密钥或破坏原有登录状态。`provider-switch` 应把这些高风险操作收敛为可发现、可验证、可回滚的维护流程。

## 2. Goals And Success Criteria

- 让用户能用统一入口新增、检查、安装、更新和切换 Agent/Provider 组合。
- 让每个组合拥有独立说明、配置资产或确定性脚本，不把所有变体塞进一个长文件。
- 默认使用临时侧载或命名 profile，退出进程后恢复原 Agent/Provider 行为。
- 所有写操作均保护 secret、备份被替换文件，并提供验证信号。
- Codex + DeepSeek Flash 组合可完成安装、参数转发、YOLO 启动和登录隔离验证。

## 3. Users And Usage Context

- 主要用户：在同一台机器上使用多个 coding Agent 和模型 Provider 的开发者。
- 典型场景：临时试用另一 Provider、维护多个模型入口、更新 Provider 配置、排查切换后的认证或协议问题。

## 4. Scope

### In Scope

- `skills/provider-switch` 安装包、UI 元数据和市场发布元数据。
- Agent/Provider catalog 与新增组合的维护规范。
- Codex + DeepSeek Flash 的参考说明和安全安装脚本。
- registry、README、专项 sanity、安装/导出/仓库回归测试。
- 可复用运行经验写入 `docs/runbooks/operational-notes.md`。

### Out Of Scope

- 首版一次性实现所有 Agent 或 Provider。
- 托管真实 API Key、账号凭据或机器专属绝对路径。
- 替用户永久切换默认 Provider，除非请求明确授权。
- 绕过 Provider 协议不兼容或伪造未被官方支持的模型能力。

## 5. Core User Journey

1. 用户指定 Agent、Provider、模型和临时或永久作用域。
2. Skill 从 catalog 选择现有组合；不存在时按扩展契约新增组合。
3. 执行前检查官方文档、本机 CLI 版本、现有配置和登录状态。
4. 预览将创建或更新的文件、命令和安全影响。
5. 安装或更新侧载配置；冲突文件先备份，已有 secret 默认保留。
6. 运行静态、mock、参数转发和登录状态回归。
7. 返回启动命令、验证证据、回滚位置和剩余风险。

## 6. Interaction And Information Design

- catalog 用稳定 id 标识组合，例如 `codex-deepseek-flash`。
- 每个组合提供用途、支持范围、reference 和 installer 路径。
- 安装脚本使用稳定日志前缀 `[provider-switch]`，输出动作、目标和验证状态，不输出 secret。
- 失败时给出具体恢复动作，不做静默 fallback。

## 7. Product Rules And State Logic

- 默认临时侧载；永久改动必须获得明确授权。
- 不可将 Agent 的全局登录策略混入 Provider profile。
- Provider 自有 Bearer/API Key 与 Agent 自身账号登录必须保持独立。
- 写入前区分新建、幂等、更新和冲突；更新时创建可恢复备份。
- 不覆盖非占位 secret；日志、测试和提交中不得出现 secret。
- 只使用官方支持的协议、模型和最低客户端版本。

## 8. Edge Cases, Errors, And Recovery

- CLI 缺失或版本过低：停止并报告最低版本要求。
- 官方模型目录格式变化：校验失败即停止，不写入目标文件。
- 目标文件已存在：内容相同则幂等跳过；内容不同则备份后更新；配置中的已有 Key 保留。
- wrapper 不在 `PATH`：报告安装目录与 PATH 修复建议。
- 登录状态变化：视为回归失败，恢复配置并要求重新登录。
- API 请求失败：区分认证、余额、协议、限速和网络错误，不把失败归结为统一“配置错误”。

## 9. Content And Terminology

- Agent：消费模型能力的客户端工具，例如 Codex CLI。
- Provider：提供模型 API 的服务，例如 DeepSeek。
- Profile / side-load：仅在指定启动命令中叠加的临时配置。
- Global config：Agent 的默认全局配置，不应被临时切换污染。

## 10. Acceptance Criteria

- Given 用户安装 `provider-switch`，when Agent 读取 skill，then 能从 catalog 发现 `codex-deepseek-flash` 及其 reference/installer。
- Given 已有 Codex 主配置和 ChatGPT 登录，when 安装并启动 DeepSeek profile，then 主配置不被修改、ChatGPT 登录不被清除。
- Given 配置中已有真实 DeepSeek Key，when 再次更新，then Key 被保留且不会出现在日志或 Git diff。
- Given 官方模型目录下载异常或结构不合法，when 执行安装，then 目标文件不发生部分写入。
- Given wrapper 接收附加参数，when 启动，then profile、YOLO 和所有用户参数按原边界传给 Codex。
- Given 新增另一个 Agent/Provider，when 维护者按扩展契约添加 catalog、reference、脚本和测试，then 无需重写核心 Skill 工作流。
- `quick_validate.py`、专项 sanity、`test-repo.sh provider-switch`、`validate-repo.sh` 和 marketplace export 全部通过。

## 11. Review Checklist And Sign-off Questions

- catalog 是否保持可扩展而非 DeepSeek 专用？
- 安装器是否默认保护主配置、登录状态和已有 Key？
- 验证是否覆盖失败原子性、幂等更新、参数转发和认证隔离？

## 12. Clarification Decision Log

| Topic | Decision | Rationale | Source Round |
|---|---|---|---|
| Skill id | `provider-switch` | 用户明确指定 | Initial request |
| Repository | AstartesSkills | 用户明确指定并要求推送 | Initial request |
| Architecture | 核心工作流 + catalog + provider reference/script | 支持多个 Agent/Provider，控制上下文体积 | Initial request + skill-creator |
| First provider | Codex + DeepSeek Flash | 复用本次已验证案例 | Initial request |
| Default scope | 临时侧载 | 避免污染现有 Agent 使用体验 | Confirmed experience |
| Auth boundary | Provider Key 与 Agent 登录隔离 | 避免 `forced_login_method` 触发全局登出 | Confirmed experience |

## 13. Open Questions And Risks

- 不同 Agent 的侧载能力差异较大，新增组合时必须逐项核对官方能力，不能假定 Codex 模式通用。
- DeepSeek 官方模型目录可能随版本更新，安装器需要结构校验并在格式变化时安全失败。

## 14. Implementation Notes

- docs 使用中文；skill 指令使用简洁英文以适配兼容 Agent。
- 不在仓库中保存真实 Key、生成后的机器配置或用户绝对路径。
