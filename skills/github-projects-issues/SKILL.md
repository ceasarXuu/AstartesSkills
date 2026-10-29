---
name: github-projects-issues
description: Manage GitHub Projects and issues together, including repository project binding, version boards, P0–P3 triage, minimal issue writing, session titles, and active status and closure synchronization. Use when setting up issue tracking or working on a GitHub issue.
---

# GitHub Projects 与 Issues 协作

围绕当前仓库管理一个明确绑定的 GitHub Project，让 issue、版本看板和 agent 会话反映真实工作状态。遵循用户已有的仓库、测试和发布权限；加载 skill 不代表获得无关外部操作授权。

## 建立或复用 Project

1. 从远端确定 `owner/repo`，读取仓库约定、已关联 Projects 和当前 issue；不要仅凭目录名确定仓库。优先用已连接 GitHub 工具，能力不足时使用已认证的 `gh` / GraphQL。
2. 默认每个 GitHub 仓库有一个用于 issue 协作的 Project。已有明确绑定则复用；有多个候选或用户提到现成 Project 时，询问要绑定哪个。尚无绑定时可以简短询问是否有现成 Project；用户已要求创建或明确没有现成的，直接创建并关联仓库。不要重复创建，也不要默认改造其他仓库共用的 Project。
3. 新建遵循下述结构；已有项目先映射等价字段和状态，保留用户配置。需要改变共享字段语义或迁移现有工作流时先确认。
4. 将最终 Project URL、owner/number 和必要的状态映射记录到仓库已有协作配置或约定文档中，避免下次重新猜测。只维护当前仓库的绑定。

## 看板规范

