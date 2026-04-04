# cliskills

Open-source skills for Codex and Claude Code. The repository now uses a single visible source tree under `agents/skills/`, keeps a generated Claude mirror under `claude/skills/`, and treats any legacy hidden directories such as `.agents/` or `.claude/` as read-only historical artifacts rather than active source.

For Chinese documentation, see [README-zh.md](./README-zh.md).

## At a glance

- 20 bundled skills across LaTeX, document generation, office automation, and vision analysis
- one maintained source tree: `agents/skills/`
- one generated Claude mirror: `claude/skills/`
- skill-local Codex metadata via `agents/openai.yaml` inside each skill
- `Makefile` targets for sync, validation, install, packaging, and release

## Repository model

```text
agents/skills/   # maintained Codex source of truth
claude/skills/   # generated mirror for Claude Code
vendor/          # optional upstream snapshots or imported references
Makefile
README.md
README-zh.md
AGENTS.md
```

Maintenance rule:

- edit skills only under `agents/skills/`
- keep `SKILL.md` and `agents/openai.yaml` together inside each skill
- run `make sync-claude` after changing the source tree
- run `make validate` or `make validate-all` before packaging or merging

## Included skills

### LaTeX and academic writing

| Skill | Best for |
| --- | --- |
| `latex-beamer` | Building and tightening Beamer slide decks |
| `latex-beamer-translate` | Translating slide decks without overloading frames |
| `latex-tikz` | Creating and adapting TikZ and PGFPlots figures |
| `latex-bug` | Diagnosing LaTeX compilation and class/package issues |
| `latex-tex-translate` | Translating `.tex` while preserving commands and math |
| `latex-pdf-translate` | Handling PDF-first translation workflows |
| `latex-academic-polish` | Polishing academic prose without changing meaning |
| `latex-bilingual` | Producing paired bilingual LaTeX output |
| `latex-posters` | Building research posters in LaTeX |
| `latex-to-typst` | Converting LaTeX content into Typst |
| `docs-latex` | Turning Markdown into polished LaTeX and PDF reports |
| `formatter` | Checking thesis-style LaTeX formatting issues |
| `read-arxiv-paper` | Reading arXiv source bundles and writing local summaries |
| `systematic-literature-review` | Running multi-stage literature review workflows |
| `complete_example` | Filling structured LaTeX examples safely |

### Document and office automation

| Skill | Best for |
| --- | --- |
| `minimax-pdf` | Generating, filling, and restyling polished PDFs |
| `minimax-docx` | Creating and formatting DOCX documents with OpenXML workflows |
| `minimax-xlsx` | Creating, editing, and validating Excel workbooks safely |
| `pptx-generator` | Creating, editing, and analyzing PowerPoint decks |

### Vision

| Skill | Best for |
| --- | --- |
| `vision-analysis` | Analyzing screenshots, charts, UI mockups, and images with MiniMax vision |

Each skill is expected to contain:

- `SKILL.md` with trigger rules, workflow, and output constraints
- `agents/openai.yaml` with Codex-facing display metadata
- optional support files such as `references/`, `scripts/`, `assets/`, templates, `README.md`, or `config.yaml`

## Working with the repository

### Source and mirror

`agents/skills/` is the only maintained source tree. `make sync-claude` copies each skill into `claude/skills/` and excludes the Codex-only `agents/` metadata directory.

### Installation modes

| Goal | Codex | Claude Code |
| --- | --- | --- |
| Use skills inside this repository | Work directly from `agents/skills/` | Use the generated `claude/skills/` mirror |
| Reuse skills across other repositories | `make install` copies to `${CODEX_HOME:-$HOME/.codex}/skills` | `make install-claude` copies to `${CLAUDE_HOME:-$HOME/.claude}/skills` |

### Typical workflow

1. Edit or add a skill under `agents/skills/<skill-id>/`.
2. Keep `SKILL.md`, `agents/openai.yaml`, and any support files aligned.
3. Run `make sync-claude`.
4. Run `make validate` or `make validate-all`.
5. Optionally test local installs with `make install` or `make install-claude`.

## How to invoke skills

For Codex, use either explicit invocation:

```text
Use $minimax-docx to format this Word document with the existing template.
Use $minimax-xlsx to fix formulas in this workbook without losing formatting.
Use $latex-bug to find the real cause of this compilation failure.
```

Or use natural language when the task clearly matches a skill:

```text
帮我把这篇 tex 论文翻译成英文，但不要改公式、引用和命令。

帮我生成一个正式的 PDF 报告，并保持设计统一。

分析这张截图里的界面问题，并给出改进建议。
```

For Claude Code, use the mirrored skill names from `claude/skills/`.

## Quick start

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

Useful variations:

```sh
make install-skill SKILL=minimax-pdf
make install INSTALL_DIR=/tmp/codex-skills-test
make install-claude CLAUDE_INSTALL_DIR=/tmp/claude-skills-test
make package
make release
```

## Makefile targets

- `make info`: show repository paths and discovered skill counts
- `make list`: list Codex source skill ids from `agents/skills/`
- `make list-metadata`: list skills that include skill-local `agents/openai.yaml`
- `make list-no-metadata`: list skills that still lack `agents/openai.yaml`
- `make list-claude`: list mirrored Claude skill ids
- `make sync-claude`: refresh `claude/skills/` from the source tree
- `make validate`: validate required docs, source skills, mirror alignment, and inline metadata
- `make validate-quick`: run Codex `quick_validate.py` across metadata-backed skills
- `make validate-all`: run both validation layers
- `make install`: install all skills locally for Codex
- `make install-skill SKILL=<id>`: install one Codex skill
- `make install-claude`: install all mirrored Claude skills into the user-scoped Claude directory
- `make manifest`: generate `dist/MANIFEST.txt`
- `make package`: create `dist/cliskills-skills.tgz`
- `make release`: run sync, validation, manifest generation, and packaging

## References

- OpenAI Codex Skills documentation: <https://developers.openai.com/codex/skills>
- Claude Code skills documentation: <https://code.claude.com/docs/en/skills>
- TikZ example library: <https://tikz.net/>
