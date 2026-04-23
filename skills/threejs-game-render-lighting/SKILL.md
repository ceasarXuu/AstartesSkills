---
name: threejs-game-render-lighting
description: Set a three.js game rendering baseline for color management, PBR, lighting, environment maps, shadows, transparency, and post-processing. Use when visual consistency, performance budgets, and WebGL/WebGPU boundaries need to be defined.
---

# Goal

建立 three.js 游戏项目的渲染基线：颜色空间、PBR、灯光、阴影、透明、后处理和渲染预算。

# Use this skill when

- 你要为游戏项目定渲染基线
- 你发现颜色、亮度、透明、阴影、环境光照表现不稳定
- 你要从 demo 级画面升级到可控的生产画面
- 你要区分 WebGL 稳态路径和 WebGPU 增强路径

# Required inputs

- 视觉目标：写实 / 半写实 / 卡通 / 复古 / 极简
- 平台与性能预算
- 是否使用后处理
- 是否需要玻璃、水面、植被、发光、体积感等效果

# Outputs

- 渲染设置基线
- 灯光与环境策略
- 阴影预算
- 透明策略
- 后处理使用边界
- 兼容矩阵说明

# Standards

- 明确颜色空间：工作流程基于 linear-sRGB
- 颜色贴图按 sRGB 处理，非颜色数据贴图保持线性
- 写实 / 半写实默认优先使用 PBR 材质
- 阴影不是默认全开，而是预算驱动
- 透明对象要单独制定策略，不允许“全 transparent 糊过去”

# Workflow

## 1. 建立 renderer 视觉基线

必须输出：

- output color space
- tone mapping 方案
- exposure 策略
- 是否启用 physically correct lights 风格工作流
- 是否需要后处理链

## 2. 环境光照策略

默认优先：

- `scene.environment`
- HDRI / PMREMGenerator
- 缺省环境可用临时环境贴图占位

如果没有环境贴图却要求写实金属材质，先指出问题，不要硬调 directional light 强行顶替。

## 3. 阴影预算

先判断：

- 主阴影光源数量
- 是否真的需要 point light 阴影
- 哪些对象需要投射阴影
- 哪些对象只接收阴影或用 fake shadow

输出应包含：

- 阴影分辨率层级
- 可投射阴影对象名单
- 必须禁用阴影的对象名单
- 远景与小物体替代方案

## 4. 透明与排序

按对象类别定义：

- 植被 / 栅栏 / 毛发：优先 `alphaTest` 风格
- 玻璃 / 液体：谨慎使用 `transparent`
- 双面透明：需要单独测试，不要默认依赖排序
- 特殊对象必要时拆 mesh、拆 pass

## 5. 后处理策略

WebGL 路径可考虑：

- RenderPass
- Bloom
- SSAO / AO
- Color grading
- FXAA / SMAA
- OutputPass

但要明确：

- 后处理是预算驱动的
- 不允许在移动端默认堆多个高成本 pass
- 有些问题应先靠内容与材质解决，而不是强行靠 post stack

## 6. WebGPU / TSL 边界

只有在以下情况再建议 WebGPU / TSL 进阶：

- 大量 GPU 驱动效果
- 程序化材质
- 粒子 / compute 场景
- 明确接受平台兼容性差异

否则先稳在 WebGL。

# Required checks

- 是否明确区分颜色贴图与数据贴图
- 是否有环境光照来源
- 是否列出阴影预算
- 是否对透明对象分了类
- 是否根据平台限制后处理堆栈

# Common pitfalls

- 颜色空间没定，后面所有材质都乱
- 用多个投影阴影光源硬堆“高级感”
- 把所有薄片物体都做成透明
- 用强 bloom 掩盖材质和光照问题
- WebGPU 还没必要就提前全迁

# Deliverable template

1. 渲染基线设置
2. 灯光与环境方案
3. 阴影预算表
4. 透明对象处理策略
5. 后处理建议
6. WebGL / WebGPU 兼容说明

# Official references

- three.js manual: color-management, shadows, transparency, post-processing
- three.js docs: WebGLRenderer, PMREMGenerator, EffectComposer, OutputPass
- three.js TSL / WebGPU docs
