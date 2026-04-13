# cliskills

Open-source skills for Codex and Claude Code. The repository now uses a single visible source tree under `agents/skills/`, keeps a generated Claude mirror under `claude/skills/`, and treats any legacy hidden directories such as `.agents/` or `.claude/` as read-only historical artifacts rather than active source.

For Chinese documentation, see [README-zh.md](./README-zh.md).

## At a glance

- 36 bundled skills across LaTeX, development workflow, Git and repository workflow, Linux packaging, document generation, office automation, and vision analysis
- one maintained source tree: `agents/skills/`
- one generated Claude mirror: `claude/skills/`
- skill-local Codex metadata via `agents/openai.yaml` inside each skill
- `Makefile` targets for sync, validation, install, interactive dashboard management, packaging, and release
- `vendor/superpowers.lock` plus a GitHub Actions workflow for safe upstream superpowers sync via PR
- repository-local quick validation via `scripts/quick_validate.py` with a `PyYAML` dependency

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
- use `make sync-superpowers` or `.github/workflows/sync-superpowers.yml` to update the allowlisted `obra/superpowers` skills without overwriting local metadata

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

### Linux packaging

| Skill | Best for |
| --- | --- |
| `package-rpm-for-fedora` | Building or repackaging Fedora-compatible RPMs from source, `.deb`, or binary archives |

### Development workflow

