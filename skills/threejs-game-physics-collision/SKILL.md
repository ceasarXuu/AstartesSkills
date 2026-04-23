---
name: threejs-game-physics-collision
description: Design a collision and physics layer for a three.js game, including character movement, collision layers, scene queries, and engine-adapter boundaries. Use when gameplay needs robust contact, blocking, triggers, or rigid-body behavior.
---

# Goal

为 three.js 游戏建立碰撞与物理层的正确边界，区分“世界碰撞”“角色控制”“刚体模拟”“查询系统”和“游戏判定”。

# Use this skill when

- 你要给角色加地面碰撞、墙体阻挡、台阶、坡面、跳跃
- 你要引入完整物理引擎或设计一个轻量碰撞层
- 你要统一射线、重叠、触发器和物理世界查询
- 你要避免把玩法逻辑和物理实现绑死

# Required inputs

- 游戏类型：FPS / platformer / sandbox / driving / physics puzzler
- 是否需要完整刚体
- 是否需要网络同步 / 回放 / 快照
- 世界是否静态为主
- 是否已有碰撞代理体资源

# Outputs

- PhysicsAdapter
- 碰撞层矩阵
- 角色控制器方案
- 查询 API 约定
- 引擎选型建议

# Standards

- 不把 three.js mesh 直接当物理世界唯一真相
- 可视 mesh 与碰撞代理体可以不同
- 角色控制器、刚体模拟、trigger 查询要分开建模
- 玩法系统通过适配层调用物理，不直接深绑底层引擎 API

# Workflow

## 1. 先选路线

### 静态世界 + 角色移动为主
可优先：
- Octree / BVH / 自定义轻量碰撞层

### 需要完整刚体、character controller、scene queries、快照
优先：
- Rapier

### 只是轻量原型
可接受：
- cannon-es 或更轻方案

## 2. 建立碰撞层矩阵

至少定义：

- player
- enemy
- world-static
- world-dynamic
- trigger
- projectile
- pickup
- ui-proxy / debug

输出矩阵必须明确谁与谁碰撞、谁与谁只重叠不阻挡。

## 3. 角色控制器

必须明确：

- 水平移动
- 重力
- 落地检测
- 台阶
- 坡面
- 墙滑
- 跳跃窗口 / coyote time（如果玩法需要）
- moving platform 规则（如果玩法需要）

## 4. 查询系统

统一封装：

- raycast
- shape cast / sweep
- overlap
- ground probe
- line of sight

不要让玩法代码直接到处调用底层引擎实例。

## 5. 同步与快照边界

如果项目需要多人或回放，要提前说明：

- 哪些对象是物理驱动
- 哪些对象是逻辑驱动
- 是否需要 deterministic 或近似 deterministic 方案
- 是否要用物理世界 snapshot

# Required checks

- 是否建立 PhysicsAdapter
- 是否给角色控制器写清楚行为规则
- 是否定义碰撞层矩阵
- 是否区分可视 mesh 和碰撞代理体
- 是否统一物理查询 API

# Common pitfalls

- 拿渲染 mesh 直接做所有碰撞
- 角色控制器与刚体混在一套不清不楚的逻辑里
- 没有碰撞层矩阵，后期弹丸、拾取物、触发器冲突混乱
- 先写了大量玩法判定，后面才发现没有稳定地面检测
- 网络需求出现后才想起物理世界无法快照

# Deliverable template

1. 引擎路线选择
2. 碰撞层矩阵
3. 角色控制器规则
4. 查询接口设计
5. 同步 / 回放风险说明

# Official references

- three.js docs/examples: Octree, games_fps
- Rapier docs: character controller, scene queries, serialization
- cannon-es docs
- three-mesh-bvh docs for accelerated queries
