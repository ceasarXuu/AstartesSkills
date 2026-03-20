# AstartesSkills

[English](README.md)

面向 Codex 和兼容代理的可安装 AI skills 仓库。

## 这是什么

`AstartesSkills` 是一个多-skill 仓库。每个 skill 都单独打包在自己的目录里，因此你可以只安装自己需要的部分。

你可以用这个仓库：

- 浏览可用 skills
- 从本地仓库安装一个或多个 skill
- 直接从 GitHub 安装指定 skill
- 把它当作自己的 skill 分发源

这个 README 是用户手册。仓库内部规则和维护约束放在 `AGENTS.md`。

## 当前可用 Skills

当前可安装示例包括：

- `hello-world`：最小示例 skill
- `custodes-coding-governor`：面向编码治理与执行规范的 skill

查看最新可安装 skills：

```bash
./scripts/list-skills.sh
```

## 安装

### 方式一：从本地克隆仓库安装

```bash
./scripts/install-skill.sh hello-world
```

一次安装多个 skills：

```bash
./scripts/install-skill.sh hello-world custodes-coding-governor
```

安装到自定义目录：

```bash
./scripts/install-skill.sh --target ~/.codex/skills hello-world
```

默认安装目录：

```text
${CODEX_HOME:-$HOME/.codex}/skills
```

### 方式二：直接从 GitHub 安装

```bash
curl -fsSL https://raw.githubusercontent.com/ceasarXuu/AstartesSkills/main/scripts/install-skill.sh \
  | bash -s -- --repo https://github.com/ceasarXuu/AstartesSkills.git hello-world
```

这个流程会：

- 临时克隆仓库
- 只复制你指定的 skill
- 将其安装到目标目录

## 如何使用已安装的 Skill

安装后，每个 skill 会出现在自己的目录下，例如：

```text
~/.codex/skills/hello-world
```

每个 skill 的核心说明都在该目录下的 `SKILL.md`。代理会根据里面的触发条件和说明决定是否启用这个 skill。

## 仓库结构概览

```text
.
├── skills/                     # 可安装 skills
├── registry/                   # 仓库级目录
├── scripts/                    # 安装/校验/导出工具
└── docs/                       # 计划与运行手册
```

## 面向维护者

如果你的目标是维护或扩展这个仓库，而不只是使用其中的 skill：

- 项目规则与约束：`AGENTS.md`
- 贡献流程：`CONTRIBUTING.md`

## 排障

建议先执行：

```bash
./scripts/list-skills.sh
./scripts/validate-repo.sh
```

如果安装失败，优先查看带有 `[install]` 或 `[validate]` 前缀的日志输出。
