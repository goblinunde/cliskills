# cliskills

Open-source Codex skill collection focused on LaTeX workflows.

## Included skills

- `latex-beamer`: create, revise, and optimize Beamer slide decks
- `latex-tikz`: build and refine TikZ figures with `tikz.net`-driven examples
- `latex-bug`: debug LaTeX compilation failures and review `.cls` / `.sty` files

## Repository layout

- `.agents/skills/`: repository-scoped Codex skills
- `AGENTS.md`: contributor guide for the repository
- `Makefile`: validation, install, and packaging helpers

## Quick start

```sh
make list
make validate
make install
make package
```

`make install` copies the skills into `${CODEX_HOME:-$HOME/.codex}/skills`.

## Publishing

Run `make validate` before committing. Use `make package` to build a release archive in `dist/` for sharing outside GitHub.
