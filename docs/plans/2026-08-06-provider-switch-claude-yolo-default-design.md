# Provider Switch：Claude 专用入口默认 YOLO 设计

- 状态：Implemented
- 日期：2026-08-06
- 范围：`provider-switch` 的 `claude-ds` 与 `claude-ds-flash`

## 背景与决策

用户要求 Claude Code 的两个 DeepSeek 专用入口默认追加 `--dangerously-skip-permissions`，行为与现有 `codex-ds-flash` 的 YOLO 启动方式一致。该参数等价于 Claude Code 的 `bypassPermissions` 模式，会跳过权限提示和安全检查。

采用共享 launcher 模板单点修改：两个 profile 仍由同一 `assets/claude-ds` 模板生成，因此无需在安装器或各 profile 中复制参数逻辑。普通 `claude` 命令、Claude 全局 settings、Provider settings、API Key 与 OAuth 存储均不改变。

## 用户可见行为

- `claude-ds` 默认执行 `claude --settings <Pro/Flash settings> --dangerously-skip-permissions ...`。
- `claude-ds-flash` 默认执行 `claude --settings <全 Flash settings> --dangerously-skip-permissions ...`。
- 启动日志将 `mode` 从 `default-permissions` 改为 `yolo`，让高风险状态在每次启动时可见。
- 不新增静默 fallback。若 Claude Code 因 root/sudo 或组织 managed settings 禁止 bypass，直接保留 CLI 错误。

## 风险边界

该模式会允许工具调用立即执行，也会放开 Claude Code 对 `.git`、`.claude` 等受保护路径的常规保护；它不能防止 prompt injection 或非预期操作。用户已经明确授权把它作为两个专用入口的默认行为。文档必须建议仅在可信工作区或隔离环境使用，并明确普通 `claude` 仍保留原权限策略。

## 测试设计

1. 静态断言共享模板的最终 `exec` 含该参数且日志为 `mode=yolo`。
2. 用 fake Claude 验证 Pro/Flash 两个生成后的 wrapper 都透传该参数。
3. 保持原有 settings 路径、模型映射、Key 隔离和参数顺序断言。
4. 在本机重装两个 profile，验证 wrapper 更新、settings 不变和 OAuth 状态不变。
5. 用 `--version` 验证真实 Claude CLI 接受参数；不发送额外模型请求。

## 验收标准

- 两个专用命令均默认进入 bypass permissions。
- 普通 `claude` 不受影响。
- 启动日志明确显示 YOLO。
- 专项回归、全仓校验和本机 CLI smoke 全部通过。
