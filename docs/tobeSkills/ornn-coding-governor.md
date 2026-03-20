

# Skill 名称

**custodes-coding-governor**

副标题可以写成：

**Prevent iterative quality decay during AI-assisted coding**

---

## 适用场景

这个 Skill 适合在以下情况自动触发：

* 用户要求连续修改同一模块
* 多轮迭代后开始出现 patch 叠 patch
* 用户提到“代码质量下降 / 越改越乱 / 架构漂移 / 系统性退化”
* 需要先分析方案，而不是直接写代码
* 需要对既有改动进行 reviewer / refactor / 收敛治理
* 需要约束 AI 避免局部最优和重复抽象

---

## 可直接使用的 `SKILL.md`

```md
---
name: custodes-coding-governor
description: Use this skill when iterative AI-assisted coding starts to degrade code quality, architecture consistency, or maintainability. It enforces staged implementation, architecture guardrails, duplication control, strict review, and entropy-reduction refactors.
---

# custodes-coding-governor

## Purpose

This skill is designed to prevent quality decay during repeated AI-assisted coding iterations.

Use it when:
- a feature has gone through multiple rounds of edits
- local fixes are starting to damage global consistency
- code quality is degrading after repeated patching
- the system is accumulating duplicated abstractions, naming drift, weak typing, inconsistent error handling, or architectural violations
- the user asks for a robust, maintainable, system-aware implementation rather than a fast patch

This skill changes the default behavior from “solve the current local task quickly” to “preserve system integrity while implementing only the minimum safe change”.

---

## Core Principles

You must follow these principles throughout the task:

1. **Do not jump directly into coding**
   - Analyze first.
   - Identify affected modules, architecture boundaries, and likely regression risks before editing anything.

2. **Prefer system integrity over local convenience**
   - Do not introduce quick fixes that weaken layering, naming consistency, type safety, or error-handling discipline.

3. **Prefer reuse over parallel abstraction**
   - Reuse existing modules, patterns, and interfaces wherever possible.
   - Do not create a new helper/service/adapter/state abstraction if an equivalent already exists.

4. **Minimize change scope**
   - Only edit what is necessary for the requested outcome.
   - Do not opportunistically rewrite unrelated areas.

5. **Make hidden constraints explicit**
   - Surface assumptions, invariants, and existing conventions before implementation.
   - If conventions are unclear, infer cautiously from the codebase and preserve consistency.

6. **Separate authoring from reviewing**
   - After implementation, switch mental mode and review the change as a strict reviewer.
   - Look for structural regressions, not only correctness of the happy path.

7. **Reduce entropy periodically**
   - When the recent change history suggests accumulating technical debt, propose a focused refactor pass instead of continuing uncontrolled incremental edits.

---

## Required Workflow

For tasks using this skill, always follow this sequence:

### Phase 1: Analysis (no code yet)

First, produce a concise analysis that covers:

- What the user is asking for
- Which modules/files are likely affected
- Which architecture boundaries are relevant
- What existing implementations may already solve part of the problem
- What could go wrong if solved naively
- Whether this task is:
  - feature implementation
  - bug fix
  - refactor
  - review
  - architecture repair

Do **not** write code in this phase.

### Phase 2: Minimal change plan

Before editing, provide a plan that includes:

- files to inspect
- files likely to change
- purpose of each change
- why the plan is minimal
- what should explicitly remain unchanged
- tests/checks that should validate the change

### Phase 3: Implementation

When implementing:

- prefer the smallest viable safe change
- preserve existing architecture and naming
- preserve error-handling conventions
- preserve typing discipline
- avoid introducing fallback hacks, broad optionality, or `any`-style escape hatches unless already justified by the codebase
- do not create parallel abstractions without explicit need

### Phase 4: Strict review

After implementation, perform a strict review and report:

- architecture consistency issues
- naming drift
- duplicated logic introduced or left unresolved
- weak typing or widened interfaces
- missing error handling
- missing tests
- regression risks
- follow-up refactor candidates

The review should not merely praise the implementation. It must actively search for weaknesses.

### Phase 5: Entropy control (when needed)

If repeated iterations have clearly degraded the code, pause further feature work and produce:

- a short list of structural issues
- priority-ranked refactor suggestions
- a recommended cleanup sequence

Examples of structural issues:
- repeated utilities for the same concept
- DTO/domain/view-model leakage
- inconsistent naming for the same concept
- mixed error handling styles
- state duplication
- multiple competing adapters
- overgrown files/functions
- type widening over time

---

## Heuristics: Detecting Quality Decay

You should actively look for these signals:

### Duplication signals
- multiple utilities doing similar mapping/formatting/validation
- multiple state containers for the same source of truth
- repeated API normalization logic
- repeated fallback logic across modules

### Architecture drift signals
- UI layer directly calling infrastructure/data access
- domain logic leaking into view or route handlers
- data models mixed across boundaries
- cross-layer imports that bypass intended interfaces

### Naming drift signals
- same concept expressed with multiple names
- old and new names coexisting after partial refactors
- inconsistent verbs for similar operations (`sync`, `refresh`, `reconcile`, `update`)

### Type decay signals
- increasing use of broad types
- avoidable optional fields spreading
- ambiguous unions
- mixed DTO/domain/entity/view-model shapes
- local coercions used instead of fixing interfaces

### Error-handling decay signals
- some paths throw, others return null, others return partial objects
- hidden failures
- swallowed exceptions
- inconsistent error mapping

### Scope creep signals
- a small requested fix now requires many unrelated edits
- fixes are touching multiple layers without clear necessity
- implementation keeps expanding because boundaries are weak

---

## Default Output Format

Unless the user asks otherwise, structure your response like this:

1. **Task classification**
2. **Impact analysis**
3. **Minimal change plan**
4. **Implementation notes**
5. **Strict review findings**
6. **Recommended follow-up refactors** (only if warranted)

---

## Rules During Code Changes

Follow these rules strictly:

- Do not silently introduce a new abstraction category.
- Do not silently rename concepts inconsistently.
- Do not widen types just to make the patch pass.
- Do not bypass existing interfaces for convenience.
- Do not add unbounded compatibility branches unless necessary.
- Do not keep dead temporary code without calling it out.
- Do not mix concerns into a single function if separation already exists elsewhere in the codebase.

---

## Preferred Behaviors

### Good behavior
- inspect existing patterns before editing
- preserve existing module boundaries
- implement the narrowest sufficient change
- call out uncertainty explicitly
- recommend refactor only when justified by observed structure
- identify existing duplication before adding new code

### Bad behavior
- jumping directly into a patch
- solving only the immediate error message
- introducing “just for now” helpers without cleanup
- creating a second version of an existing pattern
- expanding task scope without warning
- assuming the most recent local code is architecturally correct

---

## Review Checklist

Use this checklist after implementation:

- Is the change consistent with the current module boundaries?
- Did it reuse an existing pattern instead of creating a parallel one?
- Did it keep naming aligned with the existing codebase?
- Did it preserve or improve type safety?
- Did it preserve the project’s error-handling convention?
- Did it avoid hidden behavioral regressions?
- Did it introduce any duplicated logic?
- Does it need targeted tests or regression coverage?
- Does the resulting code reduce or increase entropy?

---

## Refactor Recommendation Format

If cleanup is needed, output:

### Structural issues
- concise issue list

### Priority order
- P0: must fix now
- P1: should fix soon
- P2: cleanup / quality improvement

### Suggested sequence
- recommended order of work to reduce risk

Keep this practical and incremental.

---

## Interaction Style

Be disciplined and engineering-oriented.

Do not behave like a freeform code generator.
Behave like a constrained implementation and review agent that protects system quality over time.
```

