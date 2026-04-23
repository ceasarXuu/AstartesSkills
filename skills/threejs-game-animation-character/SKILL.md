---
name: threejs-game-animation-character
description: Build a maintainable three.js character-animation system with state graphs, clip conventions, retargeting, skeletal reuse, and optional IK. Use when gameplay depends on character or object animation beyond simple clip playback.
---

# Goal

为角色、NPC、武器和可动画对象建立可维护的动画系统，包括 clip 管理、状态图、骨骼重定向、IK 和动画事件。

# Use this skill when

- 项目里有角色动画或复杂对象动画
- 你要从“直接播 clip”升级到状态驱动动画系统
- 你要复用外部动作库或同骨架多角色
- 你需要 foot planting、aim、look-at、持武器、换装等能力

# Required inputs

- 动画资产来源
- 是否共用骨架
- 是否需要 locomotion blend
- 是否需要 IK、root motion、动画事件
- 是否有角色装备、载具、攀爬等特殊状态

# Outputs

- 动画状态图
- clip 命名与装配规范
- 角色动画控制层
- 重定向与 IK 策略

# Standards

- 运行时不允许用硬编码字符串到处直接播 clip
- 动画播放必须经过 Animator / CharacterAnimationController
- 状态切换条件必须清晰，不能全部散在玩法逻辑里
- 角色骨架、挂点、武器插槽要有稳定命名约定

# Workflow

## 1. 动画资源整理

列出：

- idle / locomotion / jump / fall / land
- attack / aim / hit / death
- interact / use / equip / holster
- upper-body overlays
- additive clips

## 2. 状态图

至少定义：

- locomotion
- airborne
- action
- reaction
- cinematic / disabled

如果是第三人称项目，还要说明：

- speed blend
- direction blend
- turn-in-place
- aim offset
- layer mask

## 3. 混合与切换

输出时要写清楚：

- 哪些过渡允许 blend
- 哪些动作必须硬切
- 是否支持 cancel windows
- 动画事件如何发回玩法层

## 4. 重定向与克隆

如果多角色共骨架或共享外部动作库：

- 使用骨骼重定向工具
- 明确哪些骨骼/挂点必须存在
- 输出角色 prefab 如何绑定动画控制器

## 5. IK 与局部修正

只在需要时启用：

- foot IK
- hand IK
- look-at
- weapon aim
- interaction reach

不要把 IK 作为默认全局魔法。

# Required checks

- 是否有 Animator 层而不是直接裸用 mixer
- 是否定义状态图
- 是否建立 clip 命名规则
- 是否对共骨架资源给出重定向方案
- 是否把动画事件回传到玩法层

# Common pitfalls

- 所有地方直接写 `mixer.clipAction('Run')`
- 角色状态和动画状态混成一锅
- 动画命名无规范，后面集成外部资源极其痛苦
- root motion 与代码位移没有明确边界
- IK 一开始就大范围铺开，调试成本爆炸

# Deliverable template

1. clip 清单
2. 状态图
3. 混合与切换规则
4. 角色 prefab 动画装配方式
5. IK / 重定向策略

# Official references

- three.js docs: AnimationMixer, AnimationAction, AnimationObjectGroup, SkeletonUtils, SkinnedMesh, CCDIKSolver
