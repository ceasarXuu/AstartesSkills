---
name: threejs-game
description: Route a three.js game-development task to the right specialized skills. Use for planning a full game workflow, upgrading demos into maintainable game codebases, or choosing between runtime, asset, rendering, input, physics, animation, performance, networking, and XR tracks. Do not use for generic non-game three.js pages.
---

# Goal

作为总控 skill，为 three.js 游戏项目选择正确的工作路径、子 skill 组合和交付顺序。它本身不承担所有实现细节，而是负责把任务拆给合适的专用 skill。

# Use this skill when

- 你要从零开始做 three.js 游戏项目
- 你接手一个 three.js demo，想把它升级成可维护的游戏代码库
- 你不确定某个需求应该优先走渲染、资产、物理、交互还是性能路径
- 你要给 agent 设定明确的游戏开发工作流，避免泛化到“普通三维网页”

# Do not use this skill when

- 你已经明确知道只需要一个单点能力，例如只做 glTF 资产优化、只做 Pointer Lock 相机、只做后处理调优
- 你在做非游戏场景的产品展示、数据可视化、纯 3D 官网动效

# Required inputs

- 游戏类型：FPS / TPS / top-down / platformer / driving / XR / sandbox / strategy 等
- 目标平台：桌面浏览器 / 移动浏览器 / Electron / Tauri / WebXR
- 目标设备：键鼠 / 手柄 / 触摸 / XR 控制器
- 网络形态：单机 / 本地同步 / 服务端权威多人
- 内容形态：重资产 / 程序化 / 低多边形 / 写实 PBR / 风格化
- 当前代码状态：从零开始 / demo / 已上线项目 / 重构中

# Outputs

- 一个清晰的 skill 组合方案
- 一个按先后顺序执行的实施计划
- 对当前需求不该做什么的约束说明
- 对需要额外外部库的建议与边界

# Workflow

## 1. 先判断项目类型

至少回答以下问题：

1. 这是“游戏”还是“3D 应用”
2. 是否需要持续帧循环与实时交互
3. 是否有角色控制、碰撞、玩法状态
4. 是否需要存档 / 同步 / 可重放
5. 是否需要强视觉特效或 WebGPU

如果以上大多数回答为是，则继续按游戏工程路径组织，不要退化成普通 three.js 页面脚本。

## 2. 选择基础组合

### 最小可运行组合
- `threejs-game-bootstrap-runtime`
- `threejs-game-asset-pipeline`
- `threejs-game-render-lighting`
- `threejs-game-input-camera`
- `threejs-game-performance-profiler`

### 交互角色类游戏
再加入：
- `threejs-game-interaction-ui`
- `threejs-game-physics-collision`

### 角色驱动内容
再加入：
- `threejs-game-animation-character`

### 强视觉 / 风格化 / GPU 驱动
再加入：
- `threejs-game-materials-tsl-vfx`

### 存档 / 多人 / 回放
再加入：
- `threejs-game-save-load-network`

### XR
再加入：
- `threejs-game-xr-platform`

## 3. 固定执行顺序

默认按这个顺序推进：

1. 运行时基建
2. 资产规范
3. 渲染基线
4. 输入与相机
5. 交互与碰撞
6. 动画或玩法状态
7. 性能预算
8. 存档 / 网络 / 平台特性
9. QA 与发布

不要在还没有资源生命周期、相机控制、基础碰撞时就先做复杂 shader 和花哨 VFX。

## 4. 输出时必须包含的约束

每次调用本 skill，都要显式给出：

- 当前建议使用的渲染后端：WebGL / WebGPU / 双线支持
- 当前项目最适合的资产路径：glTF / GLB、压缩链、验证链
- 是否必须接物理引擎
- 是否应该引入 animation state graph
- 当前最值得优先优化的指标：draw calls / GPU 时间 / CPU 主线程 / 内存 / 包体

# Decision rules

- **FPS / TPS / sandbox / action**：通常必须启用 `physics-collision`
- **重角色动画**：必须启用 `animation-character`
- **写实或半写实 PBR**：必须启用 `render-lighting`
- **海量物件、粒子、风格化效果**：优先追加 `materials-tsl-vfx` 与 `performance-profiler`
- **多人或带回放**：必须启用 `save-load-network`
- **VR / MR**：必须启用 `xr-platform`

# Common pitfalls

- 把 three.js 当成完整引擎，导致玩法状态、资产规则、生命周期都散落在脚本里
- 没有渲染与资产规范就开始堆内容，后期全部返工
- 提前引入太多库，没有适配层
- 让 agent 在没有边界的情况下同时修改渲染、玩法、资产和网络

# Recommended deliverable template

1. 项目分类结论
2. 当前建议激活的 skills
3. 执行顺序
4. 风险项
5. 本轮不做的事情
6. 下一步可交付物

# Official references

- three.js manual: making a game, load-gltf, color-management, shadows, transparency, picking
- three.js docs: WebGLRenderer, WebGPURenderer, Object3D, Layers, AnimationMixer, PMREMGenerator
- Khronos glTF: spec, validator, sample models
