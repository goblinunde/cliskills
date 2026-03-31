---
name: latex-bug
description: Use when the user asks to diagnose or fix LaTeX compile failures, package conflicts, engine mismatches, missing fonts, broken references, bibliography issues, or class/style-file problems, including `.cls`, `.sty`, `.bst`, and build scripts. Strong Chinese triggers include "编译错误", "报错排查", "无法编译", "Undefined control sequence", ".cls 审查", ".sty 问题", "latexmk", "xelatex", and "帮我看日志". Do not use for pure content writing, slide polish, or TikZ design unless the primary task is debugging.
---

# LaTeX Bug

Use this skill when the main task is finding the real cause of a LaTeX failure and proposing the smallest safe fix. This includes `.tex` sources, `.cls` and `.sty` review, and build-chain diagnosis.

Read `references/latex-debug-checklist.md` for systematic triage, especially when multiple cascading errors appear.

## Language Handling

- Match the user's language. If the report is in Chinese, explain the root cause and fix path in Chinese.
- Preserve exact error messages, command names, compiler engines, and file extensions verbatim.
- When the user provides only screenshots or pasted logs, restate the first real error line clearly before proposing fixes.

## Example Triggers

- "这个 LaTeX 项目编译不过，帮我看日志。"
- "为什么我用 xelatex 会报 fontspec 错误？"
- "帮我审查一下这个 .cls 文件有没有坑。"
- "Find the real cause of this LaTeX build failure."

## Workflow

1. Reproduce or inspect the failure. Prefer the `.log` file, compiler command, and exact engine over screenshots alone.
2. Identify the first real error, not the last cascade message.
3. Confirm the build environment: `pdflatex`, `xelatex`, `lualatex`, `latexmk`, `biber`, `bibtex`, or custom scripts.
4. Separate source issues from environment issues such as missing fonts, missing classes, shell-escape restrictions, or unavailable external tools.
5. For `.cls` or `.sty` review, inspect class inheritance, option handling, package load order, robust command definitions, and hidden side effects.
6. Propose the smallest patch that removes the root cause. Avoid broad rewrites unless the class design is unsound.

## Debugging Rules

- Always quote the exact failing command or error line when available.
- Treat `Undefined control sequence`, `Missing }`, and encoding errors as root-cause candidates early.
- Watch for engine-specific assumptions such as `fontspec` with `xelatex`/`lualatex` only.
- Check whether the issue is caused by stale auxiliary files before changing source logic.
- If the project spans Beamer structure or TikZ design after the bug is fixed, hand off to `latex-beamer` or `latex-tikz`.

## Output Expectations

- State the root cause, the minimal fix, and any follow-up cleanup.
- Mention whether the change is source-only or also requires a build-command change.
- For `.cls` reviews, call out API-level risks, option collisions, and package-order hazards explicitly.
