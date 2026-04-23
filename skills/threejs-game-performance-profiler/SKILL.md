---
name: threejs-game-performance-profiler
description: Set budgets and profiling workflows for a three.js game, covering draw calls, memory, lifecycle cleanup, streaming, batching, and CPU/GPU bottlenecks. Use when performance work needs to become systematic rather than reactive.
---

# Goal

把性能工作从“事后救火”变成持续预算管理，覆盖 draw calls、GPU/CPU、内存、资源生命周期、流式加载和调试仪表。

# Use this skill when

- 你要为 three.js 游戏建立持续性能基线
- 你遇到掉帧、内存增长、包体大、场景切换泄漏
- 你要在大地图、海量对象、重资产项目中控制成本
- 你需要明确优化优先级

# Required inputs

- 目标帧率
- 目标设备等级
- 当前瓶颈迹象：GPU、CPU、加载、内存、GC、网络
- 内容特征：大量小物件、重贴图、动画角色、粒子、后处理

# Outputs

- 性能预算表
- 观察指标
- 优化优先级
- 生命周期清理清单
- 流式加载策略

# Standards

- 先测再改
- 优先减少 draw calls，再看 shader 与主线程
- 资源显式管理
- 任何长期存在的场景切换都必须有 unload / dispose 路径
- 不允许把所有问题都归因于“three.js 不行”

# Workflow

## 1. 建立预算

至少输出：

- frame budget
- draw call budget
- triangle budget
- texture memory budget
- post-processing budget
- CPU main thread budget
- loading budget

## 2. 接监控

必须建议或输出：

- `renderer.info`
- 自定义 PerfHUD
- FPS / frame time
- 场景加载计时
- 关键系统 update 时间
- 资源数（geometry / texture / material / render target）

## 3. 优化优先级

默认顺序：

1. 先减少 draw calls
2. 统一材质与实例化
3. 控制贴图尺寸与格式
4. 处理阴影、透明、后处理
5. 处理 CPU 热点
6. Worker / OffscreenCanvas 之类更重的改造

## 4. 静态与批处理

优先检查：

- InstancedMesh
- BatchedMesh
- LOD
- 静态对象关闭自动矩阵更新
- 剔除策略
- 代理对象与真正可见对象的分离

## 5. 资源生命周期

必须有：

- texture / geometry / material dispose
- render target dispose
- event listener clean-up
- asset registry reference counting 或近似策略
- scene unload 时的统一释放函数

## 6. 流式加载

对大地图或多关卡项目，至少定义：

- 何时 preload
- 何时激活
- 何时卸载
- 何时保留在缓存
- 视野 / 距离 / 区域触发加载规则

# Required checks

- 是否给出预算数值或范围
- 是否接了 renderer.info
- 是否列出 draw call 优化路径
- 是否有 dispose 清单
- 是否有场景切换 / 大地图流式策略

# Common pitfalls

- 没测就开始微优化
- 每个对象一个材质导致 draw calls 爆炸
- 资源切场景后没释放
- 为了优化而过早引入复杂并行架构
- 把移动端问题当成桌面端问题硬调参数

# Deliverable template

1. 当前瓶颈判断
2. 预算表
3. 最优先优化项
4. 生命周期清理清单
5. 中长期流式加载方案

# Official references

- three.js docs: renderer.info, InstancedMesh, BatchedMesh, LOD, WebGPUTimestampQueryPool
- three.js manual: cleanup
- MDN: OffscreenCanvas
