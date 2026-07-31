# Operational Notes

## 2026-03-21 Repo Initialization

- Problem: empty repository needed a structure that supports both market publishing and GitHub direct install
- Decision: keep each skill self-contained under `skills/`, then add repo-level discovery with `registry/skills.json`
- Why it worked: market metadata stays near each skill, while install tooling and validation stay centralized
- Reuse later: future install, packaging, and publishing tooling should continue treating each skill folder as the deployable unit

## 2026-03-21 First Real Skill Onboarding

- Problem: converting a draft document under `docs/tobeSkills/` into the first installable and exportable skill
- Decision: keep the source idea document in `docs/tobeSkills/`, but distill the actual reusable skill into a concise `SKILL.md` plus `agents/` and `markets/` metadata
- Why it worked: the long-form ideation doc remains available for iteration, while the shipped skill stays compact enough for real triggering and marketplace use
- Reuse later: when drafting future skills, write exploratory docs first if needed, then compress them into portable skill packages rather than shipping the drafts directly

## 2026-03-21 Documentation Split For Users vs Maintainers

- Problem: `README.md` was mixing end-user instructions with repository governance, making both audiences scan irrelevant content
- Decision: move project description, constraints, and maintainer norms into root `AGENTS.md`; keep `README.md` user-facing only; add `README.zh-CN.md` as a dedicated Chinese manual linked from the English default entry
- Why it worked: end users get a cleaner install/use path, while maintainers and agents have a single authoritative governance document
- Reuse later: repository-wide conventions go to `AGENTS.md`; user-facing setup and usage guidance stays in the README manuals

## 2026-03-21 Codex GUI Missing CODEX_HOME

- Problem: skills were visible in session metadata, but `CODEX_HOME` was empty inside Codex app and shell subprocesses, which makes path-dependent tooling and automation state brittle
- Root cause: macOS GUI apps launched by `launchd` do not inherit shell startup files such as `~/.zprofile` and `~/.zshrc`; meanwhile local shell config also had no explicit `CODEX_HOME`
- Decision: define `CODEX_HOME=/Volumes/XU-1TB-NPM/devtools/codex/home` in `~/.zprofile` for login shells, in `~/.local/bin/env` for interactive/helper shells, and add `~/Library/LaunchAgents/com.xuzhang.codex-env.plist` to run `launchctl setenv CODEX_HOME ...` at login for GUI apps
- Why it worked: terminal shells, helper scripts, and the Codex desktop process now converge on the same home directory instead of relying on implicit defaults
- Reuse later: whenever Codex desktop can see files but environment-dependent features behave inconsistently, check both shell exports and `launchctl getenv CODEX_HOME` before debugging skills or automations

## 2026-03-26 Packaging-Heavy Skill Authoring

- Problem: a new skill needed rich packaging logic, but putting all design guidance directly into `SKILL.md` would make triggering noisy and inflate context usage
- Decision: keep `SKILL.md` limited to trigger conditions, workflow, evidence discipline, and output contract; move scoring logic into `rubrics/`, reusable output shapes into `templates/`, and style calibration into `examples/`
- Why it worked: the installable skill stays concise enough to trigger cleanly, while still shipping the heavier guidance needed for multi-audience output
- Reuse later: when a skill needs deep judgment frameworks, split the portable package into `SKILL.md` plus selectively loaded supporting files instead of shipping one oversized instruction file

## 2026-03-26 Versioned Output For Document-Producing Skills

- Problem: a packaging skill that only returns inline text makes repeated runs hard to compare, archive, and reuse inside the target repo
- Decision: define a repo-root output contract of `show-my-repo/YYYYMMDD_vN/presentation-pack.md`, creating the root folder when absent and incrementing the version within the same day
- Why it worked: every run gets a deterministic landing zone, and repeated revisions on the same date remain ordered without overwriting older artifacts
- Reuse later: when a skill's main value is a reusable document, give it a default write path and versioning convention instead of leaving persistence to ad-hoc operator behavior

## 2026-03-26 Shell Search Patterns With Backticks

- Problem: using backticks directly inside a quoted `rg` pattern under `zsh` triggered command substitution and broke a content assertion command
- Decision: when searching for literal strings that contain backticks, either use single-quoted shell strings carefully or search for safer substrings that avoid command substitution entirely
- Why it worked: verification commands stopped depending on fragile shell quoting and became repeatable
- Reuse later: treat backticks in shell one-liners as hazardous characters during verification, especially when checking Markdown content

## 2026-03-27 Internal Repo Summary Skill

