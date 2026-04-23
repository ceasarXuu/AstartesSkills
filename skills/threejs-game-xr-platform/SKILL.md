---
name: threejs-game-xr-platform
description: Add WebXR support to a three.js game with controller mapping, interaction design, comfort rules, and XR-specific rendering constraints. Use when building or extending a game for VR, MR, or other XR platforms.
---

# Goal

为 three.js 游戏接入 WebXR，并把 XR 交互、控制器、相机、UI 和性能预算纳入统一工程规范。

# Use this skill when

- 你要做 VR / MR / XR 版 three.js 游戏
- 你要把现有桌面项目扩展到 XR
- 你要设计 XR 控制器、交互、UI 和舒适度规范
- 你要明确 WebGPU 与 XR 的现阶段边界

# Required inputs

- XR 类型：VR / AR / MR
- 设备目标
- 输入方式：手柄 / 手势 / gaze / pointer
- 是否已有桌面版玩法
- 是否需要 room-scale、teleport、grab、UI panel

# Outputs

- XR 接入流程
- 控制器与交互映射
- 舒适度与移动策略
- UI / HUD 策略
- 兼容与回退方案

# Standards

- XR 不是简单把相机换成 headset 视角
- 桌面端交互逻辑不能直接生搬到 XR
- 舒适度优先，移动与转向必须谨慎
- XR 平台差异与后端差异必须写明

# Workflow

## 1. 建立 XR 模式切换

至少定义：

- 非 XR 模式
- 进入 XR
- XR 暂停 / 退出
- XR 特有输入源注册与释放

## 2. 输入与交互

明确映射：

- trigger / squeeze / thumbstick / buttons
- pointing / ray interaction
- grab / drop / use
- UI panel 点击
- teleporter 或 snap-turn

## 3. 相机与移动

至少考虑：

- room-scale 与 seated 模式差异
- 传送移动
- snap turn / smooth turn
- 高度校准
- 双手交互 / 主手副手规则

## 4. UI 与反馈

XR 中应区分：

- 世界空间 UI
- 手腕 / 控制器附着 UI
- 菜单面板
- 瞄准 / 指示线 / 交互反馈

## 5. 渲染与性能

必须明确：

- XR 帧率目标
- 哪些后处理不可用或需谨慎
- 阴影预算更严
- WebGPU / WebGL backend 限制

# Required checks

- 是否定义 XR 进入退出流程
- 是否定义控制器映射
- 是否定义舒适度移动规则
- 是否说明 UI 在 XR 中的形态
- 是否说明 WebGPU / XR 边界

# Common pitfalls

- 直接复制桌面控制逻辑到 XR
- 平滑移动和平滑转向默认全开
- HUD 还贴在屏幕上而不是世界或控制器空间
- 忽视性能预算
- 不说明当前渲染后端的 XR 限制

# Deliverable template

1. XR 模式流程
2. 输入映射
3. 移动与舒适度策略
4. UI 设计原则
5. 性能与兼容说明

# Official references

- three.js docs: WebXRManager, XRControllerModelFactory, InteractiveGroup
- WebXR device API docs
