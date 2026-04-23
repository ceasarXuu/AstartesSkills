% Storybook 前端设计与组件开发 Skills 标准（行业通用版）
% Final 1.0
% 2026-04-23

| 项目 | 内容 |
|---|---|
| 文档状态 | Final |
| 版本 | 1.0 |
| 发布日期 | 2026-04-23 |
| 适用对象 | 设计系统团队、前端团队、QA、设计师、产品经理、技术负责人 |
| 适用范围 | 共享组件、组合组件、页面级 UI、设计系统、组件库、跨项目 UI 资产治理 |
| 示例技术栈 | React + TypeScript + Vite（原则同样适用于 Vue、Angular、Web Components） |
| 编写依据 | Storybook 官方文档 10.x、组件驱动开发实践、前端工程通用治理方法 |
| 文档属性 | 团队执行标准；结构参照行业常见工程规范编写；不宣称任何外部认证标准 |

## 目录

1. 摘要
2. 目的
3. 适用范围
4. 术语、缩略语与约束语义
5. 编制依据与外部参考
6. 核心原则
7. 角色与职责
8. 标准工作流程
9. Story 粒度与覆盖标准
10. 目录结构、命名与分层约定
11. 编写规范
12. 质量门禁
13. 代码示例
14. 实施建议
15. 附录 A：模板
16. 附录 B：官方参考链接

---


## 摘要

本标准定义一套以 Storybook 为中心的前端设计与组件开发 Skills，目标是把 **story** 统一为设计状态的表达单位、开发时的隔离工作台、测试夹具、文档节点与评审链接。本文强调以下执行原则：

1. 以 **组件驱动开发（Component-Driven Development）** 为主线，自底向上构建 Foundations、Primitive、Pattern 与 Screen。
2. 以 **CSF + TypeScript + Args-first** 作为默认编写范式；优先使用 `args` 表达状态，使用 decorators 表达上下文，使用 mocks 表达外部依赖，`loaders` 仅在必要时使用。
3. 以 **一 Story 一概念 / 一用例** 作为粒度基线，避免 props 全排列和 demo 式 story。
4. 以 **Autodocs、play、a11y、visual testing、publish、composition** 为标准化交付路径，使 story 能在文档、测试、评审和多仓协作中复用。
5. 以 **可重现、可离线、可评审、可回归** 作为故事质量门槛。

---

## 1. 目的

本标准用于解决以下常见问题：

- 设计稿、组件代码、测试用例、文档说明彼此割裂。
- 组件在真实页面中状态复杂，开发阶段难以稳定复现。
- 视觉回归、可访问性问题和交互问题进入业务集成后才暴露。
- 组件库 / 设计系统缺少一致的 story 粒度、目录结构与评审入口。
- 多团队协作时，UI 状态没有统一的“可执行规范”。

本标准的目标是：

- 为团队提供一套符合官方最佳实践且可直接落地的 Storybook 工作流。
- 明确 story 的分层、粒度、命名、状态覆盖与质量门禁。
- 把 Storybook 从“组件展示页”提升为“设计系统与前端实现的执行平台”。

## 2. 适用范围

### 2.1 适用对象

- 设计系统 / 组件库团队
- 业务前端团队
- QA / 测试团队
- 设计师 / 设计工程师
- 技术负责人 / 代码评审者

### 2.2 适用资产

- 复用型基础组件（如 Button、Input、Avatar、Badge）
- 组合组件 / 模式组件（如 LoginForm、DataTable、FilterBar）
- 页面级 UI（如 OrdersPage、DashboardPage）
- 设计 Token 展示页 / Docs 页面
- 跨仓共享的 Storybook 文档站点

### 2.3 不适用范围

以下内容不属于本文标准的主执行范围，但可以参考其原则：

- 一次性活动页 / throwaway prototype
- 纯算法或无 UI 表现的模块
- 仅为临时调试存在且不进入主干的本地 demo

## 3. 术语、缩略语与约束语义

### 3.1 术语

