---
name: coe-debug
description: Use this skill when debugging complex, multi-factor, or long-running bugs. It maintains a project-root /coe Markdown case file per bug case using a strict Chain-of-Evidence model with only 问题, 假设, and 证据 nodes.
---

# COE Debug

Use this skill when debugging a bug that may involve multiple layers, multiple causes, intermittent symptoms, long context, repeated failed attempts, or any risk of circular reasoning.

The purpose is to treat debugging like a case investigation: maintain a persistent evidence chain, separate hypotheses from facts, and avoid losing state when the conversation or code context becomes long.

## Core model

Every debug case is represented by one Markdown file under the project root:

```text
/coe/YYYY-MM-DD-HH-mm 简短bug描述.md
```

Example:

```text
/coe/2026-05-01-13-31 terminal 卡顿问题.md
```

Each case file contains exactly three node types:

1. `问题` — the unique root node of the case.
2. `假设` — a falsifiable explanation of the problem or a sub-cause.
3. `证据` — an actual observation, experiment result, log, code finding, config fact, or user confirmation used to support or refute a hypothesis.

A case file must contain exactly one `问题` node. It may contain zero or more `假设` nodes and zero or more `证据` nodes.

No other node type is allowed in case files. Do not create separate sections such as `日志`, `任务`, `行动`, `总结`, `时间线`, `计划`, `结论`, or `备注`. Put that information into fields inside one of the three allowed node types.

## Allowed states

### 问题 states

Only these values are valid:

- `open` — unresolved and still active.
- `fixed` — solved and validated by evidence.
- `closed` — no longer being pursued.

A `问题` node may be set to `fixed` only when at least one relevant `假设` has state `证实`, and there is validation evidence showing that the bug is actually resolved.

A code change, config change, or plausible explanation alone is not enough to mark the problem as `fixed`.

### 假设 states

Only these values are valid:

- `未验证` — proposed but not yet tested.
- `证实` — supported by concrete evidence and explains the relevant symptom or sub-cause.
- `证伪` — contradicted by concrete evidence.
- `block` — cannot currently be tested because required information, access, environment, reproduction, or dependency is missing.
- `closed` — intentionally no longer pursued, usually because it is superseded, irrelevant, or not worth further investigation.

Evidence nodes have no state. They are factual records.

## Case split and merge rule

When the user reports multiple bugs at the same time:

- Use one case file if the symptoms are highly correlated: same trigger, same execution path, same regression window, same error surface, same stack trace, same environment, or likely shared root cause.
- Create separate case files if the symptoms appear independent.
- If uncertain, start with one case only when there is a concrete suspected relation. Otherwise create separate cases.
- Do not put multiple unrelated root problems into one case file. One case file means one `问题` node.

If a later investigation proves that two cases share a root cause, keep both files but cross-reference the other case in a field inside the `问题` node. Do not add a fourth node type.

## Case document format

A valid case document uses this structure exactly:

```markdown
# 问题 P-001：<简短问题标题>
- 状态: open
- 创建时间: <YYYY-MM-DD HH:mm>
- 最后更新: <YYYY-MM-DD HH:mm>
- 问题目标: <本案要解决的唯一目标>
- 当前症状:
  - <观察到的现象>
- 期望行为:
  - <系统应该如何表现>
- 实际行为:
  - <系统现在如何表现>
- 影响范围:
  - <受影响功能、用户、环境、版本>
- 复现条件:
  - <复现步骤、输入、前置状态；未知则写“未知”>
- 环境信息:
  - <OS、运行时、版本、配置、分支、提交等；未知则写“未知”>
- 已知事实:
  - <已经被证据确认的事实；必须能追溯到证据节点>
- 排除项:
  - <已经被证伪假设排除的方向；必须能追溯到证据节点>
- 解决判据:
  - <什么证据出现后才允许把状态改为 fixed>
- 当前结论: <当前最稳妥的案件判断；不能超过证据支持范围>
- 关联假设:
  - H-001
- 解决依据:
  - <仅当状态为 fixed 时填写：H-xxx + E-xxx；否则写“未满足”>
- 关闭原因:
  - <仅当状态为 closed 时填写；否则写“未关闭”>

## 假设 H-001：<可验证命题短标题>
- 状态: 未验证
- 父节点: P-001
- 命题: <一个可以被证实或证伪的具体判断>
- 层级: root-cause | sub-cause | fix-validation | regression-window | environment | interaction
- 因素关系: single | all_of | any_of | part_of | unknown
- 依赖假设:
  - <H-xxx；没有则写“无”>
- 提出依据:
  - <来自问题描述、已有证据、代码结构或经验的理由；这是推理，不是证据>
- 可证伪预测:
  - 如果成立: <应该观察到什么>
  - 如果不成立: <应该观察不到什么，或会出现什么相反结果>
- 验证计划:
  - <下一步最小验证动作；优先选择能区分多个假设的实验>
- 关联证据:
  - <E-xxx；没有则写“无”>
- 结论: <未验证/证实/证伪/block/closed 的理由>
- 下一步: <继续验证、派生子假设、实施修复、等待用户信息、或停止>
- 阻塞原因:
  - <仅当状态为 block 时填写；否则写“无”>
- 关闭原因:
  - <仅当状态为 closed 时填写；否则写“未关闭”>

## 证据 E-001：<证据短标题>
- 关联假设:
  - H-001
- 方向: 支持 | 反驳 | 中性
- 类型: 观察 | 日志 | 实验 | 代码定位 | 配置 | 环境 | 用户反馈 | 修复验证
- 获取方式: <命令、文件路径、代码位置、截图说明、用户反馈来源等>
- 原始内容:
  ```text
  <粘贴关键输出、错误信息、代码片段、配置、复现结果；保持原始性>
  ```
- 判读: <这条证据如何影响关联假设；必须克制，不得超过原始内容>
- 时间: <YYYY-MM-DD HH:mm>
```

### Heading rule

Inside case documents, headings must match one of these forms only:

```text
# 问题 P-001：...
## 假设 H-001：...
## 证据 E-001：...
```

No other Markdown heading is valid in a case file.

### ID rule

- The problem node is always `P-001`.
- Hypothesis IDs are `H-001`, `H-002`, `H-003`, and so on.
- Evidence IDs are `E-001`, `E-002`, `E-003`, and so on.
- IDs are never reused.
- Do not renumber existing nodes.

## Workflow

### 1. Locate or create the case

Before debugging, inspect `/coe` in the project root.

- If a relevant `open` case already exists, update that file.
- If no relevant case exists, create a new Markdown file under `/coe` using the required timestamped filename.
- If `/coe` does not exist, create it.

The case document is the source of truth. Do not rely on conversation memory when a case file exists.

### 2. Normalize the problem

Create or update the single `问题` node.

The `问题目标` must be singular. If the user gave a broad complaint, rewrite it as one concrete debug target. Preserve the user's original symptoms under `当前症状`.

Do not mark the problem as `fixed` at creation time.

### 3. Generate hypotheses

Create hypotheses as falsifiable statements.

A good hypothesis has these properties:

- It explains at least one observed symptom.
- It predicts a concrete observation.
- It can be tested with a small action.
- It can be contradicted by evidence.

Bad hypotheses are vague labels such as “可能是环境问题”, “代码有 bug”, or “依赖有问题”. Rewrite them into testable statements.

For multi-layer issues, use `父节点` and `依赖假设` fields instead of creating new node types.

Example:

```text
H-001: 终端卡顿来自 shell 启动阶段
H-002: zsh 插件初始化阻塞导致 shell 启动阶段卡顿，父节点 H-001
H-003: nvm 自动加载导致 zsh 插件初始化阻塞，父节点 H-002
```

### 4. Choose the next evidence target

At any point, choose one active hypothesis as the current investigation target.

Prefer the hypothesis whose test is:

1. Most discriminating between competing hypotheses.
2. Cheapest to run.
3. Least destructive.
4. Most likely to unblock downstream hypotheses.

Before repeating a command, experiment, code search, or patch, check whether an equivalent evidence node already exists. Do not repeat the same loop unless something material changed.

### 5. Record evidence before changing conclusions

After each meaningful observation or experiment, add a `证据` node before changing hypothesis status.

Evidence must be concrete. It can be:

- command output,
- log text,
- stack trace,
- code location,
- config value,
- reproduction result,
- failed reproduction result,
- user confirmation,
- timing measurement,
- dependency/version fact,
- validation result after a fix.

Do not record pure speculation as evidence. Put speculation in `假设.提出依据` or `假设.结论`.

### 6. Update hypothesis status

