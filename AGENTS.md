# Repository Guidelines

## Project Structure & Module Organization
This repository maintains reusable skills for Codex and Claude Code. The main source tree is [`.agents/skills/`](/home/yyt/Documents/Github/cliskills/.agents/skills); the Claude mirror lives under [`.claude/skills/`](/home/yyt/Documents/Github/cliskills/.claude/skills). Project-level docs and automation stay in the root: [README.md](/home/yyt/Documents/Github/cliskills/README.md), [README-zh.md](/home/yyt/Documents/Github/cliskills/README-zh.md), [AGENTS.md](/home/yyt/Documents/Github/cliskills/AGENTS.md), and [Makefile](/home/yyt/Documents/Github/cliskills/Makefile).

When adding or updating a skill:
- place it under `.agents/skills/<skill-id>/`
- include `SKILL.md` for every skill and add Codex metadata either as `.agents/skills/<skill-id>/agents/openai.yaml` or, when the source tree is read-only, as `codex-metadata/<skill-id>/openai.yaml`
- keep support files next to the skill, for example `references/`, `scripts/`, `assets/`, templates, `README.md`, or `config.yaml`
- treat `.claude/skills/` as generated mirror output and refresh it with `make sync-claude`

## Build, Test, and Development Commands
Use the repository `Makefile` instead of ad hoc copy steps.

Useful commands:
- `make info` shows repository paths and discovered skill counts
- `make list` lists Codex skill directories
- `make list-metadata` lists skills that include in-skill or overlay Codex metadata
- `make list-no-metadata` lists skills that do not yet include Codex metadata
- `make list-claude` lists mirrored Claude skill directories
- `make sync-claude` refreshes `.claude/skills/` from `.agents/skills/`
- `make validate` checks required docs, metadata, and Codex/Claude mirror alignment
- `make validate-quick` runs Codex `quick_validate.py` across skills with in-skill or overlay Codex metadata
- `make validate-all` runs both validation layers
- `rg --files` lists tracked files quickly
- `git status` shows the current worktree state
- `git diff -- README.md README-zh.md AGENTS.md Makefile` reviews project-doc changes before commit

If a skill introduces a toolchain or runtime dependency, document setup and verification in both this file and the README in the same change.

## Coding Style & Naming Conventions
Use Markdown for current repository content and keep formatting clean:
- prefer short sections with descriptive headings
- wrap commands, file paths, and identifiers in backticks
- use sentence case in prose and ATX headings (`## Heading`)

For helper scripts or support code inside a skill, follow widely used conventions for the chosen language, keep indentation consistent, and document any generated artifacts or vendored templates.

## Testing Guidelines
For documentation-only changes, verify:
- headings render correctly
- file paths and commands are accurate
- examples match the current repository layout and skill inventory

When adding or changing skills, run:
- `make sync-claude` if `.agents/skills/` changed
- `make validate`
- `make validate-quick` when a metadata-backed skill changes `SKILL.md` or either metadata location

If a skill ships helper scripts or binaries, add a repeatable validation command to the skill docs.

## Commit & Pull Request Guidelines
Do not treat the earliest placeholder history as the standard. Use concise, imperative commit subjects such as `docs: refresh skill inventory` or `build: sync Claude mirror workflow`.

Pull requests should include:
- a brief summary of what changed
- the reason for the change
- any follow-up setup or tooling decisions

Keep PRs narrowly scoped and update documentation whenever repository structure, skill inventory, or maintenance workflow changes.