| 术语 | 定义 |
|---|---|
| Storybook | 在隔离环境中构建、测试、文档化组件与页面的前端工作台 |
| Story | 一个明确的 UI 状态、用例或交互场景的可执行表示 |
| CSF | Component Story Format，Storybook 官方推荐的 story 文件格式 |
| Args | story 的输入参数集合，用于表达组件渲染状态 |
| Parameters | story / 组件 / 项目级静态配置元数据 |
| Decorator | 用于为 story 注入上下文、布局、provider 或包装逻辑的机制 |
| Globals | 可被 toolbar 驱动的全局渲染变量，如 theme、locale |
| Play function | 在 story 渲染完成后执行的交互脚本，用于验证行为和流程 |
| Loader | story 渲染前准备数据的高级特性；仅在其他方式不足时使用 |
| Mocking | 对网络请求、模块、路由、上下文、浏览器环境等依赖进行替身控制 |
| Autodocs | 基于 stories 自动生成文档页面的能力 |
| Composition | 将多个 Storybook 聚合展示的能力 |
| Stable story | 作为长期文档、测试、评审与视觉基线使用的稳定 story |

### 3.2 约束语义

为保证执行一致性，本文使用如下约束语义：

- **MUST**：必须遵守；不满足即视为不符合标准。
- **SHOULD**：推荐遵守；如不采用，必须有明确原因和替代措施。
- **MAY**：可选项；按项目实际情况决定是否采用。

## 4. 编制依据与外部参考

### 4.1 官方依据（规范性参考）

以下官方文档构成本标准的主要依据：

1. Storybook Docs 首页：定义 Storybook 的定位与通用能力。
2. Component Story Format（CSF）：定义 story 的官方文件格式与写法。
3. Args：定义 story 状态的首选表达方式。
4. Parameters：定义 story、meta 与 project 级配置方式。
5. Decorators：定义上下文包装和渲染增强方式。
6. Toolbars & Globals：定义 theme、locale 等全局变量控制方式。
7. Loaders：定义高级数据准备方式及其使用边界。
8. Building Pages with Storybook：定义页面级 story 与组合方式。
9. Mocking network requests / modules：定义网络和模块 mock 的官方方法。
10. Autodocs：定义自动化文档路径。
11. Vitest addon / Testing docs：定义 stories 到 component tests 的官方路径。
12. Accessibility testing：定义可访问性测试与 `error / todo / off` 工作流。
13. Visual testing：定义视觉快照与基线比较路径。
14. Design integrations：定义 Storybook 与 Figma 等设计工具的协同方式。
15. Storybook Composition：定义跨仓 / 跨包聚合方式。

### 4.2 补充参考（说明性）

- Storybook 10.3 release：了解当前版本的能力边界。
- Storybook MCP / AI docs：作为 React 项目的高级扩展项参考，不作为基线要求。
- Intro to Storybook / Component Driven UI 站点：用于培训和新成员 onboarding。

## 5. 核心原则

### 5.1 组件驱动，自底向上

团队 MUST 采用自底向上的构建方式：

`Foundations -> Primitive -> Pattern -> Screen -> Product Integration`

含义如下：

- Foundations 表达颜色、字阶、间距、图标等设计基础。
- Primitive 表达最小可复用 UI 单元。
- Pattern 表达用户任务层级的组合组件。
- Screen 表达页面级视图状态。
- Product Integration 负责接入真实业务逻辑与数据源。

### 5.2 Story 是状态规范，不是 demo

每个 story MUST 表达一个清晰的状态、概念或用例，而不是临时演示片段。story 必须满足：

- 可稳定渲染
- 可被复用
- 可被 QA 与设计评审
- 可进入自动化测试
- 可成为文档节点

### 5.3 Args-first

团队 MUST 以 `args` 作为 story 状态建模的第一选择：

- 用户可观察的差异，优先写成 `args`。
- 控件面板需要暴露的输入，优先由 `args` 驱动。
- 事件回调优先使用 `fn()` 等可观测 mock。

### 5.4 上下文与依赖分离

团队 SHOULD 按以下优先级管理 story 依赖：

1. `args`：表达组件状态
2. `parameters`：表达静态配置
3. `decorators` / providers：表达上下文
4. `mocks`：表达网络、模块、路由、会话等外部依赖
5. `loaders`：仅在以上方式都不能合理解决时使用

### 5.5 一 Story 一概念

每个 story SHOULD 只回答一个问题，例如：

