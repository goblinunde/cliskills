# cliskills

这是一个同时面向 Codex 和 Claude Code 的开源 skills 仓库。现在仓库统一采用可见目录 `agents/skills/` 作为唯一维护源，用 `claude/skills/` 作为生成出来的 Claude 镜像；像 `.agents/`、`.claude/` 这样的隐藏目录如果仍然存在，应视为历史遗留的只读参考，而不是当前维护入口。

英文说明见 [README.md](./README.md)。

## 仓库速览

- 共 36 个内置技能，覆盖 LaTeX、开发流程、Git 与仓库工作流、Linux 打包、文档生成、Office 自动化和视觉分析
- 唯一维护源：`agents/skills/`
- Claude 镜像目录：`claude/skills/`
- 每个 skill 自带 `agents/openai.yaml` 作为 Codex 元数据
- `Makefile` 负责同步、校验、安装、交互式 dashboard 管理、打包和发布

## 仓库结构

```text
agents/skills/   # Codex 主维护目录
claude/skills/   # Claude Code 生成镜像
vendor/          # 可选的上游快照或导入参考
Makefile
README.md
README-zh.md
AGENTS.md
```

维护规则：

- 所有 skill 只在 `agents/skills/` 下修改
- 每个 skill 同时维护 `SKILL.md` 和 `agents/openai.yaml`
- 改完后运行 `make sync-claude`
- 发布或合并前运行 `make validate` 或 `make validate-all`

## 已包含技能

### LaTeX 与学术写作

| 技能 | 最适合处理的任务 |
| --- | --- |
| `latex-beamer` | 制作和重构 Beamer 幻灯片 |
| `latex-beamer-translate` | 翻译幻灯片并控制每页密度 |
| `latex-tikz` | 创建和改写 TikZ / PGFPlots 图形 |
| `latex-bug` | 排查 LaTeX 编译、类文件和包问题 |
| `latex-tex-translate` | 翻译 `.tex` 并保留命令、引用和公式 |
| `latex-pdf-translate` | 处理 PDF 为起点的翻译工作流 |
| `latex-academic-polish` | 润色学术英文，不改变技术含义 |
| `latex-bilingual` | 生成双语 LaTeX 输出 |
| `latex-posters` | 制作 LaTeX 学术海报 |
| `latex-to-typst` | 把 LaTeX 转成 Typst |
| `docs-latex` | 把 Markdown 转成 LaTeX/PDF 报告 |
| `formatter` | 检查论文式 LaTeX 格式问题 |
| `read-arxiv-paper` | 阅读 arXiv 源码包并生成总结 |
| `systematic-literature-review` | 执行系统综述流水线 |
| `complete_example` | 安全补全结构化 LaTeX 示例 |

### 文档与 Office 自动化

| 技能 | 最适合处理的任务 |
| --- | --- |
| `minimax-pdf` | 生成、填写和重排高质量 PDF |
| `minimax-docx` | 用 OpenXML 工作流创建和格式化 DOCX |
| `minimax-xlsx` | 安全创建、修改和校验 Excel 工作簿 |
| `pptx-generator` | 生成、编辑和分析 PPTX 演示文稿 |

### Linux 打包

| 技能 | 最适合处理的任务 |
| --- | --- |
| `package-rpm-for-fedora` | 从源码、`.deb` 或二进制归档构建或重打包 Fedora 兼容 RPM |

### 开发流程

