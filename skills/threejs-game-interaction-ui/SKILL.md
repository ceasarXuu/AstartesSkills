---
name: threejs-game-interaction-ui
description: Implement world interaction, picking, triggers, HUD coordination, and world-space UI patterns for a three.js game. Use when scene objects must become robust interactive gameplay entities instead of raw meshes.
---

# Goal

为 three.js 游戏建立稳定的世界交互层，包括拾取、触发器、交互提示、HUD、世界空间 UI 和事件路由。

# Use this skill when

- 你要做点击、瞄准、射线交互、拾取、开门、触发器
- 你要把“场景对象”变成“可交互游戏实体”
- 你要建立屏幕 UI 与世界对象之间的联系
- 你要区分 CPU picking、GPU picking、碰撞触发和 UI 事件

# Required inputs

- 交互类型：射线、区域触发、点击、长按、hover、瞄准、使用键
- 目标对象规模与数量
- 是否包含 skinned mesh、透明对象、程序化变形对象
- UI 类型：HUD、世界空间标签、准星、提示、背包、菜单

# Outputs

- PickingService 设计
- 交互状态机
- HUD / world-space UI 连接方式
- 交互层与渲染层分离规则

# Standards

- 所有交互对象必须有明确组件或标签，不靠名字硬猜
- Raycaster 不是唯一方案；对象类型复杂时要显式判断是否切 GPU picking
- UI 事件和世界交互事件必须解耦
- 交互候选筛选优先用 layers / tags / registries，而不是全场景暴力遍历

# Workflow

## 1. 选择交互方式

### Raycaster 适合
- 稀疏对象
- 地面点选
- 使用键对准交互
- 子弹 / 视线 / 放置点

### GPU picking 适合
- 大量可选对象
- skinned mesh
- shader 变形
- 透明洞孔复杂对象
- 对 CPU raycast 正确性不满意的场景

### Trigger volumes 适合
- 区域进入 / 离开
- 自动门
- 检查点
- 危险区
- 任务触发

## 2. 建立交互状态机

至少定义：

- `idle`
- `candidate`
- `focused`
- `armed`
- `interacting`
- `cooldown`

并说明每个状态的 UI 表现。

## 3. UI 连接规则

- HUD 只展示交互状态和关键反馈
- 世界空间标签必须有距离、遮挡、视野规则
- 不允许世界对象自己直接操作完整 HUD 树
- 所有交互提示从 InteractionService 统一发出

## 4. 交互事件约定

建议事件：

- `interaction:candidate-changed`
- `interaction:started`
- `interaction:completed`
- `interaction:cancelled`
- `trigger:enter`
- `trigger:exit`

## 5. 复杂对象特殊处理

如果对象具备以下任一条件，先列风险：

- 骨骼动画
- 顶点位移
- 大面积透明
- 多层嵌套子节点
- 需要不同部位命中

# Required checks

- 是否定义了交互实体标记方式
- 是否区分 raycast、trigger、GPU picking
- 是否规定 HUD 只通过服务层更新
- 是否为复杂对象说明命中策略
- 是否过滤了不应被交互的图元

# Common pitfalls

- 直接对全场景做 raycast
- 所有对象都用名字判断是否可交互
- skinned mesh 命中不准却不解释原因
- UI 和世界对象互相直接引用
- 一个交互里同时夹杂物理、剧情、UI、存档更新且无事件边界

# Deliverable template

1. 交互方式选择
2. 交互实体建模方式
3. 状态机
4. HUD / world-space UI 更新规则
5. 风险对象列表

# Official references

- three.js manual: picking
- three.js docs: Raycaster, Layers, InteractiveGroup