- 默认态长什么样？
- 禁用态是否正确？
- 长文案是否溢出？
- 提交后是否出现成功反馈？
- 页面空态是否清晰？

不得把多个不相关现象堆在一个 story 里，以免降低可读性、可测试性和可审阅性。

### 5.6 默认把质量能力绑定在 story 上

团队 SHOULD 把以下能力绑定到 story，而不是分散到临时页面或专门 demo：

- 自动化文档
- 交互测试
- 可访问性检查
- 视觉回归比较
- PR 评审链接

## 6. 角色与职责

| 角色 | 主要职责 | 关键交付物 |
|---|---|---|
| 设计师 / 设计工程师 | 提供设计源、状态矩阵、交互说明、设计验收标准 | Figma 链接、状态说明、设计注释 |
| 组件负责人 | 拆分组件层级、编写 stories、建立基线质量门禁 | story files、docs、play、mocks |
| 业务前端 | 将共享 stories 组合到页面，补充页面态和业务 mock | page stories、场景 mock、页面评审链接 |
| QA | 补充验收维度、验证状态覆盖、复核视觉与交互问题 | QA checklist、缺陷记录、回归结论 |
| Reviewer / TL | 审核粒度、命名、状态覆盖、质量门禁是否满足 | 评审结论、例外批准 |
| 平台 / 设计系统维护者 | 维护 `.storybook` 基线、发布策略、Composition、标签治理 | preview 基线、main 配置、发布规则 |

## 7. 标准工作流程

### 7.1 需求进入与 Story Map

在开始写组件前，团队 MUST 先完成 Story Map。最少包含以下内容：

- 组件树 / 页面树
- 状态矩阵（默认、空、错、禁用、加载、边界等）
- 交互矩阵（点击、输入、提交、导航、反馈）
- 依赖边界（API、router、auth、feature flag、浏览器能力）
- story 分层归属（Foundations / Components / Patterns / Screens）

**输出物**：一个可被评审的 Story Map 文档或表格。

### 7.2 Foundations 与 Primitive 编写

团队 SHOULD 先完成可复用层：

- Foundations：推荐使用 docs page 或 token gallery，不建议一 token 一 story。
- Primitive：必须覆盖默认态、关键变体、禁用态和至少一个边界态。

### 7.3 项目级渲染基线搭建

`.storybook/preview.ts` 或 `.storybook/preview.tsx` MUST 作为项目级基线配置中心，统一承载；如果 decorators 使用 JSX provider 包装，优先使用 `.tsx`：

- 全局 decorators
- theme / locale / density 等 globals
- 通用 parameters
- 通用 providers
- 通用 mocks 与 loader 注册
- 默认 a11y / docs / layout 策略

### 7.4 Pattern 与 Screen 组装

Pattern 与 Screen SHOULD 在复用子 story 的基础上继续组装：

- 页面 story 优先组合子 story 的 `args`
- 页面依赖通过 mock 管理，而不是直连真实后端
- 页面级必须明确 Loaded、Loading、Empty、Error 等关键状态
- 页面 story 需要时使用 `layout: 'fullscreen'`

### 7.5 交互与质量绑定

对于有真实用户流程的 Pattern / Screen，团队 MUST 识别关键路径并落在 story 上：

- 表单输入与提交
- 对话框开启 / 关闭
- 过滤、排序、分页
- 成功 / 失败反馈
- 权限拒绝或异常处理

关键路径 SHOULD 使用 `play` 表达；关键 story SHOULD 纳入 component tests、a11y 与 visual baseline。

### 7.6 发布与评审

PR 评审 SHOULD 直接基于已发布的 Storybook 或本地可访问的预览地址，而不是静态截图。评审对象包括：

- 新增 / 变更 story
- docs 页说明
- 页面状态覆盖
- 交互执行结果
- 可访问性与视觉回归结果

### 7.7 变更控制

任何影响用户可见状态的 UI 变更 MUST 对应 story 变更。以下变更至少满足其一：

- 新增 story
- 修改既有 story args / parameters
- 新增 play
- 调整 docs 说明
- 更新 visual baseline

## 8. Story 粒度与覆盖标准

### 8.1 分层粒度规范

