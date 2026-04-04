# cliskills

这是一个面向 LaTeX 工作流的开源 skills 仓库，同时支持 Codex 和 Claude Code。`cliskills` 把常见的写作、翻译、排错、制图和演示文稿任务拆成明确的技能，并让两种 agent 共用同一套能力。仓库以 `.agents/skills/` 作为 Codex 的主维护目录，再同步出项目级的 `.claude/skills/` 镜像供 Claude Code 使用；如果你想在仓库外复用 Claude skills，也可以把它们安装到 `${CLAUDE_HOME:-$HOME/.claude}/skills`。

英文说明见 [README.md](./README.md)。

## 仓库速览

- 内置 15 个技能，覆盖 Beamer、TikZ、翻译、排错、润色、格式检查、海报、Typst 转换、Markdown 转 LaTeX、arXiv 阅读和系统综述
- 只有一个主编辑源：`.agents/skills/`
- Claude 镜像目录通过 `make sync-claude` 维护
- 同时支持 Codex 和 Claude Code 的本地安装
- `Makefile` 提供同步、校验、打包和发布流程

## 包含的技能

| 技能 | 最适合处理的任务 |
| --- | --- |
| `latex-beamer` | 制作、重构、压缩和优化 Beamer 幻灯片，适合答辩、汇报和课程展示 |
| `latex-beamer-translate` | 翻译 Beamer 幻灯片，并控制每页文字密度和演示节奏 |
| `latex-tikz` | 创建或改写 TikZ / PGFPlots 图形，并优先参考 `tikz.net` |
| `latex-bug` | 排查 LaTeX 编译错误、包冲突，以及 `.cls` / `.sty` 问题 |
| `latex-tex-translate` | 翻译 `.tex` 源文件，同时保留命令、引用、标签和公式结构 |
| `latex-pdf-translate` | 处理 PDF 为起点的翻译任务，并明确说明提取质量和保真边界 |
| `latex-academic-polish` | 润色 LaTeX 学术写作，不改变技术含义 |
| `latex-bilingual` | 生成中英、英法等成对的双语 LaTeX 输出 |
| `latex-posters` | 用 LaTeX 制作研究海报，附带模板、版式建议和审查脚本 |
| `latex-to-typst` | 把 LaTeX 文档和公式转换为 Typst，并验证转换结果 |
| `docs-latex` | 把 Markdown 文档转换成适合汇报或打印的 LaTeX/PDF 报告 |
| `formatter` | 检查论文型 LaTeX 的浮动体、公式、表格、交叉引用和单位格式 |
| `read-arxiv-paper` | 下载 arXiv 源码包，从 TeX 阅读论文，并输出本地总结 |
| `systematic-literature-review` | 执行带相关性评分和导出流程的系统综述流水线 |
| `complete-example` | 在保护结构与格式的前提下，为 LaTeX 示例章节生成内容 |

每个技能配置通常包含：

- `SKILL.md`：定义触发边界、工作流和输出约束
- 可选的 Codex 元数据：可以放在技能目录内的 `agents/openai.yaml`，也可以在仓库根目录使用 `codex-metadata/<skill-id>/openai.yaml` 作为回退覆盖
- 可选的 `references/`、`scripts/`、`assets/`、`README.md`、`config.yaml`、模板或辅助代码：按技能需要补充

## 仓库模型

```text
.agents/skills/   # Codex 的主维护目录
.claude/skills/   # Claude Code 的同步镜像
codex-metadata/   # 当技能目录只读时，用于补充 Codex 元数据的覆盖层
Makefile          # sync, validate, install, package, release
README.md
README-zh.md
AGENTS.md
```

维护规则很简单：

- 技能内容统一在 `.agents/skills/` 下修改
- 修改后运行 `make sync-claude` 刷新仓库内的 `.claude/skills/`
- 发布或推送前运行 `make validate-all`
- `make install` 和 `make install-claude` 主要用于本地消费端安装，不是主编辑流程

`make sync-claude` 会把技能同步到 `.claude/skills/`，复制 Claude Code 运行所需的全部支持文件，只排除 Codex 专用的 `agents/` 元数据目录。

当前这些技能已经做了中英双语触发优化：

- 保留英文触发能力
- 补充中文触发词，提升隐式命中率
- 在 `openai.yaml` 中提供更适合中文用户的 `default_prompt`
- 如果技能源码目录只读，可在 `codex-metadata/` 中维护对应的 Codex 元数据

## 发现与安装方式

| 目标 | Codex | Claude Code |
| --- | --- | --- |
| 直接在本仓库内使用 | Codex 会自动发现 `.agents/skills/` | Claude Code 会读取项目级 `.claude/skills/` 镜像 |
| 在其他仓库中复用 | `make install` 复制到 `${CODEX_HOME:-$HOME/.codex}/skills` | `make install-claude` 复制到 `${CLAUDE_HOME:-$HOME/.claude}/skills` |

如果你只是维护这个仓库，通常不需要先执行安装命令。安装目标更适合做隔离测试，或者把技能带到别的项目里复用。

## 如何使用这些技能

对于 Codex，常见用法有两种：

