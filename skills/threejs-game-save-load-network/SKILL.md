---
name: threejs-game-save-load-network
description: Define save/load, snapshot, replay, and networking boundaries for a three.js game. Use when game state must be serialized, restored, synchronized, or replayed rather than existing only inside the current scene graph.
---

# Goal

为 three.js 游戏建立存档、快照、状态恢复和网络同步边界，避免后期才发现状态模型不可序列化、不可回放、不可同步。

# Use this skill when

- 你需要本地存档
- 你计划做多人同步或联机原型
- 你想支持回放、重播、checkpoint、关卡恢复
- 你想把逻辑状态与可视状态分离

# Required inputs

- 单机 / 多人 / 同步模式
- 是否有物理世界
- 是否需要回放 / 检查点
- 是否要离线存档
- 数据量与敏感度

# Outputs

- SaveSchema
- WorldState / ViewState 边界
- 同步策略
- 快照与恢复流程
- 运输层建议

# Standards

- 存档记录逻辑真相，不直接存整个 three.js scene 图
- 可视状态可重建，逻辑状态要可序列化
- 网络同步优先同步意图或权威状态，不同步无意义渲染细节
- 物理世界需要明确快照边界

# Workflow

## 1. 拆分状态层

至少区分：

- persistent game state
- transient runtime state
- derived visual state
- player profile / settings
- session-only data

## 2. 设计存档模型

建议最小字段：

- version
- world seed / level id
- player state
- inventory / quest / mission progress
- entity states
- timestamps
- checksum / migration hooks

## 3. 本地存储选择

- 小配置：localStorage 可接受
- 正式存档与大对象：IndexedDB 优先
- 二进制快照可单独存 blob / Uint8Array

## 4. 同步策略

### 单机
- checkpoint / autosave / manual save

### 多人
- authoritative server / host-client / P2P 明确选一种
- 输入同步、状态同步、事件同步各自边界要明确
- 对延迟、回滚、预测要有最小计划

## 5. 物理与回放

如果有物理：

- 是否需要物理世界 snapshot
- 哪些对象可用快照恢复
- 哪些对象由逻辑重建
- 是否追求 deterministic 或“足够接近”的回放

# Required checks

- 是否区分逻辑状态与可视状态
- 是否定义存档版本
- 是否说明本地存储介质
- 是否说明多人同步模式
- 是否考虑快照 / 回放需求

# Common pitfalls

- 直接序列化 three.js scene
- 没有版本迁移设计
- 单机逻辑写法导致未来无法联网
- 同步了太多视觉细节
- 物理对象恢复后与逻辑状态不一致

# Deliverable template

1. 状态分层图
2. SaveSchema
3. 存储介质建议
4. 网络同步模式
5. 回放 / 快照策略

# Official references

- MDN: IndexedDB, WebSocket API, RTCDataChannel
- Rapier docs: serialization / snapshots