| 层级 | 目标 | 推荐载体 | 推荐 story 数量 | 必备内容 |
|---|---|---|---:|---|
| Foundations | 展示设计基础与规则 | Docs page / token gallery | 1-3 / 类别 | 色板、字阶、间距、使用规则 |
| Primitive | 固化最小可复用 UI 单元 | 组件 story file | 4-8 / 组件 | 默认、关键变体、禁用、边界 |
| Pattern | 表达用户任务级组合 | 组合组件 story file | 3-6 / 组件 | 关键流程、交互、异常、空态 |
| Screen | 表达页面与视图状态 | 页面 story file | 3-5 / 页面 | Loaded、Loading、Empty、Error、Permission |
| Connected container | 处理接近真实应用的连接层 | 仅在必要时单独建立 | 1-3 / 容器 | 浏览器环境、框架 API、外部依赖控制 |

### 8.2 最低状态覆盖要求

| 状态类型 | 说明 | 是否必须 |
|---|---|---|
| Default | 正常默认状态 | MUST |
| Variant | 公开支持的核心变体 | SHOULD |
| Disabled / Readonly | 被禁用或只读时的表现 | MUST（如组件支持） |
| Loading | 加载或占位状态 | MUST（如用户可见） |
| Empty | 数据为空时的状态 | MUST（如存在列表/容器语义） |
| Error | 校验失败、接口错误、权限错误等 | MUST（如存在失败路径） |
| Boundary | 长文本、极小/极大值、缺失图片、异常字符等 | SHOULD |
| Responsive | 小屏/大屏导致布局显著变化时 | SHOULD |
| Theme / Locale | 主题或语言改变导致表现差异时 | SHOULD |

### 8.3 粒度判断规则

团队 MUST 使用以下判断规则：

1. **用户可观察**：用户看得见或操作得到的差异，才值得独立 story。
2. **概念单一**：一个 story 只表达一个核心概念或用例。
3. **价值优先**：不要为 props 做笛卡尔积；保留最有价值的状态集合。
4. **复用优先**：Page story 优先复用子 story 的 args，而不是重新造数据。
5. **工具条优先**：theme、locale、density 等横切变量优先用 globals，而不是复制多份 story。

### 8.4 反模式

| 反模式 | 问题 | 替代方案 |
|---|---|---|
| 把 story 当 demo 页 | 状态不可复用、不可测试 | 一 Story 一概念 / 用例 |
| props 全排列 | 噪声太大，难以维护 | 保留默认、关键变体、边界态 |
| 页面直连真实后端 | 不稳定，难复现 | MSW / module mock / provider mock |
| 在每个 story 中重复包一层 provider | 配置分散、易漂移 | 放入 project-level decorators |
| 所有问题都用 loaders 解决 | 与 args / controls / docs 生态脱节 | 优先 args、decorators 与 mocks |
| 只做 happy path | 空态、错态和边界态缺失 | 按最低状态集建模 |

## 9. 目录结构、命名与分层约定

### 9.1 推荐目录结构

```text
src/
  foundations/
    colors/
      Colors.mdx
    typography/
      Typography.mdx
  components/
    Button/
      Button.tsx
      Button.stories.tsx
      Button.test.tsx
  patterns/
    LoginForm/
      LoginForm.tsx
      LoginForm.stories.tsx
  screens/
    OrdersPage/
      OrdersPage.tsx
      OrdersPage.stories.tsx
.storybook/
  main.ts
  preview.tsx
  manager.ts
```

### 9.2 Sidebar / title 命名规范

Storybook 侧边栏 SHOULD 使用清晰稳定的层级：

- `Foundations/Colors`
- `Foundations/Typography`
- `Components/Button`
- `Components/Form/Input`
- `Patterns/Auth/LoginForm`
- `Patterns/Data/OrderTable`
- `Screens/Orders/OrdersPage`

命名要求：

- `title` MUST 对应清晰的产品 / 设计层级，而不是技术路径噪声。
- 公开 story 名称 SHOULD 使用业务或设计语言，而不是内部调试术语。
- 修改 story 导出名会改变 story ID 与 URL；对外部集成稳定性有要求时，应谨慎变更。

### 9.3 文件命名规范