These process skills are imported from the public [`obra/superpowers`](https://github.com/obra/superpowers) project and adapted to this repository's visible `agents/skills/` layout.

| Skill | Best for |
| --- | --- |
| `using-superpowers` | Checking for relevant process skills before doing any work |
| `brainstorming` | Turning rough feature ideas into an approved design before implementation |
| `writing-plans` | Breaking approved requirements into detailed implementation plans |
| `executing-plans` | Executing a written plan with review checkpoints |
| `subagent-driven-development` | Driving plan execution task by task with implement and review loops |
| `dispatching-parallel-agents` | Splitting independent tasks across parallel agents safely |
| `test-driven-development` | Enforcing red-green-refactor before implementation |
| `systematic-debugging` | Investigating root causes methodically before proposing fixes |
| `requesting-code-review` | Requesting focused review before issues compound |
| `receiving-code-review` | Evaluating review feedback critically before applying changes |
| `verification-before-completion` | Requiring fresh verification before claiming success |
| `using-git-worktrees` | Creating isolated worktrees for feature branches and plan execution |
| `finishing-a-development-branch` | Closing out finished work with explicit merge or cleanup choices |
| `writing-skills` | Creating or revising skills with trigger-focused descriptions and validation |

### Git and repository workflow

| Skill | Best for |
| --- | --- |
| `github-commit` | Generating complete git commit commands with concise defaults and explicit mode switches |

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

### Upstream superpowers sync

The allowlisted development-workflow skills imported from [`obra/superpowers`](https://github.com/obra/superpowers) are tracked in [vendor/superpowers.lock](/home/yyt/Documents/Github/cliskills/vendor/superpowers.lock). Use [scripts/sync_superpowers.sh](/home/yyt/Documents/Github/cliskills/scripts/sync_superpowers.sh) or `make sync-superpowers` to:

- fetch the upstream repository
- update only allowlisted `SKILL.md` files
- preserve local `agents/openai.yaml`
- refresh `claude/skills/`
- run `make validate-all`

The scheduled workflow at [.github/workflows/sync-superpowers.yml](/home/yyt/Documents/Github/cliskills/.github/workflows/sync-superpowers.yml) follows the same flow and opens a PR on `bot/sync-superpowers` instead of pushing to `main`.

### Dashboard

`make dashboard` combines the old `make help` and `make list` workflows into one place. It reads the bundled repo skills plus the default installed skills from `${CODEX_HOME:-$HOME/.codex}/skills` and `${CLAUDE_HOME:-$HOME/.claude}/skills`, shows match or drift status, and in a real TTY provides a numeric menu for:

- browsing bundled or installed skills
- installing or updating one Codex skill
- installing or updating one Claude skill
- installing or updating all bundled skills
- syncing the Claude mirror
- validating one skill or the whole repository

For scripting, use non-interactive actions such as `make dashboard ACTION=show`, `make dashboard ACTION=install-codex-skill SKILL=github-commit`, or `make dashboard ACTION=install-claude-skill SKILL=github-commit`.

### Installation modes

| Goal | Codex | Claude Code |
| --- | --- | --- |
| Use skills inside this repository | Work directly from `agents/skills/` | Use the generated `claude/skills/` mirror |
| Reuse skills across other repositories | `make install` installs into `${CODEX_HOME:-$HOME/.codex}/skills` and fails on conflicting local changes by default | `make install-claude` installs into `${CLAUDE_HOME:-$HOME/.claude}/skills` and fails on conflicting local changes by default |

### Typical workflow

1. Edit or add a skill under `agents/skills/<skill-id>/`.
2. Keep `SKILL.md`, `agents/openai.yaml`, and any support files aligned.
3. Run `make sync-claude`.
4. Run `make validate` or `make validate-all`.
5. Optionally test local installs with `make install` or `make install-claude`.
6. Use `make dashboard` when you want one interactive entry point for repo, Codex, and Claude skill state plus install or update actions.

Install behavior:

- default `INSTALL_MODE=fail`: stop if an installed skill differs from the source skill
- `INSTALL_MODE=keep`: keep the installed version when a conflict exists
- `INSTALL_MODE=overwrite`: replace the installed version
- local extra files under an installed skill are preserved when all source files already match

Validation dependency:

- `make validate-quick`, `make validate-all`, and the superpowers sync workflow use the repository-local [scripts/quick_validate.py](/home/yyt/Documents/Github/cliskills/scripts/quick_validate.py), which requires `PyYAML`. Install it with `python -m pip install pyyaml` if your local environment does not already provide it.

### Skill-specific setup notes

- `package-rpm-for-fedora`: install a Fedora/RHEL packaging toolchain before relying on the skill for native builds: `rpm-build`, `rpmdevtools`, `redhat-rpm-config`, `git`, `make`, `patch`, and a C compiler. For `.deb` or binary repack routes, also install `dpkg-deb` and optionally `alien` or `fpm` when those helpers are available on the host. Verify the current machine with `agents/skills/package-rpm-for-fedora/scripts/check_toolchain.sh source`, `agents/skills/package-rpm-for-fedora/scripts/check_toolchain.sh repack-deb`, or `agents/skills/package-rpm-for-fedora/scripts/check_toolchain.sh repack-binary`.

## How to invoke skills

For Codex, use either explicit invocation:

```text
Use $minimax-docx to format this Word document with the existing template.
Use $minimax-xlsx to fix formulas in this workbook without losing formatting.
Use $latex-bug to find the real cause of this compilation failure.
Use $package-rpm-for-fedora to turn this upstream tar.gz or .deb into a Fedora RPM and adjust the spec for this host.
Use $github-commit to generate the exact git add / commit / push commands for these changes, defaulting to a concise commit message.
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
make dashboard
make list
make list-ids
make list-metadata
make list-no-metadata
make list-claude
make sync-superpowers
make sync-claude
make validate
make validate-skill SKILL=github-commit
make validate-quick
make validate-all
make install
make install-claude
make install-claude-skill SKILL=github-commit
```

Useful variations:

```sh
make dashboard ACTION=show
make dashboard ACTION=install-codex-skill SKILL=github-commit
make dashboard ACTION=install-claude-skill SKILL=github-commit
make list LIST_FORMAT=ids
make sync-superpowers
make install-skill SKILL=minimax-pdf
make install INSTALL_MODE=overwrite
make install INSTALL_MODE=keep
make install INSTALL_DIR=/tmp/codex-skills-test
make install-claude CLAUDE_INSTALL_DIR=/tmp/claude-skills-test
make package
make release
```

## Makefile targets

- `make info`: show repository paths and discovered skill counts
- `make list`: list Codex source skills from `agents/skills/` with short descriptions
- `make list-ids`: list Codex source skill ids only
- `make list-metadata`: list skills that include skill-local `agents/openai.yaml`
- `make list-no-metadata`: list skills that still lack `agents/openai.yaml`
- `make list-claude`: list mirrored Claude skills with short descriptions
- `make list-claude-ids`: list mirrored Claude skill ids only
- `make dashboard`: show bundled and installed skill status, then offer interactive install, update, sync, and validation actions
- `make sync-claude`: refresh `claude/skills/` from the source tree
- `make sync-superpowers`: sync allowlisted `obra/superpowers` skills, then refresh and validate the mirror
- `make validate`: validate required docs, source skills, mirror alignment, and inline metadata
- `make validate-skill SKILL=<id>`: validate one source skill, its Claude mirror, and inline metadata
- `make validate-quick`: run Codex `quick_validate.py` across metadata-backed skills
- `make validate-all`: run both validation layers
- `make install`: install all skills locally for Codex; default conflicts fail
- `make install-skill SKILL=<id>`: install one Codex skill; default conflicts fail
- `make install-claude`: install all mirrored Claude skills into the user-scoped Claude directory; default conflicts fail
- `make install-claude-skill SKILL=<id>`: install one mirrored Claude skill into the user-scoped Claude directory; default conflicts fail
- `INSTALL_MODE=fail|overwrite|keep`: control install conflict handling; default is `fail`
- `make manifest`: generate `dist/MANIFEST.txt`
- `make package`: create `dist/cliskills-skills.tgz`
- `make release`: run sync, validation, manifest generation, and packaging

## References

- OpenAI Codex Skills documentation: <https://developers.openai.com/codex/skills>
- Claude Code skills documentation: <https://code.claude.com/docs/en/skills>
- TikZ example library: <https://tikz.net/>