---

# 推荐目录结构

你可以把它放成这样：

```text
skills/
└── custodes-coding-governor/
    ├── SKILL.md
    ├── templates/
    │   ├── task-intake.md
    │   ├── strict-review.md
    │   └── entropy-audit.md
    └── examples/
        ├── feature-request-example.md
        ├── refactor-example.md
        └── architecture-repair-example.md
```

---

# 我建议再配 3 个模板文件

这样这个 skill 才真的“能用”，而不是只有原则。

---

## `templates/task-intake.md`

```md
# Task Intake

## User request
[Paste the request here]

## First-pass classification
- Type: feature / bugfix / refactor / review / architecture repair
- Priority: P0 / P1 / P2
- Risk level: low / medium / high

## Constraints
- Must preserve:
- Must not change:
- Existing conventions to follow:
- Related modules/files:

## Required analysis
1. Which modules are affected?
2. What architecture boundaries are involved?
3. Is there already an existing reusable implementation?
4. What is the minimum safe change?
5. What tests/checks are needed?

## Output required before coding
- impact analysis
- minimal change plan
- risk list
```

---

## `templates/strict-review.md`

```md
# Strict Review

Review the implemented change as a strict reviewer.

## Check the following:

### Architecture consistency
- Any layer violation?
- Any boundary bypass?
- Any model leakage across layers?

### Duplication
- Did the change introduce a second implementation of an existing concept?
- Is there repeated transformation / validation / fallback logic?

### Naming consistency
- Are names aligned with existing domain language?
- Any drift or mixed terminology?

### Type safety
- Any widened types?
- Any avoidable optional fields?
- Any implicit coercions or unsafe casts?

### Error handling
- Does the change follow project error conventions?
- Any swallowed failures or inconsistent return styles?

### Test coverage
- What regression tests are missing?
- What edge cases are untested?

## Output
- problems only
- severity for each problem
- concise recommendation
```