- story 文件 MUST 命名为 `ComponentName.stories.tsx`（或对应框架后缀）。
- 示例 / 教学型 MDX 文档 SHOULD 命名为 `ComponentName.mdx` 或专题名称。
- 元数据对象 SHOULD 使用 `meta`；story 类型 SHOULD 使用 `type Story = StoryObj<typeof meta>`。

### 9.4 标签（tags）治理建议

| 标签 | 用途 | 说明 |
|---|---|---|
| `autodocs` | 自动生成文档 | 推荐项目级默认启用 |
| `stable` | 稳定基线 | 用于纳入长期文档 / 测试 / 视觉基线 |
| `page` | 页面级 story | 便于筛选页面类状态 |
| `experimental` | 试验性 story | SHOULD 默认从导航或测试中排除 |
| `wip` | 开发中 | 不建议长期保留在主干 |

## 10. 编写规范

### 10.1 基线写法

团队 SHOULD 采用以下基线：

- TypeScript stories
- CSF 对象写法
- `satisfies Meta<typeof Component>` 进行类型约束
- `StoryObj<typeof meta>` 定义 story 类型
- 项目级默认启用 `autodocs`

### 10.2 Args 与 Controls

- 组件公开输入 SHOULD 尽量进入 `args`。
- 用户能感知的文本、状态、变体、尺寸、禁用开关、插槽内容 SHOULD 暴露为 `args`。
- 内部实现细节、不稳定或不适合交互的属性 MAY 通过 `argTypes` 隐藏控制。
- callbacks SHOULD 使用 `fn()` 以便在 Actions / Tests 中观测调用。

### 10.3 Parameters

`parameters` MUST 用于表达 story 的静态元数据，例如：

- `layout`
- `a11y`
- `msw`
- docs 说明
- 视觉或测试相关配置

团队 SHOULD 避免把会频繁变化的状态塞进 `parameters`；这类内容应优先作为 `args` 或 `globals`。

### 10.4 Decorators 与 Globals

- provider、router、theme、i18n、session 等上下文 SHOULD 放在 project-level decorators 中统一管理。
- theme、locale、density 等横切切换项 SHOULD 通过 globals + toolbar 控制。
- 只有局部特殊场景，才在 story 级使用 decorator 覆盖。

### 10.5 Mocking 数据与模块

- 网络请求 MUST 使用 MSW 或等价机制隔离。
- 路由、浏览器 API、会话模块、实验开关等 SHOULD 使用 provider mock 或 module automocking。
- story MUST 在无真实后端、无真实登录、无真实第三方服务的前提下独立运行。
- 连接型组件 MAY 单独建立 `Connected` story，但仍需保证可重现与可离线。

模块 mock 示例：

```ts
import type { Preview } from '@storybook/react-vite';
import { sb } from 'storybook/test';

sb.mock(import('../src/lib/session.ts'), { spy: true });
sb.mock(import('../src/lib/analytics.ts'));

const preview: Preview = {};
export default preview;
```

### 10.6 Loaders 使用边界

`loaders` 是高级特性。团队 MUST 遵守以下边界：

- 仅当 `args + decorators + mocks` 无法合理表达场景时使用。
- 需要异步准备大型数据或外部资源时可使用。
- 使用时 SHOULD 在注释或文档中说明其必要性。
- 不应把所有页面数据都简单迁移到 `loaders`，以免失去 args/controls/doc 的可组合性。

### 10.7 文档规范

- 项目 SHOULD 默认启用 `autodocs`。
- 对于需要更强叙事的主题（如可访问性说明、设计原则、Do / Don’t），MAY 使用 MDX 补充。
- 组件 docs 页面 SHOULD 至少包含：用途、何时使用、关键 props、状态说明、可访问性注意事项、交互注意事项。
- 对外共享的 Storybook SHOULD 保证 story 名称、说明文字、代码示例可被设计与 QA 理解。

### 10.8 测试规范

**交互测试**

- Pattern / Screen 的关键用户流程 SHOULD 使用 `play` 描述。
- 对重要 callback、提交行为、状态变化 SHOULD 加断言。

**组件测试**

- 对 Vite-based Storybook（如 `react-vite`、`vue3-vite`、`nextjs-vite`、`sveltekit` 等），SHOULD 优先使用 Vitest addon。
- 非 Vite 项目 MAY 采用官方支持的其他测试路径，但 stories 仍应保持可组合、可测试。

