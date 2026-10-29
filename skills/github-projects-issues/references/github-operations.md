# GitHub 操作参考

## 示例设计的已验证事实

2026-10-30 通过已认证 GitHub GraphQL 和 `gh project field-list` 读取：

- Project：`ceasarXuu` 用户名下 #5，标题 `doumen-issues`。
- view #6：`v1.5.2`，`BOARD_LAYOUT`，filter 为 `milestone:1.5.2`，`verticalGroupByFields` 为 Status。
- 显示字段：Title、Assignees、Status、Labels、Linked pull requests、Milestone。
- Status 选项：TODO、In Progress、In Review、Done。
- 另有 All Issues 表格、待定需求 Board（`milestone:Backlog（未定版本）`）及其他版本 Board。

这些是结构参考，不是固定版本、项目归属、字段 ID 或复制业务内容的要求。复用目标 Project 时以实时读取为准。

## 工具路径

优先使用连接的 GitHub 工具。若其不支持 Projects，用本机已认证 `gh`；需要设置视图而 CLI 无对应命令时，查询当前官方 GraphQL schema 或使用可用的浏览器控制。不要臆造命令或 mutation。无权限时报告所需访问，继续能执行的本地准备，不把未配置的视图说成已完成。

官方入口：

- [gh project](https://cli.github.com/manual/gh_project)
- [Projects API](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects)
- [内置自动化](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-built-in-automations)

GitHub 内置 workflows 可以将已关闭 issue 标为 Done，也可以配置其他同步，但要检查目标项目实际是否启用。不要依赖默认值或让自动关闭绕过交付标准。

## 常用操作骨架

变量均为目标仓库现场读取的值；先查 `--help` 核对当前 CLI 支持。使用明确的 `--repo`，避免在错误仓库写入。

```bash
gh repo view --json nameWithOwner,url
gh project list --owner "$project_owner" --format json
gh project view "$project_number" --owner "$project_owner" --format json
gh project field-list "$project_number" --owner "$project_owner" --format json
gh issue view "$issue_number" --repo "$repo" --json number,title,body,state,labels,milestone,assignees,projectItems,url
gh label list --repo "$repo" --limit 100
```

列表可能分页；使用工具支持的分页参数或 GraphQL cursor，不能因第一页没找到就新建。Project owner 可能是组织，GraphQL 应选择 `organization` 或 `user`，不硬编码用户名。

以下为按任务选用的写入操作，不是整批执行脚本：

```bash
# 确认没有可复用绑定后创建；Project 默认保留原有可见性策略。
gh project create --owner "$project_owner" --title "$project_title" --format json
gh project link "$project_number" --owner "$project_owner" --repo "$repo"
# body_file 使用真实换行；标签先读取，缺少才创建。
gh issue create --repo "$repo" --title "$issue_title" --body-file "$body_file"
gh project item-add "$project_number" --owner "$project_owner" --url "$issue_url" --format json
gh project item-edit --id "$item_id" --project-id "$project_id" --field-id "$status_field_id" --single-select-option-id "$status_option_id"
# 仅在交付条件已满足时关闭。
gh issue close "$issue_number" --repo "$repo" --reason completed
```

Project number、Project node ID、issue node ID、item ID、field ID 和 option ID 互不通用。`item-add` 返回的 item ID 用于 `item-edit`；Status option ID 从目标字段实时获取。已加入时复用 item，不重复添加。标签描述区分 bug 与需求的评级含义；调整优先级使用精准 add/remove，不覆盖整个 labels 列表。

回读 issue state 与 Project item 的 Status。关闭成功而状态更新失败时，只补 Project 更新；创建成功但响应丢失时先查找再重试。遇权限、认证或 API 能力问题停止该写入链并说明具体缺项，不循环重试。
