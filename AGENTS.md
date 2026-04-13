# Repository Guidelines

## Project Structure & Module Organization

This repository maintains reusable skills for Codex and Claude Code. The main source tree is [`agents/skills/`](/home/yyt/Documents/Github/cliskills/agents/skills); the Claude mirror lives under [`claude/skills/`](/home/yyt/Documents/Github/cliskills/claude/skills). Project-level docs and automation stay in the root: [README.md](/home/yyt/Documents/Github/cliskills/README.md), [README-zh.md](/home/yyt/Documents/Github/cliskills/README-zh.md), [AGENTS.md](/home/yyt/Documents/Github/cliskills/AGENTS.md), and [Makefile](/home/yyt/Documents/Github/cliskills/Makefile).

Legacy hidden directories such as `.agents/` or `.claude/` may still exist in some environments as read-only historical artifacts. Do not treat them as the maintained source tree.

When adding or updating a skill:

- place it under `agents/skills/<skill-id>/`
- include `SKILL.md` for every skill
- include Codex metadata as `agents/skills/<skill-id>/agents/openai.yaml`
- keep support files next to the skill, for example `references/`, `scripts/`, `assets/`, templates, `README.md`, or `config.yaml`
- treat `claude/skills/` as generated mirror output and refresh it with `make sync-claude`

## Build, Test, and Development Commands

Use the repository `Makefile` instead of ad hoc copy steps.

Useful commands:

- `make info` shows repository paths and discovered skill counts
- `make list` lists Codex skills with short descriptions
- `make list-ids` lists Codex skill ids only
- `make list-metadata` lists skills with `agents/openai.yaml`
- `make list-no-metadata` lists skills that do not yet include `agents/openai.yaml`
- `make list-claude` lists mirrored Claude skills with short descriptions
- `make dashboard` shows bundled and installed skill state and exposes install or update actions from one entry point
- `make sync-claude` refreshes `claude/skills/` from `agents/skills/`
- `make validate` checks required docs, metadata, and Codex/Claude mirror alignment
- `make validate-skill SKILL=<id>` checks one skill plus its Claude mirror and metadata
- `make validate-quick` runs Codex `quick_validate.py` across metadata-backed skills
- `make validate-all` runs both validation layers
- `make install INSTALL_MODE=fail|overwrite|keep` controls whether existing installed skills must match, be overwritten, or be kept
- `make install-claude-skill SKILL=<id> INSTALL_MODE=fail|overwrite|keep` installs one mirrored Claude skill without touching the rest
- `rg --files` lists tracked files quickly
- `git status` shows the current worktree state
- `git diff -- README.md README-zh.md AGENTS.md Makefile` reviews project-doc changes before commit
- `agents/skills/package-rpm-for-fedora/scripts/check_toolchain.sh source|repack-deb|repack-binary` verifies the local Fedora RPM packaging toolchain for the RPM skill

If a skill introduces a toolchain or runtime dependency, document setup and verification in both this file and the README in the same change.

For `package-rpm-for-fedora`, document and verify `rpm-build`, `rpmdevtools`, `redhat-rpm-config`, `git`, `make`, `patch`, and a compiler; for `.deb` repack flows, also note `dpkg-deb` and optional helpers such as `alien` or `fpm`.

For install targets, keep the default non-destructive posture: fail on conflicting installed content unless the caller explicitly chooses `INSTALL_MODE=overwrite` or `INSTALL_MODE=keep`. When only local extra files exist under an installed skill and the source files still match, preserve those extras.

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

- `make sync-claude` if `agents/skills/` changed
- `make validate`
- `make dashboard ACTION=show` if you changed install or dashboard behavior and want a quick status smoke test
- `make validate-skill SKILL=<id>` when you only need to validate one affected skill before installing it locally
- `make validate-quick` when a metadata-backed skill changes `SKILL.md` or `agents/openai.yaml`

If a skill ships helper scripts or binaries, add a repeatable validation command to the skill docs.

## Commit & Pull Request Guidelines

Do not treat the earliest placeholder history as the standard. Use concise, imperative commit subjects such as `docs: refresh skill inventory` or `build: simplify skill metadata layout`.

Pull requests should include:

- a brief summary of what changed
- the reason for the change
- any follow-up setup or tooling decisions

Keep PRs narrowly scoped and update documentation whenever repository structure, skill inventory, or maintenance workflow changes.