- Problem: `show-my-repo` covered outward-facing repo packaging, but maintainers still lacked a reusable skill for internal onboarding and architecture digestion
- Decision: add `summary-my-repo` as a separate skill that writes a versioned markdown pack under repo-root `summary-my-repo/YYYY-MM-DD-vN/`, split into overview, directory map, and core logic files
- Why it worked: internal onboarding needs directory responsibilities and control-flow explanation, which are different from investor or user packaging
- Reuse later: when a repo summary is meant for engineers rather than external audiences, default to a multi-file architecture pack with explicit coverage of source-of-truth files, workflows, invariants, and risks

## 2026-03-27 Retiring An Obsolete Skill Cleanly

- Problem: the repository no longer needed one older example skill, but removing only the folder or only the registry entry would leave validation, docs, and exported artifacts inconsistent
- Decision: retire the skill as a full package removal by updating `registry/skills.json`, README examples, install-script examples, generated summary docs, and stale `dist` artifacts together
- Why it worked: the repo's real contract spans filesystem, registry, user docs, and generated marketplace output, so removing a skill has to be treated as a multi-surface change
- Reuse later: when removing a skill, search the whole repo first and clean source, docs, and exported artifacts in one pass before running validation

## 2026-03-28 Summary Skill Needs Code Proof

- Problem: architecture summaries without explicit code snippets are easy to read but hard to verify, and different readers may interpret prose claims differently
- Decision: add a mandatory `03-code-evidence.md` output file and require snippet ids, file paths, line ranges, and short interpretations for core claims
- Why it worked: the summary remains readable while key claims become auditable against concrete code
- Reuse later: for repository-summary skills, treat prose as interpretation and code snippets as proof; require both by contract

## 2026-04-21 Frontend Refactoring Skill Needs Migration Framing

- Problem: long-form frontend cleanup advice can easily collapse into generic CSS tips and fail to tell an agent when to isolate, when to rebuild the DOM, and when to delete legacy styles
- Decision: encode the skill around a fixed sequence of boundary selection, contamination audit, isolation strategy, view rebuild criteria, cutover gating, and deletion order
- Why it worked: the central rule stays visible: the new UI must leave the legacy style pollution domain instead of fighting inside it
- Reuse later: for methodology-heavy refactor skills, encode decision boundaries and migration order first; keep tactic lists secondary

## 2026-04-23 Frontend Migration Needs A Style-Agnostic Baseline

- Problem: when a frontend refactor starts from styled output or visual intuition, agents can accidentally break page structure, drop existing functional components, or invent components that were never part of the original page contract
- Decision: require a pre-migration pass that strips styling concerns away and produces a structure-first inventory of regions, reusable components, functional components, states, and explicit non-existent elements
- Why it worked: the refactor gains a stable, style-independent baseline, so the migration can modernize presentation without drifting from the original page contract
- Reuse later: for large UI migrations, extract a style-agnostic structure checklist before touching the new design layer; use that checklist as the acceptance baseline for parity

## 2026-04-23 Skill Release Metadata Must Be Enforced

- Problem: skill edits were being published without an explicit record of version, publish time, publisher, and change summary, which makes later distribution and audit trails ambiguous
- Decision: require a mirrored `release` object in both each skill manifest and `registry/skills.json`, then enforce it in `./scripts/validate-repo.sh`
- Why it worked: the publishing contract becomes explicit and exportable instead of relying on memory or commit history
- Reuse later: when a repo publishes installable units, keep release metadata in machine-readable manifests and validate it before export

## 2026-04-23 Importing A Skill From Downloads Under macOS TCC

- Problem: shell reads against `/Users/xuzhang/Downloads/storybook-skills-standard-v1.0` failed with `Operation not permitted`, even though `stat` could see the directory
- Decision: use Finder automation to duplicate the source folder into a repo-local `.import-inbox/`, then normalize the imported package from that readable copy
- Why it worked: Finder had the required Downloads access, while the Codex shell process did not; copying preserved the source and avoided destructive operations
- Reuse later: when importing user-provided folders from protected macOS locations, first try read-only shell access; if TCC blocks contents, duplicate through Finder into a temporary repo-local inbox and clean the inbox by moving it to Trash after import

## 2026-04-23 Importing A Multi-Skill Family

- Problem: `threejs-game-skill-family` was already shaped as `skills/<id>/SKILL.md` folders, but this repository requires every installable unit to also have `agents/openai.yaml`, `markets/openai-compatible.json`, registry release metadata, README discovery, validation, and export coverage
- Decision: import each child folder as an independent installable skill, keep `threejs-game` as the routing entry, and give every child skill its own manifest plus mirrored registry release metadata
- Why it worked: the source family remains composable, while repository tooling can list, validate, export, install, and release each specialized skill separately
- Reuse later: when importing a family package, preserve the source package's skill boundaries instead of flattening it into one oversized skill; only collapse children if the child folders are incomplete or non-installable

