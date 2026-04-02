# cliskills

Open-source LaTeX skills for both Codex and Claude Code. `cliskills` packages task-focused skills for writing, translating, debugging, and presenting LaTeX projects, while keeping the same skill set available to both agents. The repository uses `.agents/skills/` as the maintained Codex source tree and keeps a synced project-scoped Claude mirror under `.claude/skills/`. If you want Claude skills outside this repository, you can also install them into `${CLAUDE_HOME:-$HOME/.claude}/skills`.

For Chinese documentation, see [README-zh.md](./README-zh.md).

## At a glance

- 8 bundled skills covering Beamer, TikZ, translation, debugging, academic polishing, and bilingual output
- one authoring source: edit skills under `.agents/skills/`
- one Claude mirror: refresh `.claude/skills/` with `make sync-claude`
- local installation targets for both Codex and Claude Code
- validation, packaging, and release helpers in `Makefile`

## Included skills

| Skill | Best for |
| --- | --- |
| `latex-beamer` | Building, restructuring, and tightening Beamer slide decks for talks, defenses, and classes |
| `latex-beamer-translate` | Translating slide decks without losing presentation rhythm or overloading each frame |
| `latex-tikz` | Creating or adapting TikZ and PGFPlots figures, with `tikz.net` as the first reference |
| `latex-bug` | Diagnosing LaTeX compilation failures, package conflicts, and `.cls` / `.sty` issues |
| `latex-tex-translate` | Translating `.tex` source while preserving commands, citations, labels, and math |
| `latex-pdf-translate` | Handling PDF-first translation workflows while being explicit about extraction fidelity |
| `latex-academic-polish` | Polishing LaTeX-based academic prose without changing technical meaning |
| `latex-bilingual` | Producing paired bilingual LaTeX output such as Chinese-English or English-French versions |

Each skill directory is expected to contain:

- `SKILL.md` with trigger boundaries, workflow, and output rules
- `agents/openai.yaml` with Codex-facing metadata
- optional `references/`, `scripts/`, and `assets/` for deeper guidance or reusable helpers

## Repository model

```text
.agents/skills/   # source of truth for Codex
.claude/skills/   # synced mirror for Claude Code
Makefile          # sync, validate, install, package, release
README.md
README-zh.md
AGENTS.md
```

The maintenance rule is simple:

- edit skill content under `.agents/skills/`
- run `make sync-claude` to refresh the repository mirror under `.claude/skills/`
- run `make validate-all` before packaging or pushing changes
- use `make install` or `make install-claude` only for local consumer installs

`make sync-claude` copies `SKILL.md` plus shared support directories such as `references/`, `scripts/`, and `assets/` when they exist.

The current skills are intentionally bilingual in triggering behavior:

- English prompts remain first-class
- Chinese trigger phrases improve implicit invocation
- `default_prompt` examples in `openai.yaml` are written to be Chinese-friendly

## Discovery and installation modes

| Goal | Codex | Claude Code |
| --- | --- | --- |
| Use skills while working inside this repository | Codex discovers `.agents/skills/` automatically | Claude Code reads the project-scoped `.claude/skills/` mirror |
| Reuse skills across other repositories | `make install` copies skills to `${CODEX_HOME:-$HOME/.codex}/skills` | `make install-claude` copies mirrored skills to `${CLAUDE_HOME:-$HOME/.claude}/skills` |

If you only want to maintain this repository, you usually do not need either install step. The install targets are mainly for dry-run testing and cross-repository reuse.

## How to use the skills

For Codex, there are two normal paths:

1. Work inside this repository and ask naturally. Because the skills live under `.agents/skills/`, Codex can discover them while working here.
2. Install them into `${CODEX_HOME:-$HOME/.codex}/skills` with `make install`, then use them from other repositories or local sessions.

For Claude Code, there are also two modes:

- work inside this repository and use the project-scoped `.claude/skills/` mirror
- run `make install-claude` to copy the mirrored skills into `${CLAUDE_HOME:-$HOME/.claude}/skills` for reuse across repositories

You can invoke a Codex skill explicitly by naming it in the prompt:

```text
Use $latex-tex-translate to translate this LaTeX paper into English and keep citations, labels, and formulas unchanged.

Use $latex-bug to find the real cause of this LaTeX compilation error and review the .cls file.

Use $latex-tikz to rebuild this figure based on a similar example from tikz.net.
```

In Claude Code, direct invocation uses slash commands:

```text
/latex-tex-translate main.tex
/latex-bug build.log
/latex-tikz figure-concept.md
```

You can also rely on implicit invocation by describing the task clearly:

```text
把这个 tex 文件翻译成英文，但不要改动公式、引用和命令。

帮我把这套 Beamer 幻灯片翻译成中文，并控制每页文字密度。

Polish this abstract for academic English without changing the technical meaning.
```

Useful prompt patterns:

- translation: source format + target language + what must stay unchanged
- polishing: scope + desired tone + what must not change
- debugging: compiler or build command + log + first visible error
- TikZ or Beamer: target output + density or style constraint + source files

Use explicit `$skill-name` calls when you want deterministic routing. Use natural prompts when the task is simple and clearly matches a skill.

## Quick start

```sh
make info
make list
make sync-claude
make validate
make validate-quick
make validate-all
make install
make install-claude
```

Useful variations:

```sh
make install-skill SKILL=latex-tikz
make install INSTALL_DIR=/tmp/codex-skills-test
make install-claude CLAUDE_INSTALL_DIR=/tmp/claude-skills-test
make package
make release
```

`make install` copies all bundled Codex skills into `${CODEX_HOME:-$HOME/.codex}/skills`.
`make install-claude` copies the mirrored Claude skills into `${CLAUDE_HOME:-$HOME/.claude}/skills`.

## Contributor workflow

1. Edit a skill under `.agents/skills/<skill-id>/`.
2. Keep `SKILL.md`, `agents/openai.yaml`, and any support files aligned.
3. Run `make sync-claude`.
4. Run `make validate-all`.
5. Optionally test installation with `make install`, `make install-skill SKILL=<id>`, or `make install-claude`.
6. Build a shareable archive with `make package`, or use `make release` for the full release sequence.

When adding a new skill, the minimum expected structure is:

```text
.agents/skills/<skill-id>/
  SKILL.md
  agents/openai.yaml
```

Add `references/`, `scripts/`, or `assets/` only when they materially improve the skill. After that, run `make sync-claude` so the Claude mirror stays in sync.

## Makefile targets

- `make doctor`: verify local tools needed for packaging and validation
- `make list`: list bundled Codex skill ids
- `make list-claude`: list mirrored Claude skill ids
- `make sync-claude`: refresh the project-scoped `.claude/skills` mirror from the Codex source tree
- `make validate`: check that required docs exist and each skill has valid core metadata
- `make validate-quick`: run Codex `quick_validate.py` across all skills
- `make validate-all`: run repository validation plus Codex quick validation
- `make install`: install all skills locally for Codex
- `make install-skill SKILL=<id>`: install a single Codex skill
- `make install-claude`: install all mirrored Claude skills into the user-scoped Claude directory
- `make manifest`: generate `dist/MANIFEST.txt` for release contents
- `make package`: create `dist/cliskills-skills.tgz`
- `make release`: run `sync-claude`, `doctor`, `validate-all`, `manifest`, and `package`

## References

- OpenAI Codex Skills documentation: <https://developers.openai.com/codex/skills>
- Claude Code skills documentation: <https://code.claude.com/docs/en/skills>
- TikZ example library: <https://tikz.net/>
