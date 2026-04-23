---
name: threejs-game-materials-tsl-vfx
description: Implement custom materials, TSL, procedural shaders, particle systems, and advanced visual effects for a three.js game while keeping WebGL and WebGPU paths explicit. Use when built-in materials are no longer sufficient.
---

# Goal

为 three.js 游戏实现程序化材质、自定义 shader、TSL 和高性价比视觉特效，并明确 WebGL 与 WebGPU 路径边界。

# Use this skill when

- 你要做风格化材质、GPU 粒子、程序化动画、特殊后效
- 你要用 TSL / WebGPU 但不想把项目整体拖进不必要的兼容风险
- 你要规范自定义材质的工程化方式
- 你要在效果实现时保住性能和可维护性

# Required inputs

- 目标效果列表
- 平台与兼容目标
- 是否允许 WebGPU only 能力
- 是否需要 compute
- 是否需要与阴影、后处理、instancing 协同

# Outputs

- 效果实现路径
- 材质组织方式
- WebGL / WebGPU 分流方案
- 性能与调试边界

# Standards

- 默认优先内置材质；只有在内置材质无法满足时才自定义
- 所有自定义材质必须归档到统一 MaterialLibrary
- 特效必须明确属于：对象材质、后处理、屏幕空间、粒子、实例驱动、compute 驱动
- 不允许把效果逻辑和玩法状态直接缠死在同一个 shader 巨石里

# Workflow

## 1. 先分类效果

- 材质改造：表面风格、边缘光、扫描线、卡通分层
- 几何/顶点变形：旗帜、草地、波浪、抖动
- 粒子：子弹轨迹、爆炸、雾、雪
- 屏幕空间：bloom、outline、retro、motion blur
- 大规模状态驱动：群体颜色、命中闪烁、热力图
- GPU compute：大量粒子 / 仿真 / 高级程序化

## 2. 决定实现路径

### WebGL 稳定线
优先：
- 内置材质参数
- `onBeforeCompile`
- ShaderMaterial / RawShaderMaterial
- EffectComposer 路线
- instancing + attributes / data textures

### WebGPU / TSL 增强线
适用于：
- TSL node materials
- compute
- storage buffers
- 更复杂的 GPU 数据流

## 3. 阴影与深度兼容

凡是顶点位移、程序化透明、特殊深度行为，都要检查：

- 阴影深度材质是否需要单独覆盖
- picking / collision 是否仍与可视表现一致
- motion vectors / post 效果是否需要补充数据

## 4. 实例化与批量状态

海量对象优先考虑：

- InstancedMesh
- InstancedBufferAttribute
- 颜色 / 状态表
- DataTexture / storage buffer

## 5. 调试与回退

所有高阶效果都必须给出：

- 低配 fallback
- 调试开关
- 性能开关
- 平台支持声明

# Required checks

- 是否先确认内置材质不够用
- 是否把效果分了类型
- 是否有 WebGL / WebGPU 分流
- 是否检查阴影/深度兼容
- 是否提供 fallback

# Common pitfalls

- 为了一个小效果直接重写整套材质体系
- shader 里硬塞玩法状态
- 只在主机上看过效果，移动端直接爆
- 顶点位移后阴影不对却没有 custom depth material
- WebGPU 特性不做 fallback 就默认上线

# Deliverable template

1. 效果清单及分类
2. 每个效果的实现路径
3. WebGL / WebGPU 兼容说明
4. 性能预算与 fallback
5. 调试方案

# Official references

- three.js docs: TSL, WebGLRenderer.setNodesHandler, InstancedBufferAttribute, StorageInstancedBufferAttribute, Object3D.customDepthMaterial
- three.js examples: webgpu_postprocessing*, node materials, particles
- EffectComposer docs for WebGL post-processing