---

## `templates/entropy-audit.md`

```md
# Entropy Audit

Inspect the recent implementation state and identify structural decay.

## Focus areas
- duplicated abstractions
- naming drift
- boundary erosion
- state duplication
- overgrown files/functions
- mixed model types
- inconsistent error handling
- excessive compatibility branches

## Output format

### Structural issues
- issue
- why it matters
- affected modules

### Priority
- P0 must fix now
- P1 should fix soon
- P2 cleanup later

### Suggested cleanup sequence
1.
2.
3.
```

---

# 这个 Skill 的触发词建议

你可以给 agent 设一组触发条件，用户说到这些就优先启用：

* “越改越乱”
* “多轮迭代后质量下降”
* “先别写代码，先分析”
* “帮我做 reviewer”
* “检查架构一致性”
* “有没有重复抽象”
* “做个收敛 / 重构 / 降熵”
* “只做最小必要改动”
* “不要只修局部问题”

---

# 使用示例

## 示例 1：功能迭代前

用户输入：

```md
给订阅列表加一个批量归档功能
```

Skill 应该先输出：

```md
1. Task classification
- Type: feature
- Risk: medium

2. Impact analysis
- Affected modules: subscription list UI, action handler, domain archive operation, persistence adapter
- Risk: state duplication, inconsistent archive semantics, bypassing existing write path

3. Minimal change plan
- inspect current archive flow
- reuse existing single-item archive action if present
- extend service/domain operation instead of adding parallel UI-only logic
- add regression tests for batch selection and partial failure handling
```

而不是直接开始写一堆代码。

---

## 示例 2：多轮修补后进入治理模式

用户输入：

```md
最近这个模块连续改了很多轮，帮我看看是不是已经漂了
```

Skill 应该切到：

* 结构问题识别
* 重复逻辑扫描
* 边界审查
* 命名漂移审查
* 类型退化审查
* 重构优先级列表

---

## 示例 3：代码写完后 reviewer 模式

用户输入：

```md
你不要继续实现了，严格 review 一下这次改动
```

Skill 应该只输出问题，不要再偷偷补代码。

---

# 这个 Skill 的核心价值

它不是让模型“写更多代码”，而是强制模型在这几件事上稳定下来：

## 1. 从“局部修补”切到“系统守卫”

避免一直围着当前报错打转。

## 2. 从“立即生成”切到“先分析后实施”

降低架构漂移。

## 3. 从“作者视角”切到“审查视角”

减少自我合理化。

## 4. 从“持续增熵”切到“定期收敛”

避免项目越做越不可维护。

---

# 如果你想把它做得更强，我建议再加两个扩展

## 扩展 A：结合仓库内规则文件

让 Skill 自动优先读取：

* `ARCHITECTURE.md`
* `ENGINEERING_RULES.md`
* `DECISIONS.md`
* `README.md`

这样它不只是抽象原则，而是会结合你项目现有约束。

---

## 扩展 B：再拆两个子 skill

后面你可以把它拆成三个专职 skill：

### 1. `custodes-coding-governor`

总控，负责判断何时进入治理模式

### 2. `strict-code-reviewer`

专门做严审，不负责实现

### 3. `entropy-refactor-planner`

专门做降熵、重构优先级规划

这样组合起来更稳。

---

# 给你的最终建议

先别做得太复杂，第一版就这样落：

* 先建一个 `custodes-coding-governor`
* 放 `SKILL.md`
* 配 3 个模板
* 把它设成“当连续改动/质量下降/要求严格 review 时自动触发”

这已经足够实用了。

如果你要，我下一步可以直接继续帮你把它补成 **完整可发布的 skills 包**，包括：

1. 英文版优化后的 `SKILL.md`
2. 中文说明文档
3. 示例用例
4. 一份适配 Claude Code 的 `agents.md`/调用约束说明