**可访问性测试**

- 项目级 SHOULD 默认 `a11y: { test: 'error' }`。
- 已知债务可临时设置为 `'todo'`，但必须有跟踪项。
- `'off'` 仅适用于反模式示例或明确不应执行 a11y 测试的 story。

**视觉测试**

- `stable` stories SHOULD 全部进入视觉基线比较。
- 视觉测试优先覆盖容易回归的组件：表格、表单、导航、主题切换、边界态。

**外部测试复用**

- 团队 SHOULD 使用 `composeStories` / `composeStory` 在 Vitest 等外部环境复用 stories，而不是重写测试夹具。

### 10.9 设计协作与 Distribution

- 设计团队使用 Figma 时，SHOULD 建立 Storybook 与 Figma 的双向协作路径：嵌入 Figma 到 Storybook，或嵌入 Storybook 到 Figma。
- 当设计系统与业务系统分仓时，SHOULD 使用 Storybook Composition 聚合展示。
- 当组件库对外发布为 package 时，SHOULD 保持 story 作为对内对外一致的质量入口。

### 10.10 AI / MCP（高级扩展项）

- 对 React 项目，可将 Storybook 的 AI / MCP / manifests 能力视为高级扩展能力。
- 该能力当前处于预览阶段，应作为“增强项”而非“基线要求”。
- 若启用，story 必须更加注重单概念、清晰命名与高质量描述，以利于机器消费与检索。

## 11. 质量门禁

### 11.1 Definition of Ready（DoR）

| 检查项 | 要求 |
|---|---|
| 设计源 | 有可访问的设计稿或状态说明 |
| 状态矩阵 | 已列出默认、异常、边界、权限、主题等关键状态 |
| 交互说明 | 关键流程和反馈已明确 |
| 依赖边界 | API、router、auth、feature flag 等依赖已识别 |
| 验收口径 | 设计、前端、QA 对 story 分层有一致理解 |

### 11.2 Definition of Done（DoD）

| 检查项 | Primitive | Pattern | Screen |
|---|---|---|---|
| 已建立 story file | MUST | MUST | MUST |
| 已覆盖 Default | MUST | MUST | MUST |
| 已覆盖 Empty / Error / Loading | 如适用 | MUST（如适用） | MUST |
| 已覆盖至少一个边界态 | SHOULD | SHOULD | SHOULD |
| 已配置 docs | MUST | MUST | MUST |
| 已配置 mock | 如适用 | MUST | MUST |
| 已有 play | 可选 | SHOULD | SHOULD |
| a11y 已通过或有 todo 说明 | MUST | MUST | MUST |
| 进入视觉基线 | SHOULD | SHOULD | SHOULD |
| 已提供 PR / 发布链接供评审 | MUST | MUST | MUST |

### 11.3 PR 检查清单

提交涉及 UI 变更的 PR 时，作者 MUST 自检以下事项：

- [ ] 新增用户可见状态已补充对应 story。
- [ ] 被修改的组件 story 没有与实现脱节。
- [ ] 页面状态已覆盖 Loaded / Empty / Error / Loading 中的适用项。
- [ ] 所有外部依赖均已 mock，不依赖真实后端。
- [ ] 关键流程已补充或更新 `play`。
- [ ] `a11y` 违规已修复，或已显式标记 `todo` 并登记原因。
- [ ] 需要长期追踪的故事已加 `stable` 标签。
- [ ] PR 描述中附有 Storybook 预览地址或构建产物链接。

## 12. 代码示例

### 12.1 项目级预览配置：`.storybook/preview.tsx`

```ts
import type { Preview } from '@storybook/react-vite';
import { initialize, mswLoader } from 'msw-storybook-addon';
import { AppProviders } from '../src/app/AppProviders';

initialize();

const preview: Preview = {
  tags: ['autodocs'],
  loaders: [mswLoader],
  parameters: {
    layout: 'centered',
    controls: { expanded: true },
    a11y: { test: 'error' },
  },
  globalTypes: {
    theme: {
      toolbar: {
        title: 'Theme',
        items: ['light', 'dark'],
      },
    },
    locale: {
      toolbar: {
        title: 'Locale',
        items: ['zh-CN', 'en-US'],
      },
    },
  },
  decorators: [
    (Story, context) => (
      <AppProviders theme={context.globals.theme} locale={context.globals.locale}>
        <Story />
      </AppProviders>
    ),
  ],
};

export default preview;
```