A hypothesis may change state only after evidence is recorded.

- Set to `证实` when evidence supports the hypothesis and the hypothesis explains the relevant symptom or sub-cause.
- Set to `证伪` when evidence contradicts a required prediction.
- Set to `block` when the next verification step cannot proceed; record `阻塞原因` and the exact unblock condition.
- Set to `closed` when it is intentionally abandoned, superseded, or irrelevant; record `关闭原因`.

Do not treat absence of evidence as disproof unless the hypothesis explicitly predicted that evidence should appear under the tested conditions.

### 7. Apply fixes only after enough evidence

Prefer targeted fixes attached to confirmed or strongly supported hypotheses.

If a patch is exploratory, record that as evidence or as a hypothesis validation step. Do not present an exploratory patch as a confirmed fix until validation evidence exists.

### 8. Mark the problem fixed only after validation

The `问题` status may become `fixed` only when all are true:

1. At least one relevant hypothesis is `证实`.
2. The implemented change or discovered correction is tied to that hypothesis.
3. A `证据` node of type `修复验证` shows the original symptom no longer occurs under the stated reproduction conditions.
4. The `问题.解决依据` field lists the confirming hypothesis and validation evidence.

If the validation only covers part of the symptom, do not mark the problem `fixed`. Add a new hypothesis for the remaining symptom or split the case if it is independent.

### 9. Close without fixing only when appropriate

Set the `问题` status to `closed` only when the case is intentionally stopped, for example:

- user no longer wants to pursue it,
- bug is out of scope,
- required information cannot be obtained,
- reproduction is impossible and no productive path remains,
- the issue is accepted as known limitation.

Record the reason in `问题.关闭原因`.

## Response behavior while using this skill

When interacting with the user during a debugging case:

- Name the active case file when it is created or selected.
- State the active hypothesis being tested.
- State what evidence the next action is expected to produce.
- After a debug step, summarize only:
  - new evidence added,
  - hypothesis status changes,
  - problem status,
  - next hypothesis or blocker.

Do not dump the entire case file unless the user asks.

## Loop prevention rules

To avoid circular debugging:

- Never rerun the same check without explaining what changed.
- Never create a new hypothesis that is semantically identical to an existing active, disproven, or closed hypothesis.
- Never mark a hypothesis `证实` because it is plausible; require evidence.
- Never mark a problem `fixed` because a patch was applied; require validation evidence.
- When stuck, inspect the case file and choose between:
  - adding a discriminating hypothesis,
  - splitting the case,
  - marking a hypothesis `block`,
  - closing a dead branch.

## Case document maintenance rules

- The case file is append-friendly and evidence-preserving.
- Do not delete evidence nodes. If an earlier interpretation was wrong, add a new evidence node or update the hypothesis conclusion to explain the correction.
- Do not delete hypotheses. Mark them `证伪`, `closed`, or `block` as appropriate.
- Keep `问题.已知事实`, `问题.排除项`, `问题.当前结论`, and `问题.最后更新` synchronized after meaningful evidence.
- Keep raw evidence short but sufficient. Include exact file paths, line numbers, commands, and key outputs where possible.
- Use absolute or project-relative file paths consistently.

## Minimal case template

Use the file in `templates/case-template.md` or copy this skeleton into a new case file.

```markdown
# 问题 P-001：<简短问题标题>
- 状态: open
- 创建时间: <YYYY-MM-DD HH:mm>
- 最后更新: <YYYY-MM-DD HH:mm>
- 问题目标: <本案要解决的唯一目标>
- 当前症状:
  - <观察到的现象>
- 期望行为:
  - <系统应该如何表现>
- 实际行为:
  - <系统现在如何表现>
- 影响范围:
  - <受影响功能、用户、环境、版本>
- 复现条件:
  - <复现步骤、输入、前置状态；未知则写“未知”>
- 环境信息:
  - <OS、运行时、版本、配置、分支、提交等；未知则写“未知”>
- 已知事实:
  - <必须能追溯到证据节点；没有则写“无”>
- 排除项:
  - <必须能追溯到证据节点；没有则写“无”>
- 解决判据:
  - <什么证据出现后才允许把状态改为 fixed>
- 当前结论: <不能超过证据支持范围>
- 关联假设:
  - <H-xxx；没有则写“无”>
- 解决依据:
  - 未满足
- 关闭原因:
  - 未关闭
```
