# cliskills

Open-source Codex skills for LaTeX work. This repository packages three repository-scoped skills under `.agents/skills/` so they can be versioned, reviewed, and shared like normal source code.

For Chinese documentation, see [README-zh.md](./README-zh.md).

## Included skills

| Skill | Purpose |
| --- | --- |
| `latex-beamer` | Build, rewrite, and tighten Beamer slide decks for talks, defenses, and course presentations |
| `latex-tikz` | Create and refine TikZ or PGFPlots figures, with `tikz.net` as the first reference point |
| `latex-bug` | Diagnose LaTeX compilation failures and review `.cls` / `.sty` behavior |

Each skill includes:
- `SKILL.md` with trigger conditions and workflow
- `agents/openai.yaml` for UI-facing metadata
- `references/` for longer task-specific guidance

## Repository layout

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

## How Codex uses this repo

Codex scans repository-scoped skills from `.agents/skills/` when working inside the repo. These skills are also structured so they can be copied into `${CODEX_HOME:-$HOME/.codex}/skills` for broader local reuse.

The current skills are intentionally bilingual in triggering behavior:
- English prompts remain first-class
- Chinese trigger phrases are added to improve implicit invocation
- `default_prompt` examples in `openai.yaml` are Chinese-friendly

## Quick start

```sh
make info
make list
make validate
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
- `make install`: install all skills locally
- `make install-skill SKILL=<id>`: install a single skill
- `make manifest`: generate `dist/MANIFEST.txt` for release contents
- `make package`: create `dist/cliskills-skills.tgz`
- `make release`: run `doctor`, `manifest`, and `package`

## Development workflow

1. Edit a skill under `.agents/skills/<skill-id>/`.
2. Run `make validate`.
3. If you want a local dry-run install, use `make install` or `make install-skill SKILL=<id>`.
4. Build a shareable archive with `make package`.

For isolated testing without touching your default Codex directory:

```sh
make install INSTALL_DIR=/tmp/codex-skills-test
```

## References

- OpenAI Codex Skills documentation: <https://developers.openai.com/codex/skills>
- TikZ example library: <https://tikz.net/>
