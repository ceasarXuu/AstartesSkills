---
name: threejs-game-input-camera
description: Design a device-agnostic input abstraction and camera-control baseline for a three.js game, including keyboard, mouse, pointer lock, gamepad, touch, and mode switching. Use when gameplay input must stay stable across devices and states.
---

# Goal

把键鼠、手柄、触摸和 XR 控制等原始设备输入抽象成稳定的游戏动作层，并建立相机控制基线。

# Use this skill when

- 你要实现 FPS、TPS、top-down 或 sandbox 相机
- 你要同时支持多种输入设备
- 你想避免玩法代码直接读取 DOM 事件
- 你要为菜单态、暂停态、输入焦点切换建立规则

# Required inputs

- 游戏视角类型
- 目标输入设备
- 是否需要 Pointer Lock
- 是否需要游戏手柄或触摸控制
- 是否有 UI 覆层与输入焦点切换

# Outputs

- 输入抽象层
- 动作映射表
- 相机控制器基线
- 菜单 / 战斗 / 载具 / 观战等模式切换规则

# Standards

- 原始事件只进入 InputService
- 玩法层只消费 action / axis / state
- 不允许到处直接监听 `window.addEventListener('keydown', ...)`
- Pointer Lock 必须有锁定、解锁、失败、失焦处理
- 手柄与触摸必须走同一套 action 语义

# Workflow

## 1. 定义动作层

至少分成：

- digital actions：jump / interact / fire / sprint
- analog axes：moveX / moveY / lookX / lookY
- system actions：pause / openMenu / toggleInventory

## 2. 设备到动作的映射

为每个平台建立映射表：

- keyboard
- mouse
- gamepad
- touch
- XR controllers（如果适用）

输出时要明确死区、灵敏度、反转和加速度策略。

## 3. 相机控制器选择

### FPS
- Pointer Lock
- yaw / pitch 分离
- 垂直角度限制
- 灵敏度与 smoothing 可配置

### TPS
- follow target
- orbit offset
- 碰撞拉近 / 防穿模策略
- 锁定目标时的 look-at 规则

### top-down / RTS
- 平移
- 边缘滚屏 / 拖拽
- 缩放与倾角约束

## 4. 输入模式

至少区分：

- gameplay
- menu
- text input
- paused
- cutscene
- debug

不同模式下哪些 action 有效，必须显式说明。

## 5. 失焦与恢复

必须处理：

- tab 切走
- pointer lock 解除
- gamepad 断连
- 浏览器手势 / 权限拒绝

# Required checks

- 是否有统一 InputService
- 是否定义 ActionMap
- 是否有输入模式切换
- 是否明确 Pointer Lock 边界
- 是否处理手柄 / 触摸与 UI 焦点冲突

# Common pitfalls

- 玩法代码直接依赖 DOM 事件
- 键盘版和手柄版走不同逻辑
- Pointer Lock 没有退出和重进策略
- UI 输入与游戏输入互相抢焦点
- look 输入没有帧率无关化

# Deliverable template

1. 设备映射表
2. ActionMap
3. 相机控制规则
4. 输入模式与切换
5. 失焦恢复策略

# Official references

- three.js docs: PointerLockControls
- MDN: Pointer Lock API, Gamepad API
- WebXR input profiles docs if XR is in scope