## 2026-04-24 Importing A Skill Under A New Managed Id

- Problem: a source skill can arrive with a usable workflow but a source-facing id that does not match the repository naming decision, such as `chain-of-evidence-debug` needing to ship here as `coe-debug`
- Decision: rename the managed folder path, frontmatter `name`, manifest source path, registry id, and README install command together, while preserving the skill's internal methodology and bundled templates
- Why it worked: repository discovery stays coherent around the chosen managed id, but the imported skill still preserves its real operating model and supporting files
- Reuse later: when renaming an imported skill, treat id changes as a full metadata migration across folder path, frontmatter, manifest, registry, and docs rather than only renaming the directory

## 2026-05-29 Isolated Subagent Review Benchmarks

- Problem: a benchmark can look isolated while still copying oracle answers into the reviewer-visible runtime tree, and internal subagent thread limits can block follow-up reviews if completed reviewers are left open
- Decision: copy only reviewer-facing fixtures/templates into ignored `tmp/` runtime roots, keep oracles in tracked source only, generate a main-context canary that is not sent to reviewers, scan runtime artifacts for leakage, and close only completed reviewers when a fresh closure review needs a slot
- Why it worked: oracle contamination became structurally impossible in the runtime copy, path traversal was rejected, and closure reviews could continue without touching stuck or unknown agent sessions
- Reuse later: for any subagent benchmark, separate source oracle from runtime fixture, record launch metadata in a temp report, scan for canary leakage, and treat `test-repo` checks as asset sanity unless a runtime subagent report is present

## 2026-06-02 Product-First Skill Packaging

- Problem: a new requirements-clarification skill could pass generic package validation while losing its real product contract, such as top-down questioning, A/B/C options, recommended choices, dependency-aware rounds, partial-answer handling, requester review, and PRD output.
- Decision: add the skill package, mirrored release metadata, README discovery, an interaction fixture, and a dedicated `scripts/clear-prd-sanity.sh` check wired into `./scripts/test-repo.sh clear-prd`.
- Why it worked: the generic repository gates still validate packaging and export, while the skill-specific smoke check protects the behavior that makes the skill useful, including Draft versus Ready output.
- Reuse later: when adding a methodology skill, encode its core method as structural assertions plus small behavior fixtures instead of relying only on prose review.

## 2026-06-16 Importing An Installed Global Skill

- Problem: a skill already installed under `~/.agents/skills/` needed to become a managed AstartesSkills package without losing its bundled references or scripts.
- Decision: copy the whole source skill directory into `skills/<id>/`, add `markets/openai-compatible.json`, mirror release metadata in `registry/skills.json`, then run repository validation plus a lightweight script smoke check.
- Why it worked: the source package stayed self-contained while the repository-level registry, marketplace manifest, and validation coverage made it installable through the normal distribution flow.
- Reuse later: when smoke-checking Python helper scripts with `py_compile`, either disable bytecode writes or move generated `__pycache__` into ignored recoverable backup storage before committing.
# 2026-06-03: Packaging a root-cause-first debug skill

- When creating a new AstartesSkills package, update the skill folder, `agents/openai.yaml`, market manifest, `registry/skills.json`, README discovery entries, and `scripts/test-repo.sh` in the same change.
- Add a skill-specific sanity script when the workflow has a non-obvious contract. For `multi-path-debug`, the script checks ordering, prompt gates, and interaction fixtures that preserve the root-cause-before-repair gate, external-agent authorization, low-confidence continuation, and evidence-weighted synthesis.
- External debug advisors should be documented as discoverable and user-approved paths, not mandatory dependencies. This keeps the skill usable when Claude, Gemini, Opencode, or similar local agents are unavailable.
- Repo validation should compare skill folders and registry entries in both directions. A skill directory that is not registered is packaging drift, not a valid hidden package.

## 2026-06-30 新建报告型 Skill 的打包检查

