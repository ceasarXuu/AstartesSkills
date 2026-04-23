---
name: threejs-game-tooling-qa-release
description: Create a quality workflow for a three.js game with tests, asset validation, visual regression, browser coverage, and release checklists. Use when a project needs repeatable verification rather than ad-hoc manual checking.
---

# Goal

为 three.js 游戏建立持续可执行的质量体系：测试、资产校验、可视回归、跨浏览器检查与发布清单。

# Use this skill when

- 你要给 three.js 游戏项目建立工程质量基线
- 你希望 agent 在改功能时顺手补验证
- 你需要资产导入回归、交互 smoke test、视觉回归与发布检查
- 你要避免“改一个 shader，坏了半个项目但没人知道”

# Required inputs

- 测试环境：本地 / CI
- 浏览器覆盖范围
- 是否需要移动端模拟
- 是否存在关键资产流水线
- 是否已有测试框架

# Outputs

- 测试策略
- QA 清单
- 资产验证流程
- 发布检查单
- 最小自动化建议

# Standards

- 单元测试负责纯逻辑与工具函数
- 集成 / E2E 测试负责关键玩法流和页面行为
- 资产验证必须成为固定流程
- 发布前必须做跨浏览器与性能 spot check

# Workflow

## 1. 测试分层

### 单元测试
用于：
- 数学工具
- 游戏规则纯函数
- SaveSchema 迁移
- 输入映射转换
- 配置解析

### 集成测试
用于：
- 运行时装配
- 资产注册表
- 动画控制器状态切换
- 物理适配层输出

### E2E / 浏览器测试
用于：
- 启动游戏
- 加载关卡
- 进入菜单
- 基础移动与交互
- 关键 UI
- 存档恢复 smoke test

## 2. 资产 QA

固定至少检查：

- glTF validator
- 动画 clip 枚举
- 材质与纹理完整性
- 命名约定
- 关键 prefab 是否包含必须节点

## 3. 视觉回归

选择关键场景：

- 主菜单
- 白天 / 夜晚或不同灯光场景
- 角色近景
- 大场景远景
- 强透明 / 特效场景

## 4. 发布检查

发布前至少确认：

- 构建模式与 sourcemap 策略
- 关键设备与浏览器 smoke test
- 资源路径正确
- 包体和首屏加载未回退
- 关键输入设备可用
- 重要异常日志为零或已知可接受

# Required checks

- 是否明确测试分层
- 是否把资产验证纳入流程
- 是否列出视觉回归场景
- 是否有发布 checklist
- 是否覆盖关键浏览器与设备

# Common pitfalls

- 只测纯函数，不测实际加载与交互
- 资产坏了只能靠人工在场景里偶然发现
- 视觉回归全靠肉眼记忆
- 发布前不做跨浏览器检查
- 把所有 QA 都拖到最后一天

# Deliverable template

1. 测试分层表
2. 资产 QA 清单
3. 视觉回归清单
4. 发布检查单
5. 推荐接入的自动化最小集合

# Official references

- Vitest docs
- Playwright docs
- Khronos glTF validator / sample models / sample viewer