这组流程型 skill 来自公开项目 [`obra/superpowers`](https://github.com/obra/superpowers)，并已经适配到当前仓库使用的可见 `agents/skills/` 结构。

| 技能 | 最适合处理的任务 |
| --- | --- |
| `using-superpowers` | 在动手前先检查应启用哪些流程型 skill |
| `brainstorming` | 在实现前把模糊需求梳理成已确认设计 |
| `writing-plans` | 把通过的需求或设计拆成细粒度实现计划 |
| `executing-plans` | 按既有计划推进，并在检查点复核 |
| `subagent-driven-development` | 按任务执行计划，并在实现后跑规格与质量审查 |
| `dispatching-parallel-agents` | 把彼此独立的任务安全并行拆分 |
| `test-driven-development` | 在写实现前强制走红绿重构 |
| `systematic-debugging` | 在提修复前系统定位根因 |
| `requesting-code-review` | 在问题放大前发起聚焦代码审查 |
| `receiving-code-review` | 在采纳意见前先核实 review 反馈是否成立 |
| `verification-before-completion` | 在宣称完成前强制补齐新鲜验证证据 |
| `using-git-worktrees` | 为功能开发和计划执行创建隔离 worktree |
| `finishing-a-development-branch` | 在任务完成后给出明确的合并或清理选项 |
| `writing-skills` | 创建或修改 skill，并保证描述与触发条件可靠 |

### Git 与仓库工作流

| 技能 | 最适合处理的任务 |
| --- | --- |
| `github-commit` | 生成完整的 git 提交命令，默认 commit 精炼，按显式关键词切换中文、丰富说明和附加项 |

### 视觉分析

| 技能 | 最适合处理的任务 |
| --- | --- |
| `vision-analysis` | 用 MiniMax vision 分析截图、图表、界面和图片 |

每个 skill 目录通常包含：

- `SKILL.md`：触发条件、工作流和输出约束
- `agents/openai.yaml`：Codex 显示名和默认提示词等元数据
- 可选支持文件：`references/`、`scripts/`、`assets/`、模板、`README.md`、`config.yaml`

## 仓库工作方式

### 主源与镜像

`agents/skills/` 是唯一维护源。`make sync-claude` 会把每个 skill 同步到 `claude/skills/`，并自动排除 Codex 专用的 `agents/` 元数据目录。

### Dashboard

`make dashboard` 把原来的 `make help` 和 `make list` 整合到了一个入口里。它会读取仓库内置 skill，以及默认安装目录 `${CODEX_HOME:-$HOME/.codex}/skills` 和 `${CLAUDE_HOME:-$HOME/.claude}/skills` 下的 skill，展示匹配、缺失或漂移状态；如果在真实终端里运行，还会提供数字菜单，支持：

- 浏览仓库 skill 和已安装 skill
- 安装或更新单个 Codex skill
- 安装或更新单个 Claude skill
- 安装或更新全部内置 skill
- 同步 Claude 镜像
- 校验单个 skill 或整个仓库

如果要脚本化调用，可以直接用非交互动作，例如 `make dashboard ACTION=show`、`make dashboard ACTION=install-codex-skill SKILL=github-commit`、`make dashboard ACTION=install-claude-skill SKILL=github-commit`。

### 安装模式

| 目标 | Codex | Claude Code |
| --- | --- | --- |
| 在本仓库内直接使用 | 直接读取 `agents/skills/` | 使用生成的 `claude/skills/` 镜像 |
| 在其他仓库中复用 | `make install` 安装到 `${CODEX_HOME:-$HOME/.codex}/skills`，默认遇到本地冲突就失败 | `make install-claude` 安装到 `${CLAUDE_HOME:-$HOME/.claude}/skills`，默认遇到本地冲突就失败 |

### 典型维护流程

1. 在 `agents/skills/<skill-id>/` 下修改或新增 skill。
2. 保持 `SKILL.md`、`agents/openai.yaml` 和支持文件一致。
3. 运行 `make sync-claude`。
4. 运行 `make validate` 或 `make validate-all`。
5. 如需本地试装，再运行 `make install` 或 `make install-claude`。
6. 如果想在一个入口里查看仓库、Codex、Claude 的 skill 状态并执行安装或更新，运行 `make dashboard`。

安装行为：

- 默认 `INSTALL_MODE=fail`：只要已安装 skill 与源 skill 冲突就停止
- `INSTALL_MODE=keep`：冲突时保留已安装版本
- `INSTALL_MODE=overwrite`：冲突时覆盖已安装版本
- 如果只是已安装 skill 下多了本地额外文件，而源文件本身完全一致，会保留这些额外文件

### 技能特定环境说明

- `package-rpm-for-fedora`：在依赖该技能做原生 RPM 构建前，先安装 Fedora/RHEL 打包工具链：`rpm-build`、`rpmdevtools`、`redhat-rpm-config`、`git`、`make`、`patch` 和一个 C 编译器。处理 `.deb` 或二进制归档重打包时，再补充 `dpkg-deb`，以及在本机可用时使用 `alien` 或 `fpm`。可用 `agents/skills/package-rpm-for-fedora/scripts/check_toolchain.sh source`、`agents/skills/package-rpm-for-fedora/scripts/check_toolchain.sh repack-deb` 或 `agents/skills/package-rpm-for-fedora/scripts/check_toolchain.sh repack-binary` 校验当前机器。

## 如何调用技能

在 Codex 里可以显式调用：

```text
使用 $minimax-docx 帮我按现有模板排版这个 Word 文档。
使用 $minimax-xlsx 帮我修复这个工作簿里的公式，并保持格式不丢失。
使用 $latex-bug 帮我找到这个编译错误的真正根因。
使用 $package-rpm-for-fedora 把这个上游 tar.gz 或 .deb 处理成适合当前 Fedora 主机的 rpm，并按需要修改 spec。
使用 $github-commit 根据当前改动生成完整的 git add / commit / push 命令，默认 commit 精炼，只有我明确提到中文、丰富、README、.gitignore 或 workflow 时才扩展。
```

也可以直接自然描述任务：

```text
把这篇 tex 论文翻译成英文，但不要改公式、引用和命令。

帮我生成一个正式的 PDF 报告，并保持设计统一。

分析这张截图里的界面问题，并给出改进建议。
```

Claude Code 使用的是 `claude/skills/` 里的镜像技能。

## 快速开始

```sh
make info
make dashboard
make list
make list-ids
make list-metadata
make list-no-metadata
make list-claude
make sync-claude
make validate
make validate-skill SKILL=github-commit
make validate-quick
make validate-all
make install
make install-claude
make install-claude-skill SKILL=github-commit
```

常用扩展命令：

```sh
make dashboard ACTION=show
make dashboard ACTION=install-codex-skill SKILL=github-commit
make dashboard ACTION=install-claude-skill SKILL=github-commit
make list LIST_FORMAT=ids
make install-skill SKILL=minimax-pdf
make install INSTALL_MODE=overwrite
make install INSTALL_MODE=keep
make install INSTALL_DIR=/tmp/codex-skills-test
make install-claude CLAUDE_INSTALL_DIR=/tmp/claude-skills-test
make package
make release
```

## Makefile 命令

- `make info`：显示仓库路径和技能数量
- `make list`：列出 `agents/skills/` 下的 Codex skill，并附带简短功能说明
- `make list-ids`：只列出 Codex skill id
- `make list-metadata`：列出带 `agents/openai.yaml` 的 skill
- `make list-no-metadata`：列出缺少 `agents/openai.yaml` 的 skill
- `make list-claude`：列出 Claude 镜像 skill，并附带简短功能说明
- `make list-claude-ids`：只列出 Claude 镜像 skill id
- `make dashboard`：显示内置 skill 与已安装 skill 的状态，并提供交互式安装、更新、同步和校验入口
- `make sync-claude`：根据源树刷新 `claude/skills/`
- `make validate`：校验文档、源 skill、镜像一致性和内联元数据
- `make validate-skill SKILL=<id>`：校验单个源 skill、对应 Claude 镜像和内联元数据
- `make validate-quick`：对带元数据的 skill 运行 Codex `quick_validate.py`
- `make validate-all`：执行全部校验层
- `make install`：安装全部 Codex skill；默认冲突失败
- `make install-skill SKILL=<id>`：安装单个 Codex skill；默认冲突失败
- `make install-claude`：安装全部 Claude 镜像 skill；默认冲突失败
- `make install-claude-skill SKILL=<id>`：安装单个 Claude 镜像 skill；默认冲突失败
- `INSTALL_MODE=fail|overwrite|keep`：控制安装冲突策略，默认是 `fail`
- `make manifest`：生成 `dist/MANIFEST.txt`
- `make package`：生成 `dist/cliskills-skills.tgz`
- `make release`：执行同步、校验、清单生成和打包

## 参考链接

- OpenAI Codex Skills 官方文档：<https://developers.openai.com/codex/skills>
- Claude Code Skills 官方文档：<https://code.claude.com/docs/en/skills>
- TikZ 示例站点：<https://tikz.net/>
