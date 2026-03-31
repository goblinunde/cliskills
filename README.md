# cliskills

Open-source Codex skills for LaTeX work. This repository packages repository-scoped skills under `.agents/skills/` so they can be versioned, reviewed, and shared like normal source code.

For Chinese documentation, see [README-zh.md](./README-zh.md).

## Included skills

| Skill | Purpose |
| --- | --- |
| `latex-beamer` | Build, rewrite, and tighten Beamer slide decks for talks, defenses, and course presentations |
| `latex-beamer-translate` | Translate Beamer decks while keeping slide density and presentation rhythm under control |
| `latex-tikz` | Create and refine TikZ or PGFPlots figures, with `tikz.net` as the first reference point |
| `latex-bug` | Diagnose LaTeX compilation failures and review `.cls` / `.sty` behavior |
| `latex-tex-translate` | Translate `.tex` source while preserving commands, citations, labels, and math |
| `latex-pdf-translate` | Translate academic PDFs while being explicit about extraction fidelity |
| `latex-academic-polish` | Polish LaTeX-based academic prose without changing technical meaning |
| `latex-bilingual` | Generate bilingual LaTeX output such as Chinese-English or English-French versions |

Each skill includes:
- `SKILL.md` with trigger conditions and workflow
- `agents/openai.yaml` for UI-facing metadata
- `references/` for longer task-specific guidance

## Repository layout

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

## How Codex uses this repo

Codex scans repository-scoped skills from `.agents/skills/` when working inside the repo. These skills are also structured so they can be copied into `${CODEX_HOME:-$HOME/.codex}/skills` for broader local reuse.

The current skills are intentionally bilingual in triggering behavior:
- English prompts remain first-class
- Chinese trigger phrases are added to improve implicit invocation
- `default_prompt` examples in `openai.yaml` are Chinese-friendly

## How to use the skills

There are two normal ways to use these skills:

1. Work inside this repository and ask Codex naturally. Because the skills live under `.agents/skills/`, Codex can discover them while working here.
2. Install them into `${CODEX_HOME:-$HOME/.codex}/skills` with `make install`, then use them from other repositories or local sessions.

You can invoke a skill explicitly by naming it in the prompt:

```text
Use $latex-tex-translate to translate this LaTeX paper into English and keep citations, labels, and formulas unchanged.

Use $latex-bug to find the real cause of this LaTeX compilation error and review the .cls file.

Use $latex-tikz to rebuild this figure based on a similar example from tikz.net.
```

You can also rely on implicit invocation by describing the task clearly:

```text
把这个 tex 文件翻译成英文，但不要改动公式、引用和命令。

帮我把这套 Beamer 幻灯片翻译成中文，并控制每页文字密度。

Polish this abstract for academic English without changing the technical meaning.
```

As a rule:
- use explicit `$skill-name` calls when you want deterministic routing
- use natural prompts when the task is simple and clearly matches a skill
- mention target language, file type, and output constraint in the prompt

Useful prompt patterns:
- translation: source format + target language + what must stay unchanged
- polishing: scope + desired tone + what must not change
- debugging: compiler/log/build command + first visible error
- TikZ/Beamer: target output + density/style constraint + source files

## Quick start

```sh
make info
make list
make validate
make validate-quick
make install
```

Useful variations:

```sh
make install-skill SKILL=latex-tikz
make package
make release
```

`make install` copies all bundled skills into `${CODEX_HOME:-$HOME/.codex}/skills`.

## Makefile targets

- `make doctor`: verify local tools needed for packaging and validation
- `make validate`: check that required docs exist and each skill has valid core metadata
- `make validate-quick`: run Codex `quick_validate.py` across all skills
- `make validate-all`: run both validation layers together
- `make install`: install all skills locally
- `make install-skill SKILL=<id>`: install a single skill
- `make manifest`: generate `dist/MANIFEST.txt` for release contents
- `make package`: create `dist/cliskills-skills.tgz`
- `make release`: run `doctor`, `manifest`, and `package`

## Development workflow

1. Edit a skill under `.agents/skills/<skill-id>/`.
2. Run `make validate-all`.
3. If you want a local dry-run install, use `make install` or `make install-skill SKILL=<id>`.
4. Build a shareable archive with `make package`.

For isolated testing without touching your default Codex directory:

```sh
make install INSTALL_DIR=/tmp/codex-skills-test
```

## References

- OpenAI Codex Skills documentation: <https://developers.openai.com/codex/skills>
- TikZ example library: <https://tikz.net/>