参考已读取的 [示例视图](https://github.com/users/ceasarXuu/projects/5/views/6)。详细证据、操作方法和工具限制见 [references/github-operations.md](references/github-operations.md)，设置 Project 或操作 API 时读取。

- Status：`TODO` → `In Progress` → `In Review` → `Done`。含义依次为待做、正在处理、等待审查或合并、已完成。
- `All Issues`：表格总览，不限定 milestone；共用项目则加当前仓库过滤。
- `待定需求`：按 Status 分列的 Board，筛选未定版本的 Backlog milestone。
- 版本视图：按 Status 分列的 Board，按对应 milestone 的实际名称筛选。只为已确定的版本创建，不照搬示例中的版本号。
- 主要字段：Title、Assignees、Status、Labels、Linked pull requests、Milestone。GitHub 已有的 Created、Updated、Closed 等字段不另造副本。
- milestone 表示版本；Labels 表示类型和优先级；Status 表示进度。不为同一概念额外创建重复自定义字段。
- 未明确版本的事项不擅自承诺发布日期或塞进当前版本；待定需求放 Backlog。P0 bug 应进入最近可交付修复版本，具体版本不明确时尽快确认。

## 标签与优先级

先读现有 labels；复用语义一致的标签，缺少才创建。最小集合为类型 `bug`、`enhancement`（需求）和互斥的 `P0`、`P1`、`P2`、`P3`。可按需补 `needs-info`（缺少关键事实）、`blocked`（受阻），不要预建庞大分类。颜色建议：P0 `B60205`、P1 `D93F0B`、P2 `FBCA04`、P3 `D4C5F9`。标签 description 应概括下表，不能只有颜色。

| 优先级 | Bug | 需求 |
| --- | --- | --- |
| P0 | 有重大影响，应在最近版本立刻修复 | 影响范围和后果重大，用户收益范围和程度明显 |
| P1 | 影响范围较小或后果可承受，用户可自行解决或暂时忍耐 | 小范围用户或场景受益的甜点 |
| P2 | 影响范围和后果很小，或较低概率发生，可延后处理 | 极低频场景甜点 |
| P3 | 可做可不做，待讨论 | 可做可不做，待讨论 |

Bug 综合影响范围、概率、后果和自救能力判断；低概率不能单独抵消重大不可逆后果。需求按用户收益判断，不按开发难度评级。事实不足时先补信息，不机械默认 P2/P3。每个 issue 至多一个优先级；调整时只替换优先级标签，保留无关标签。已有明确优先级不得无说明覆盖，出现新证据时简短说明调整依据。P3 是价值待讨论，不等于信息不足或工作受阻。

## 最简 issue 内容

先搜索现有 issue，更新或复用同一问题，避免重复。标题直接写问题或期望行为，不堆类型、版本和优先级前缀。内容沿用用户语言，只写必要事实；不要自行扩展范围、解决方案、背景、时间、负责人、状态、优先级或其他 GitHub 已有字段。

Bug 必填四项；触发项同时包含条件和概率：

```markdown
- 影响范围：哪些用户、场景或功能受影响
- 触发与概率：最短触发条件；必现/约 X%/偶发（依据）
- 后果严重度：触发后具体发生什么、损失或阻断程度
- 用户能否自行解除：能/不能；能时写最短恢复办法
```

不得猜测概率、影响范围或恢复办法。先从描述、日志和现有证据补齐；缺失则集中问缺少的事实。必须先登记时写“待确认”，加 `needs-info` 并明确尚未完成必填信息，不把“待确认”当作有效答案。用户未授权的复现、重型测试不自动执行。日志或附件仅在说明问题确有必要时补一条链接，不默认增加章节。

需求默认仅两项：

```markdown
- 期望行为：谁在什么场景下希望做到什么
- 完成标准：一个可观察、可判断是否实现的结果
```

已有正文只做必要补充，保留用户提供的有效信息。用户另有模板或明确要求时遵循，不强制套模板增加噪声。

## 处理 issue 的会话与状态闭环

- 开始处理时读取最新 issue、评论、关联 PR、Project item 和当前状态。立即将当前会话标题设为 `[#123] 修复 xxx 问题`，后半部分使用 issue 实际标题，不改写 GitHub 标题。Codex 环境发现并使用 `set_thread_title`；其他环境使用对应会话工具。不可用则说明限制，不能声称已改名。切换主要 issue 时重新同步；同号跨仓库歧义时补仓库名。
- 新建或接收待办：确保 issue 已加入绑定 Project，设为 `TODO`，issue 保持 open。只对本次涉及的 issue 操作，不批量导入历史事项。
- 实际开始处理：主动设为 `In Progress`，issue 保持 open；仅阅读、分诊或规划不算已经开工。协作前检查负责人和近期活动，不抢占他人正在处理的事项。
- 等待 review / PR 合并：设为 `In Review`，保持 open。没有审查环节的任务无需制造一个审查步骤。
- 阻塞或暂停：保留真实阶段，必要时加 `blocked`，用简短评论写明具体阻塞和下一步。只有确实退回待办才改 `TODO`，不能因为会话结束就假装完成。
- 满足完成标准、相关授权验证通过且到达仓库要求的交付点后：主动关闭 issue（completed），同步 `Done`。有 PR 的仓库通常等合并；仅提交、推送或创建 PR 不等于完成。允许关联 PR 的 `Closes #123`，但必须回读确认实际关闭。
- 重开或确认回归：需要继续修复时重开 issue，恢复 `TODO` 或正在实际处理的 `In Progress`。已发布版本中的独立回归可按仓库约定建新 issue 并关联原项。
- 用户决定不做或确认重复：按 GitHub `not planned` 原因关闭，必要时仅附重复项链接；不声称已修复。沿用项目已有终止状态，没有时用 `Done` 表示已结束，并保留关闭原因。
- Issue open/closed 和 Project Status 是两份状态，不能假定互相同步。每次关键变更后分别回读；只修改绑定 Project 的 item。失败时报告哪一步成功、哪一步未成功，下次继续前重新读取，避免重复创建或错误关闭。

结束时简短给出 issue/Project 链接、真实状态、完成证据或阻塞。只在有实质进展、优先级变化或阻塞时评论，不为每个工具调用刷评论。不要把此次单纯创建 skill 的任务理解成批量创建真实 Projects/issues 的指令。
