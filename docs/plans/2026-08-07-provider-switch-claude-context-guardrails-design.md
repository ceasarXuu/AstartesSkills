# Provider Switch：Claude 上下文保护配置设计

- 状态：Implemented
- 日期：2026-08-07
- 范围：`claude-ds` 与 `claude-ds-flash` 专用 settings

## 背景与决策

Claude Code 在上下文窗口接近上限时会自动压缩；若压缩触发过晚，可能出现 `Prompt is too long` 或压缩失败，使当前 session 难以继续。两个 DeepSeek profile 均通过独立 `--settings` 文件注入环境变量，因此将保护项写入各自的 `env`，不修改普通 `claude`、全局 settings 或 shell 环境。

固定配置如下：

```json
"CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
"CLAUDE_CODE_AUTO_COMPACT_WINDOW": "700000"
```

`CLAUDE_CODE_AUTO_COMPACT_WINDOW` 将自动压缩计算使用的有效容量设为 70 万 token。对于 1M 上下文模型，这会比按完整窗口计算更早预留压缩空间，从而降低接近极限时 session 不可用的风险；它不能保证消除所有超长提示、超大附件或压缩失败。`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1` 继续阻止自动更新、反馈、错误报告和遥测等非必要流量。

## 方案比较

- 专用 settings `env`：推荐。配置可见、随 profile 安装和备份、不会污染普通 Claude。
- launcher 内 `export`：能生效，但配置散落在 shell 模板中，不利于用户检查 settings。
- 全局 shell 或 `~/.claude/settings.json`：覆盖范围过大，会改变普通 Claude 行为，不符合临时 profile 契约。

## 验证

1. 测试先要求两个资产均包含准确字符串值，并观察因缺少自动压缩窗口而失败。
2. 更新两个 settings 资产后运行专项 sanity，验证首次安装、凭据保留、幂等更新和全局配置隔离。
3. 本机重装两个 profile，确认已安装 settings 包含固定值且 API Key 仍被保留。
4. 运行仓库 smoke test 与全仓校验。