### 12.2 Primitive 示例：`Button.stories.tsx`

```ts
import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';
import { Button } from './Button';

const meta = {
  title: 'Components/Button',
  component: Button,
  tags: ['autodocs', 'stable'],
  args: {
    label: '保存',
    variant: 'primary',
    disabled: false,
    onClick: fn(),
  },
  parameters: {
    a11y: { test: 'error' },
  },
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Secondary: Story = {
  args: { variant: 'secondary' },
};

export const Disabled: Story = {
  args: { disabled: true },
};

export const LongLabel: Story = {
  args: { label: '保存并继续编辑当前内容' },
};
```

### 12.3 Pattern 示例：`LoginForm.stories.tsx`

```ts
import type { Meta, StoryObj } from '@storybook/react-vite';
import { expect, fn } from 'storybook/test';
import { LoginForm } from './LoginForm';

const meta = {
  title: 'Patterns/Auth/LoginForm',
  component: LoginForm,
  args: {
    onSubmit: fn(),
  },
  parameters: {
    a11y: { test: 'error' },
  },
} satisfies Meta<typeof LoginForm>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Empty: Story = {};

export const FilledAndSubmitted: Story = {
  play: async ({ canvas, userEvent, args }) => {
    await userEvent.type(canvas.getByLabelText('邮箱'), 'demo@example.com');
    await userEvent.type(canvas.getByLabelText('密码'), 'correct-horse-battery-staple');
    await userEvent.click(canvas.getByRole('button', { name: '登录' }));
    await expect(args.onSubmit).toHaveBeenCalled();
  },
};
```

### 12.4 Screen 示例：`OrdersPage.stories.tsx`

```ts
import type { Meta, StoryObj } from '@storybook/react-vite';
import { delay, http, HttpResponse } from 'msw';

import { OrdersPage } from './OrdersPage';
import * as HeaderStories from '../Header/Header.stories';
import * as OrderTableStories from '../OrderTable/OrderTable.stories';

const meta = {
  title: 'Screens/Orders/OrdersPage',
  component: OrdersPage,
  tags: ['autodocs', 'stable', 'page'],
  parameters: {
    layout: 'fullscreen',
  },
  args: {
    header: HeaderStories.LoggedIn.args,
    rows: OrderTableStories.WithResults.args?.rows ?? [],
  },
} satisfies Meta<typeof OrdersPage>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Loaded: Story = {};

export const Empty: Story = {
  args: {
    rows: [],
  },
};

export const Error: Story = {
  parameters: {
    msw: {
      handlers: [
        http.get('/api/orders', async () => {
          await delay(500);
          return new HttpResponse(null, { status: 500 });
        }),
      ],
    },
  },
};
```

### 12.5 外部测试复用示例：`Button.test.tsx`

```ts
import { test, expect } from 'vitest';
import { screen } from '@testing-library/react';
import { composeStories } from '@storybook/react-vite';
import * as stories from './Button.stories';

const { Default } = composeStories(stories);

test('renders default button', async () => {
  await Default.run();
  expect(screen.getByText('保存')).toBeTruthy();
});
```

## 13. 实施建议

### 13.1 分阶段落地

| 阶段 | 目标 | 最低交付 |
|---|---|---|
| Phase 1 基线化 | 建立 Storybook 作为统一工作台 | `.storybook` 基线、组件 stories、autodocs |
| Phase 2 质量化 | 让 stories 成为测试与评审入口 | play、a11y、visual baseline、PR 评审链接 |
| Phase 3 资产化 | 让 stories 成为跨团队共享资产 | publish、composition、设计联动 |
| Phase 4 智能化 | 提升 machine-readable 能力 | 高质量 story 描述、React 项目 AI / MCP 增强 |

### 13.2 团队治理建议

- 把 story 变更纳入 code review 必审项。
- 将新增组件“先有 story，再接业务”设为团队约束。
- 定期清理 `experimental` 与 `wip` 标签，避免主干失控。
- 用仪表盘统计 stable stories、a11y todo 数、visual baseline 覆盖率。

