# AstartesSkills Agent Guide

本文件面向仓库协作者、代码代理与维护者。`README.md` 和 `README.zh-CN.md` 只保留给最终用户的使用说明。

## 项目定位

`AstartesSkills` 是一个多-skill 仓库，用于统一维护、验证、导出和分发多个可独立安装的 AI skills。

目标：

- 支持 skills market 分发
- 支持 GitHub 直接安装
- 保持每个 skill 可独立复制、安装、发布
- 用统一注册表、校验脚本和导出脚本管理整个仓库

## 仓库结构

```text
.
├── skills/                     # 所有可安装 skills
│   ├── _templates/             # 新 skill 模板
│   └── <skill-id>/             # 独立 skill 包
├── registry/                   # 仓库级目录与分发元数据
├── scripts/                    # 安装、列举、校验、导出工具
├── docs/
│   ├── plans/                  # 设计与实施记录
│   ├── runbooks/               # 可复用操作经验
│   └── tobeSkills/             # 长文草稿/想法沉淀
└── .github/workflows/          # CI 校验
```

单个 skill 建议结构：

```text
skills/<skill-id>/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── markets/                    # 可选
├── references/                 # 可选
├── scripts/                    # 可选
└── assets/                     # 可选
```

## 工作原则

### 最小化提交原则

- 每次围绕一个小主题修改
- 小主题完成后积极提交，增强开发轨迹与回滚能力
- 不把多个无关改动揉进同一批修改

### 日志驱动原则

- 新增功能或修复 bug 后，补充日志与可观测性建设
- 安装、校验、导出等脚本要输出明确日志前缀
- 可复用的排障、发布、环境操作经验写入 `docs/runbooks/`

### 独立自驱原则

- 除产品设计决策外，默认自行推进，不把执行型决策抛给用户
- 优先自己获取日志、复现问题、验证修复
- 回复要给出解决方案，而不是把执行工作转交给用户

### 直面问题

- 优先修真实根因
- 避免以绕过、兜底、静默屏蔽代替修复
- 若必须做兼容或保护措施，需要说明覆盖的真实风险

### 修复闭环

- bug 修复后必须自行复查
- 只有在确认无法复现或验证通过后，才可视为完成
- 若无法验证，需要明确说明阻塞条件和剩余风险

### 经验沉淀

- 启动、登录、环境配置、拉日志、打包、上传、发布等高摩擦操作，做完后记录经验
- 新经验优先写入 `docs/runbooks/operational-notes.md`
- 避免重复踩坑、重复摸索

### Skills 演化

- 如果实际执行表明某个 skill 指引不准确、不完整或不适用，可以直接修正
- 修正应基于真实成功/失败案例，而不是抽象猜测
- skill 本身也应像代码一样持续迭代

### Skills 发布记录

- 每次编辑任意 skill，都必须同步记录本次发布元数据
- 发布元数据至少包含：`version`、`published_at`、`publisher`、`changes`
- `published_at` 使用本地时区的 ISO 8601 时间字符串
- `changes` 使用简洁变更列表，概括这次编辑实际带来的修改
- 发布元数据必须同时更新到该 skill 的市场清单文件和 `registry/skills.json`
- 若发布元数据未更新，则该次 skill 编辑视为未完成

## 子代理使用约束

- 鼓励使用 subagents 提升效率，但只允许以下组合
- `gpt-5.4` + `medium`
- `gpt-5.4` + `low`
- `gpt-5.4-mini`
- 仅在任务可清晰拆分、能并行推进时使用
- 子代理产出需要主代理复核后再落地

## 仓库级工作流

### 新增 skill

1. 复制 `skills/_templates/basic-skill`
2. 重命名为最终 `skill id`
3. 编写 `SKILL.md`
4. 补齐 `agents/openai.yaml`
5. 如需市场发布，补充 `markets/` 元数据与发布记录
6. 在 `registry/skills.json` 中注册，并同步发布记录
7. 运行 `./scripts/validate-repo.sh`
8. 需要导出时运行 `./scripts/export-marketplace.py`

### 维护已有 skill

1. 先读该 skill 的 `SKILL.md`、`agents/openai.yaml` 与相关市场元数据
2. 保持 skill 自包含，避免把运行依赖散落到仓库外
3. 修改后同步更新版本号、发布时间、发布者、变更内容
4. 执行校验
5. 若本次操作带来新经验或新坑，更新 runbook

## 文档分工

- `README.md`：给最终用户，英文默认入口
- `README.zh-CN.md`：给最终用户的中文手册
- `AGENTS.md`：给仓库维护者、协作者、代理的项目说明与约束
- `CONTRIBUTING.md`：贡献流程的简版摘要

## 常用命令

```bash
./scripts/list-skills.sh
./scripts/validate-repo.sh
./scripts/export-marketplace.py
```

如修改了安装路径、注册表或市场清单，至少执行一次 `./scripts/validate-repo.sh`。