- 问题：`skill-creator` 的 `init_skill.py` 会生成 `scripts/example.py`、`references/api_reference.md`、`assets/example_asset.txt` 等占位资源；如果直接提交，会把无用途文件发布到 skill 包里。
- 决策：初始化后只保留真正会被 skill 加载的引用文件；无关占位 `scripts/` 和 `assets/` 先移入系统回收站，再用真实的 `SKILL.md`、`agents/openai.yaml`、`markets/openai-compatible.json` 和 `registry/skills.json` 元数据替换模板。
- 问题：报告模板里外层 Markdown 示例包含内层 Mermaid 代码块，若外层也用三反引号，会提前闭合并导致渲染结构错误。
- 决策：外层示例使用四反引号，内层 Mermaid 保持三反引号；把这个约束写入对应 sanity 脚本，避免后续模板回归。
- 问题：`git push` 可能返回 GitHub HTTP 401，即使 `gh auth status` 显示当前账号已登录并拥有 `repo` 权限；原因通常是 Git 仍在使用旧的 HTTPS credential helper 凭据。
- 决策：先用 `git rev-parse HEAD`、`git rev-parse origin/main`、`git ls-remote origin refs/heads/main` 确认远端是否真的更新；若本地仍 ahead 且 `gh` 登录有效，运行 `gh auth setup-git` 后重试 `git push origin main`。
- 问题：`skill-creator` 的 `quick_validate.py` 和 `package_skill.py` 依赖 `PyYAML`；不同 Python 运行时依赖不一致时，`/opt/homebrew/bin/python3` 或 Codex bundled Python 可能报 `ModuleNotFoundError: No module named 'yaml'`，但 `/usr/bin/python3` 可正常运行。
- 决策：打包校验失败时先用 `which -a python3 python` 枚举运行时，并逐个执行 `import yaml` 检查；找到可用解释器后显式运行 `/usr/bin/python3 <skill-creator>/scripts/quick_validate.py ...` 和 `/usr/bin/python3 <skill-creator>/scripts/package_skill.py ...`。
- 复用方式：创建新 skill 后，先跑专项 sanity、`quick_validate.py`、`package_skill.py <skill> /tmp/<package-check>` 和 `./scripts/validate-repo.sh`；打包校验输出放到 `/tmp`，不要把临时 `.skill` 包留在仓库工作区。

## 2026-07-19 下线不再维护的 Skill

- 问题：仅删除 `skills/<id>/` 会遗留注册表、README 安装示例、默认冒烟目标和专项 sanity 接线，使用户仍看到不可安装的 skill，或导致 CI 因缺失脚本失败。
- 决策：下线时同步移除 skill 包、`registry/skills.json` 条目、README 当前展示与安装入口、专项 sanity 脚本及其调用；历史计划、审查报告和构想文档保留，继续承担决策追溯作用。
- 验证：运行 `./scripts/validate-repo.sh`，确认注册 skills 数与发现目录数一致；再运行默认冒烟和仍维护的专项回归测试。
- 复用方式：若默认冒烟目标被下线，必须在同一次变更中切换到仍维护且具有代表性的 skill，避免无参数测试立即失效。

## 2026-07-31 Provider Profile 与 Agent 登录状态隔离

- 问题：把 `forced_login_method = "api"` 放进 Codex 的 DeepSeek 临时侧载配置，会让 Codex 把现有 ChatGPT 登录视为违反全局登录策略，并主动清除 `auth.json`。
- 根因：Provider Bearer Token 与 Codex 自身登录是两条认证链；`forced_login_method` 约束后者，并不是发送自定义 Provider Key 的必要条件。
- 决策：Provider profile 只配置 provider endpoint、Responses 协议、`requires_openai_auth = false` 和 provider bearer；禁止把全局登录策略写进临时 profile。安装器在更新时保留已有非占位 Key，并用本地 mock 验证请求头存在、运行前后登录状态不变。
- 复用方式：新增任何 Agent/Provider 组合时，先画清 Agent 账号登录、Provider 鉴权、配置作用域三条边界；临时切换默认不得修改主配置或登录存储，真实 Provider 冒烟必须单独确认成本和远端数据影响。

## 2026-07-31 Skill Creator 工具版本与本地目录残留

- 问题：历史 runbook 记录的 `package_skill.py` 在当前系统 `skill-creator` 中已不存在，且本机 Three.js 合并后遗留只含 `.DS_Store` 的旧 skill 目录，导致全仓校验把它们识别为缺少 `SKILL.md` 的安装包。
- 决策：以当前 `SKILL.md` 明示的 `init_skill.py`、`quick_validate.py` 为准；额外用仓库 market export 和临时安装 smoke 代替已移除的打包脚本。确认旧目录没有业务文件后移入回收站，再重跑全仓门禁。
- 复用方式：不要把 runbook 中的工具清单当作永久 API；每次先枚举当前 system skill 的 scripts。合并或下线 macOS 目录后检查 `.DS_Store` 是否让本应消失的目录继续存在。