1. 直接在这个仓库里和 Codex 对话。因为技能就在 `.agents/skills/` 下，Codex 在仓库内工作时可以发现它们。
2. 先运行 `make install`，把技能复制到 `${CODEX_HOME:-$HOME/.codex}/skills`，然后在其他仓库或本地会话中复用。

对于 Claude Code，也有两种模式：

- 直接在这个仓库里工作，使用项目级 `.claude/skills/` 镜像
- 运行 `make install-claude`，复制到 `${CLAUDE_HOME:-$HOME/.claude}/skills`，以便跨仓库复用

你可以显式指定 Codex skill：

```text
使用 $latex-tex-translate 帮我把这篇 LaTeX 论文翻译成英文，并保持引用、标签和公式不变。

使用 $latex-bug 帮我找到这个 LaTeX 编译错误的根因，并顺便审查 .cls 文件。

使用 $latex-tikz 参考 tikz.net 的相似例子重画这个图。
```

在 Claude Code 里，直接调用用的是 `/skill-name`：

```text
/latex-tex-translate main.tex
/latex-bug build.log
/latex-tikz figure-concept.md
```

也可以直接用自然语言描述任务，让系统隐式命中：

```text
把这个 tex 文件翻译成英文，但不要改动公式、引用和命令。

帮我把这套 Beamer 幻灯片翻译成中文，并控制每页文字密度。

请把这段摘要润色成更自然的学术英文，不要改技术含义。
```

实用提示模板：

- 翻译类：源文件类型 + 目标语言 + 必须保持不变的内容
- 润色类：范围 + 目标风格 + 不允许改动的部分
- 排错类：编译命令或构建命令 + 日志 + 第一条错误信息
- TikZ / Beamer 类：目标效果 + 密度或风格约束 + 输入文件

如果你想稳定命中某个 skill，显式写 `$skill-name` 最稳妥。任务边界很清楚时，也可以直接自然描述。

## 快速开始

```sh
make info
make list
make list-metadata
make list-no-metadata
make sync-claude
make validate
make validate-quick
make validate-all
make install
make install-claude
```

常用扩展命令：

```sh
make install-skill SKILL=latex-bug
make install INSTALL_DIR=/tmp/codex-skills-test
make install-claude CLAUDE_INSTALL_DIR=/tmp/claude-skills-test
make package
make release
```

`make install` 会把所有 Codex 技能复制到 `${CODEX_HOME:-$HOME/.codex}/skills`，并在需要时把 `codex-metadata/` 中的覆盖元数据落到安装后的技能目录里。
`make install-claude` 会把 Claude 镜像技能复制到 `${CLAUDE_HOME:-$HOME/.claude}/skills`。

## 开发与维护流程

1. 修改 `.agents/skills/<skill-id>/` 下的技能文件。
2. 保持 `SKILL.md`、可选的 Codex 元数据和支持文件一致。
3. 运行 `make sync-claude`。
4. 运行 `make validate-all`。
5. 如需本地试装，运行 `make install`、`make install-skill SKILL=<id>` 或 `make install-claude`。
6. 如需打包分享，运行 `make package`，或直接用 `make release` 执行完整发布流程。

新增 skill 时，最小目录结构应当是：

```text
.agents/skills/<skill-id>/
  SKILL.md
```

如果你希望补充 Codex 侧元数据并纳入 `make validate-quick`，在技能目录可写时添加 `agents/openai.yaml`，在技能目录只读时添加 `codex-metadata/<skill-id>/openai.yaml`。只有在确实能提升技能效果时，再补充支持文件，例如 `references/`、`scripts/`、`assets/`、模板、`README.md` 或 `config.yaml`。新增后记得执行 `make sync-claude`，让 Claude 镜像保持同步。

## Makefile 命令

- `make doctor`：检查本地是否具备打包和校验所需命令
- `make list`：列出 Codex 主目录中的全部 skill id
- `make list-metadata`：列出已经具备 Codex 元数据的 skill，包括技能内元数据和 `codex-metadata/` 覆盖层
- `make list-no-metadata`：列出当前还没有 Codex 元数据的 skill
- `make list-claude`：列出 Claude 镜像目录中的全部 skill id
- `make sync-claude`：根据 Codex 主目录刷新项目级 `.claude/skills` 镜像
- `make validate`：检查文档文件和技能元数据是否齐全
- `make validate-quick`：对带有技能内元数据或 `codex-metadata/` 覆盖层的 skill 运行 Codex `quick_validate.py`
- `make validate-all`：同时执行仓库级校验和 Codex quick 校验
- `make install`：把全部技能安装到本地 Codex 技能目录
- `make install-skill SKILL=<id>`：只安装一个 Codex skill
- `make install-claude`：把全部 Claude 镜像技能安装到用户级 Claude 技能目录
- `make manifest`：生成 `dist/MANIFEST.txt`，用于发布时查看归档内容
- `make package`：生成 `dist/cliskills-skills.tgz`
- `make release`：顺序执行 `sync-claude`、`doctor`、`validate-all`、`manifest`、`package`

## 参考链接

- OpenAI Codex Skills 官方文档：<https://developers.openai.com/codex/skills>
- Claude Code Skills 官方文档：<https://code.claude.com/docs/en/skills>
- TikZ 示例站点：<https://tikz.net/>
