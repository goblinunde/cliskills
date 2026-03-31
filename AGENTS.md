# Repository Guidelines

## Project Structure & Module Organization
This repository is currently minimal. The root contains [README.md](/home/yyt/Documents/Github/cliskills/README.md) and Git metadata only; no application source tree, test suite, or asset directory has been introduced yet.

When adding code, keep the layout simple and predictable:
- place runtime code in `src/`
- place tests in `tests/` or next to the module as `*.test.*`
- place static assets in `assets/`
- keep project-wide docs in the repository root

## Build, Test, and Development Commands
There is no build system, package manifest, or test runner configured at the moment. Until one is added, contributors should focus on documentation-quality checks and small, reviewable changes.

Useful commands:
- `rg --files` lists tracked files quickly
- `git status` shows the current worktree state
- `git diff -- README.md AGENTS.md` reviews documentation edits before commit

If you introduce a language toolchain, add its setup and build commands to both this file and the README in the same change.

## Coding Style & Naming Conventions
Use Markdown for current repository content and keep formatting clean:
- prefer short sections with descriptive headings
- wrap commands, file paths, and identifiers in backticks
- use sentence case in prose and ATX headings (`## Heading`)

For new code, default to widely used conventions for the chosen language, use consistent indentation, and avoid mixing generated files with hand-written source unless the generator is documented.

## Testing Guidelines
No automated tests are configured yet. For documentation-only changes, verify:
- headings render correctly
- file paths and commands are accurate
- examples match the repository layout

When adding executable code, include a repeatable test command and document expected coverage or validation steps here.

## Commit & Pull Request Guidelines
The current Git history only contains placeholder messages (`first commit`), so do not treat that as the standard. Use concise, imperative commit subjects such as `docs: add contributor guide`.

Pull requests should include:
- a brief summary of what changed
- the reason for the change
- any follow-up setup or tooling decisions

Keep PRs narrowly scoped and update documentation whenever repository structure or workflow changes.
