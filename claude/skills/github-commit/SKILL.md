---
name: github-commit
description: 'Generate or execute safe Git and GitHub commit workflows when the user asks to commit code, write a commit message, produce `git add` / `git commit` / `git push` commands, or prepare a repository for GitHub submission. Strong triggers include "提交代码", "git commit", "commit message", "帮我写提交命令", "中文 commit", "丰富 commit", "push 到 GitHub", and "生成提交代码". Default behavior: output a complete shell command sequence with a concise commit message. Only switch modes when the user explicitly asks for them: use Chinese commit text only when the prompt mentions "中文"; use a richer multi-line message only when the prompt mentions "丰富", "详细", or similar; create or update `.gitignore`, `.github/workflows/*`, GitHub Actions, or `README.md` only when those items are explicitly requested. Do not use for PR review, release-note writing, or generic Git debugging unless the main goal is preparing or performing a commit.'
---

# GitHub Commit

Match the user's language, but keep commands, file paths, branch names, and commit subjects verbatim.

Read `references/modes-and-addons.md` when choosing message style, push behavior, or optional repository extras.

## Default behavior

When the user simply asks to "commit", "提交", or "给我提交代码":

1. Inspect the repository state first.
2. Infer the narrowest relevant file set.
3. Output a complete shell command sequence.
4. Keep the commit message concise by default.

Default means:

- one short subject line
- no extra body paragraphs
- no `.gitignore`, workflow, or README edits unless explicitly requested
- no `git push` unless the user explicitly asks to push, submit, or upload to GitHub

## Required inspection

Before writing commit commands, inspect:

- `git status --short`
- `git diff --stat` or a targeted diff when needed
- `git branch --show-current` if push may be requested

If the workspace contains unrelated changes, stage only the intended paths. Do not sweep unrelated files into the commit.

## Mode switches

Switch only when the prompt explicitly asks:

- `中文`: write the commit message in Chinese
- `丰富`, `详细`, `完整说明`: use a multi-line commit message with a body
- `push`, `推送`, `提交到 GitHub`, `上传到 GitHub`: include a push command
- `.gitignore`: create or update `.gitignore` before the commit
- `workflow`, `action`, `GitHub Actions`: create or update `.github/workflows/*.yml` before the commit
- `README`, `README.md`, `文档`: update `README.md` only when the user asks for it

If multiple switches are present, combine them. Example: `中文 + 丰富 + push`.

## Output rules

- Prefer a shell code block first, then one or two short lines of explanation if needed.
- Use explicit `git add <path>` for scoped work. Use `git add -A` only when the whole working tree is intentionally part of the commit.
- Use one-line `git commit -m "..."` for the default mode.
- Use multiple `-m` flags for rich commit bodies instead of fragile interactive editors.
- For `.gitignore`, workflow, and README add-ons, inspect existing files first and patch them minimally. Create the file only when it does not already exist.
- If the user asks only for commands, do not add extra commentary.
- If the repo state is ambiguous, state the assumption briefly before the command block.
