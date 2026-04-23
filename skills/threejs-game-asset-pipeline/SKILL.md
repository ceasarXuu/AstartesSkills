---
name: threejs-game-asset-pipeline
description: Define and enforce a three.js game asset pipeline around glTF/GLB, compression, validation, naming conventions, runtime prefab assembly, and loader setup. Use when importing or normalizing 3D assets for real-time gameplay.
---

# Goal

把美术资源处理成适合游戏运行时使用的 three.js 资产流水线，重点是 **glTF / GLB**、压缩、验证、命名约定和运行时装配。

# Use this skill when

- 你要导入外部模型或动画到 three.js 游戏
- 你要做资源优化、压缩、命名规范与质量校验
- 你要定义“运行时资产格式”而不是只看 DCC 工具里的效果
- 你发现当前项目的模型原点、缩放、材质、命名、动画导入一团乱

# Required inputs

- 模型来源：Blender / Maya / 外包 / 商店资产 / 程序化生成
- 目标风格：低模 / 写实 PBR / 风格化
- 目标平台：桌面 / 移动 / XR
- 是否有骨骼动画、挂点、碰撞代理体、LOD

# Outputs

- 资产格式与压缩方案
- 导入规范
- 运行时命名约定
- 验证清单
- 一套 loader 装配建议

# Standards

- 运行时首选格式：`glTF / GLB`
- 颜色贴图、法线贴图、金属粗糙度贴图用途必须明确
- 所有可交互 / 可装备 / 可生成对象必须有稳定命名与原点规则
- 任何性能优化都不能破坏运行时必须依赖的命名节点、extras、动画 clips

# Workflow

## 1. 统一运行时格式

- 默认只接受 `glTF / GLB` 作为正式运行时资产
- `FBX / OBJ / blend` 等都视作源资产，不直接进入生产 runtime
- 加载统一走 `GLTFLoader`

## 2. 定义资产约定

至少定义：

- 坐标系与前向约定
- 尺寸单位
- 原点位置
- 根节点命名
- 动画 clip 命名
- 挂点命名，例如 `socket_weapon_r`, `socket_camera`
- 碰撞代理体命名，例如 `col_static`, `col_trigger`
- LOD 命名
- 是否允许负 scale

## 3. 压缩与优化链

默认建议：

- 几何压缩：Draco 或 Meshopt
- 纹理压缩：KTX2 / Basis
- 离线变换：glTF-Transform
- 包体与顶点缓存优化：gltfpack

但必须说明取舍：

- Draco 减体积，但会增加解码成本
- KTX2 很适合大纹理和移动端
- aggressive 优化前先确认不会吞掉命名节点和元数据

## 4. 运行时 loader 装配

检查是否需要：

- `setDRACOLoader`
- `setKTX2Loader`
- `setMeshoptDecoder`

并输出示例初始化方案。

## 5. 验证链

必须至少包含：

- glTF validator
- 可视化预检
- three.js 运行时 smoke test
- 动画 clip 枚举
- 材质与纹理引用检查
- 原点与缩放 spot check

## 6. 资产进入运行时后的结构

不要直接在业务代码里遍历整棵模型树做猜测。导入后应建立：

- `AssetRegistry`
- 预制体 / prefab 概念
- 命名节点查询封装
- 动画、挂点、碰撞代理体的二次索引

# Required checks

- 新资产能否通过同一条导入链进入项目
- 角色模型是否有稳定根节点
- 模型的默认 transform 是否合理
- 是否可直接枚举动画 clips
- 是否为关键对象建立 prefab 级封装

# Common pitfalls

- 使用 OBJ / FBX 直接充当运行时正式格式
- 把错误原点、错误 scale 的模型交给代码层“临时修”
- 没有命名约定，后续 socket / trigger / 装备全靠手写路径
- 优化器把挂点或 extras 弄没了才发现运行时依赖它们

# Deliverable template

1. 资产格式规范
2. 模型/动画/纹理命名规则
3. loader 装配代码建议
4. 压缩链建议
5. 验证步骤
6. 本轮要修复的高风险资产问题

# Official references

- three.js manual: load-gltf
- three.js examples/docs: GLTFLoader, DRACOLoader, KTX2Loader
- Khronos glTF spec, validator, sample models
- glTF-Transform docs
- meshoptimizer / gltfpack docs
