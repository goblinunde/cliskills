# cliskills

这是一个面向 LaTeX 工作流的开源 Codex skills 仓库。仓库把 3 个技能放在 `.agents/skills/` 下，便于像普通源码一样进行版本管理、审查和分享。

英文说明见 [README.md](./README.md)。

## 包含的技能

| 技能 | 用途 |
| --- | --- |
| `latex-beamer` | 用于制作、改写、压缩和优化 Beamer 幻灯片，适合答辩、汇报和课程展示 |
| `latex-tikz` | 用于创建和优化 TikZ / PGFPlots 图形，并优先参考 `tikz.net` |
| `latex-bug` | 用于排查 LaTeX 编译错误，以及审查 `.cls` / `.sty` 文件行为 |

每个技能目录都包含：
- `SKILL.md`：定义触发边界、工作流和输出要求
- `agents/openai.yaml`：定义 UI 元数据和默认 prompt
- `references/`：放置更详细的参考说明

## 仓库结构

```text
.agents/skills/
  latex-beamer/
  latex-tikz/
  latex-bug/
AGENTS.md
Makefile
README.md
README-zh.md
```

## Codex 如何使用这些技能

当 Codex 在这个仓库中工作时，会从 `.agents/skills/` 扫描仓库级技能。与此同时，这些技能也可以通过复制到 `${CODEX_HOME:-$HOME/.codex}/skills` 的方式，在本机其他仓库中复用。

当前这 3 个技能已经做了中英双语触发优化：
- 保留英文触发能力
- 在 `description` 中补充中文触发词
- 在 `openai.yaml` 中使用更适合中文用户的默认 prompt

## 快速开始

```sh
make info
make list
make validate
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
- `make install`：安装全部技能到本地 Codex 技能目录
- `make install-skill SKILL=<id>`：只安装一个技能
- `make manifest`：生成 `dist/MANIFEST.txt`，用于发布时查看归档内容
- `make package`：生成 `dist/cliskills-skills.tgz`
- `make release`：顺序执行 `doctor`、`manifest`、`package`

## 开发流程

1. 修改 `.agents/skills/<skill-id>/` 下的技能文件。
2. 运行 `make validate`。
3. 如需本地试装，运行 `make install` 或 `make install-skill SKILL=<id>`。
4. 如需打包分享，运行 `make package`。

如果你想做隔离测试而不覆盖默认 Codex 技能目录，可以这样运行：

```sh
make install INSTALL_DIR=/tmp/codex-skills-test
```

## 参考链接

- OpenAI Codex Skills 官方文档：<https://developers.openai.com/codex/skills>
- TikZ 示例站点：<https://tikz.net/>
