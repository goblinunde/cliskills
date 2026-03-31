# cliskills

这是一个面向 LaTeX 工作流的开源 Codex skills 仓库。仓库把多个技能放在 `.agents/skills/` 下，便于像普通源码一样进行版本管理、审查和分享。

英文说明见 [README.md](./README.md)。

## 包含的技能

| 技能 | 用途 |
| --- | --- |
| `latex-beamer` | 用于制作、改写、压缩和优化 Beamer 幻灯片，适合答辩、汇报和课程展示 |
| `latex-beamer-translate` | 用于翻译 Beamer 幻灯片，并控制页内文字密度和展示节奏 |
| `latex-tikz` | 用于创建和优化 TikZ / PGFPlots 图形，并优先参考 `tikz.net` |
| `latex-bug` | 用于排查 LaTeX 编译错误，以及审查 `.cls` / `.sty` 文件行为 |
| `latex-tex-translate` | 用于翻译 `.tex` 源文件，并保留命令、引用、标签和公式结构 |
| `latex-pdf-translate` | 用于翻译学术 PDF，并明确说明提取质量和版式保真边界 |
| `latex-academic-polish` | 用于润色 LaTeX 学术写作，不改变技术含义 |
| `latex-bilingual` | 用于生成中英、英法等双语 LaTeX 输出 |

每个技能目录都包含：
- `SKILL.md`：定义触发边界、工作流和输出要求
- `agents/openai.yaml`：定义 UI 元数据和默认 prompt
- `references/`：放置更详细的参考说明

## 仓库结构

```text
.agents/skills/
  latex-academic-polish/
  latex-beamer/
  latex-beamer-translate/
  latex-bilingual/
  latex-bug/
  latex-pdf-translate/
  latex-tex-translate/
  latex-tikz/
AGENTS.md
Makefile
README.md
README-zh.md
```

## Codex 如何使用这些技能

当 Codex 在这个仓库中工作时，会从 `.agents/skills/` 扫描仓库级技能。与此同时，这些技能也可以通过复制到 `${CODEX_HOME:-$HOME/.codex}/skills` 的方式，在本机其他仓库中复用。

当前这些技能已经做了中英双语触发优化：
- 保留英文触发能力
- 在 `description` 中补充中文触发词
- 在 `openai.yaml` 中使用更适合中文用户的默认 prompt

## 如何使用这些技能

通常有两种使用方式：

1. 直接在这个仓库里和 Codex 对话。因为技能就在 `.agents/skills/` 下，Codex 在仓库内工作时可以发现它们。
2. 先运行 `make install`，把技能复制到 `${CODEX_HOME:-$HOME/.codex}/skills`，然后在其他仓库或本地会话中复用。

你可以显式指定 skill：

```text
使用 $latex-tex-translate 帮我把这篇 LaTeX 论文翻译成英文，并保持引用、标签和公式不变。

使用 $latex-bug 帮我找到这个 LaTeX 编译错误的根因，并顺便审查 .cls 文件。

使用 $latex-tikz 参考 tikz.net 的相似例子重画这个图。
```

也可以直接用自然语言描述任务，让 Codex 隐式命中：

```text
把这个 tex 文件翻译成英文，但不要改动公式、引用和命令。

帮我把这套 Beamer 幻灯片翻译成中文，并控制每页文字密度。

请把这段摘要润色成更自然的学术英文，不要改技术含义。
```

经验上：
- 想稳定命中某个 skill，就显式写 `$skill-name`
- 任务很明确时，可以直接自然描述
- 提示里最好写清楚目标语言、文件类型、哪些内容不能改

实用提示模板：
- 翻译类：源文件类型 + 目标语言 + 必须保持不变的内容
- 润色类：范围 + 目标风格 + 不允许改动的部分
- 排错类：编译命令/日志 + 第一条错误信息
- TikZ/Beamer 类：目标效果 + 密度或风格约束 + 输入文件

## 快速开始

```sh
make info
make list
make validate
make validate-quick
make install
```

常用扩展命令：

```sh
make install-skill SKILL=latex-bug
make package
make release
```

`make install` 会把所有技能复制到 `${CODEX_HOME:-$HOME/.codex}/skills`。

## Makefile 命令

- `make doctor`：检查本地是否具备打包和校验所需命令
- `make validate`：检查文档文件和技能元数据是否齐全
- `make validate-quick`：对所有 skill 运行 Codex 的 `quick_validate.py`
- `make validate-all`：同时执行仓库级校验和 Codex 校验
- `make install`：安装全部技能到本地 Codex 技能目录
- `make install-skill SKILL=<id>`：只安装一个技能
- `make manifest`：生成 `dist/MANIFEST.txt`，用于发布时查看归档内容
- `make package`：生成 `dist/cliskills-skills.tgz`
- `make release`：顺序执行 `doctor`、`manifest`、`package`

## 开发流程

1. 修改 `.agents/skills/<skill-id>/` 下的技能文件。
2. 运行 `make validate-all`。
3. 如需本地试装，运行 `make install` 或 `make install-skill SKILL=<id>`。
4. 如需打包分享，运行 `make package`。

如果你想做隔离测试而不覆盖默认 Codex 技能目录，可以这样运行：

```sh
make install INSTALL_DIR=/tmp/codex-skills-test
```

## 参考链接

- OpenAI Codex Skills 官方文档：<https://developers.openai.com/codex/skills>
- TikZ 示例站点：<https://tikz.net/>
