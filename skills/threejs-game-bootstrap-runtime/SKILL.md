---
name: threejs-game-bootstrap-runtime
description: Create or refactor a three.js game runtime into a maintainable project structure with a renderer factory, game loop, resize flow, lifecycle hooks, and service boundaries. Use for new projects or when a demo needs production-grade runtime structure.
---

# Goal

建立一个可维护、可扩展、适合游戏开发的 three.js 运行时基线，而不是一次性 demo 脚本。

# Use this skill when

- 你在新建 three.js 游戏项目
- 你要把单文件或少量模块的 demo 重构成工程化结构
- 你需要统一主循环、时间系统、renderer 创建、resize、场景与服务边界
- 你希望 agent 在改代码时始终遵守固定运行时架构

# Required inputs

- 包管理器与构建工具偏好
- 是否使用 TypeScript
- 目标平台：浏览器 / Electron / Tauri / WebView
- 是否预期未来接 WebGPU / XR / Worker 渲染

# Outputs

- 项目目录结构
- 主循环与渲染器工厂
- runtime service 边界
- 最小可运行样板代码
- 运行时约束文档

# Standards

- 默认 `Vite + TypeScript strict`
- 默认 `renderer.setAnimationLoop()` 驱动循环
- 默认使用独立的 `App`, `World`, `Render`, `Input`, `UI`, `AssetRegistry` 服务
- 不允许玩法逻辑直接散落在入口文件
- 不允许任何模块偷偷 new 出第二个 renderer、clock、camera 而不经过运行时服务

# Workflow

## 1. 建立目录边界

推荐最小骨架：

```text
src/
  main.ts
  app/
    GameApp.ts
  render/
    RendererService.ts
    CameraService.ts
    SceneService.ts
  world/
    WorldRoot.ts
  input/
    InputService.ts
  ui/
    UiRoot.ts
  assets/
    AssetRegistry.ts
  shared/
    events.ts
    types.ts
```

## 2. 构建 renderer 工厂

必须显式设置：

- `antialias`
- `powerPreference`
- `alpha`
- `canvas`
- `outputColorSpace`
- tone mapping 策略
- pixel ratio 上限

默认要求：

- `setPixelRatio(Math.min(window.devicePixelRatio, 2))`
- 在 resize 时统一更新 camera aspect、projection matrix 与 renderer size
- 所有 resize 逻辑只允许存在一个入口

## 3. 主循环分层

主循环至少分成：

1. input pre-update
2. gameplay update
3. animation update
4. physics step
5. late update
6. render
7. metrics update

不要把所有内容都塞进一个 `tick()`。

## 4. 时间系统

- 统一 delta 计算来源
- 为暂停、慢动作、fixed step 预留能力
- 动画时间与物理时间允许不同步，但必须在架构上明确

推荐做法：

- `rawDelta`：原始帧间隔
- `gameDelta`：受暂停/slow-motion 影响的逻辑间隔
- `fixedDelta`：物理固定步长

## 5. 场景组织

至少拆分：

- 主世界 scene
- HUD / overlay
- 可选 debug scene

避免：
- 把 UI、调试 gizmo、交互代理体、真实内容对象混在同一层
- 直接用全局变量跨模块引用场景节点

## 6. 生命周期

必须提供：

- `init()`
- `start()`
- `pause()`
- `resume()`
- `dispose()`

资源释放要贯穿运行时，不要等项目大了再补。

# Required checks

- 入口文件小于 100 行，主要负责装配
- 所有 service 的创建顺序明确
- 主循环步骤可读
- resize 只有一处
- dispose 能释放事件监听、动画、物理、WebGL 资源引用

# Common pitfalls

- 入口文件直接承担玩法逻辑
- 各系统互相 new 对方，造成循环依赖
- 把 `window` / DOM 操作散落到所有模块
- 没有 pause / resume，后面做菜单、后台切换、XR 时很痛苦

# Practical output template

1. 目录树
2. 运行时服务列表
3. 主循环伪代码
4. resize 流程
5. dispose 清单
6. 接下来应该接入哪个子 skill

# Official references

- Vite guide
- TypeScript strict mode docs
- three.js docs: WebGLRenderer, WebGPURenderer, Object3D, Timer