### 13.3 例外管理

当项目因框架、历史包袱或性能原因无法完全遵循时，团队 MAY 申请例外，但必须说明：

- 无法遵循的具体条款
- 原因与影响范围
- 替代措施
- 预计回归标准的时间点

## 14. 附录 A：模板

### A.1 Story Map 模板

| 模块 / 页面 | 层级 | 关键状态 | 关键交互 | 外部依赖 | 对应 story |
|---|---|---|---|---|---|
| Button | Primitive | Default / Disabled / LongLabel | Click | 无 | `Components/Button/*` |
| LoginForm | Pattern | Empty / Error / Submitting | Input / Submit | Auth API | `Patterns/Auth/LoginForm/*` |
| OrdersPage | Screen | Loaded / Empty / Error / Permission | Filter / Retry / Pagination | Orders API / Router | `Screens/Orders/OrdersPage/*` |

### A.2 状态矩阵模板

| 状态类别 | 说明 | 是否有 story | 备注 |
|---|---|---|---|
| Default | 默认展示 |  |  |
| Variant | 核心变体 |  |  |
| Disabled | 禁用 / 只读 |  |  |
| Loading | 加载中 |  |  |
| Empty | 空状态 |  |  |
| Error | 错误 / 异常 |  |  |
| Boundary | 长文本 / 溢出 / 缺图 |  |  |
| Theme / Locale | 主题 / 多语言差异 |  |  |

### A.3 审核记录模板

| 审核项 | 结论 | 备注 |
|---|---|---|
| story 粒度合理 | 通过 / 不通过 |  |
| 状态覆盖完整 | 通过 / 不通过 |  |
| mock 稳定 | 通过 / 不通过 |  |
| docs 可读 | 通过 / 不通过 |  |
| play 覆盖关键流程 | 通过 / 不通过 |  |
| a11y 结果可接受 | 通过 / 不通过 |  |
| visual baseline 已更新 | 通过 / 不通过 |  |

## 15. 附录 B：官方参考链接（2026-04-23 访问）

以下链接建议保留在团队 wiki 或 README 中，便于长期维护：

- Storybook Docs: https://storybook.js.org/docs
- Storybook Home: https://storybook.js.org/
- CSF: https://storybook.js.org/docs/api/csf
- Args: https://storybook.js.org/docs/writing-stories/args
- Parameters: https://storybook.js.org/docs/api/parameters
- Decorators: https://storybook.js.org/docs/writing-stories/decorators
- Toolbars & Globals: https://storybook.js.org/docs/essentials/toolbars-and-globals
- Loaders: https://storybook.js.org/docs/writing-stories/loaders
- Building pages with Storybook: https://storybook.js.org/docs/writing-stories/build-pages-with-storybook
- Mocking network requests: https://storybook.js.org/docs/writing-stories/mocking-data-and-modules/mocking-network-requests
- Mocking modules: https://storybook.js.org/docs/writing-stories/mocking-data-and-modules/mocking-modules
- Autodocs: https://storybook.js.org/docs/writing-docs/autodocs
- Testing: https://storybook.js.org/docs/writing-tests
- Vitest addon: https://storybook.js.org/docs/writing-tests/integrations/vitest-addon/index
- Accessibility testing: https://storybook.js.org/docs/writing-tests/accessibility-testing
- Visual testing: https://storybook.js.org/docs/writing-tests/visual-testing
- Design integrations: https://storybook.js.org/docs/sharing/design-integrations
- Storybook Composition: https://storybook.js.org/docs/sharing/storybook-composition
- Portable stories in Vitest: https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest
- Storybook 10.3 release: https://storybook.js.org/blog/storybook-10-3/
- Storybook MCP for React: https://storybook.js.org/blog/storybook-mcp-for-react/

---

**结论**：

团队在采用本标准后，应把 Storybook 视为前端设计与组件开发的标准工作台。story 不再只是展示材料，而是设计状态、实现约束、测试入口、文档节点与跨团队沟通链接的统一载体。只要 story 粒度设计正确、工作流固定、质量门禁前置，Storybook 的开发优势才能被系统性放大。
