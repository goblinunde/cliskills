---
name: latex-beamer
description: Use when the user asks to create, revise, tighten, theme, or optimize a LaTeX Beamer deck, including requests about slides (`.tex`), frames, overlays, handouts, talk flow, or defense presentations ("beamer", "幻灯片", "答辩PPT"). Do not use for TikZ-focused figure work or general LaTeX compiler debugging unless the Beamer deck itself is the main target.
---

# LaTeX Beamer

Use this skill for Beamer-first work: building a new talk, restructuring an existing deck, or improving readability, pacing, and visual consistency.

Read `references/beamer-playbook.md` when the request involves a full deck, theme cleanup, or major slide-density problems.

## Workflow

1. Determine the job: new deck, rewrite, style cleanup, or slide reduction.
2. Inspect the preamble before editing. Note theme, color theme, font theme, custom macros, bibliography setup, and handout/notes options.
3. Preserve the author's structure unless it is clearly broken. Prefer fixing frame flow and repetition before changing visual styling.
4. Optimize for spoken delivery. One frame should usually communicate one idea, not a mini-paper.
5. When content is dense, split frames, move derivations to appendix, or use overlays only if they improve narration.

## Editing Rules

- Keep frame titles parallel and informative.
- Prefer short bullets over paragraphs.
- Use blocks, columns, and theorem environments only when they improve scanning.
- Reuse existing macros and theme conventions instead of introducing one-off formatting.
- Avoid animation-heavy overlays unless the user explicitly wants them.
- If a frame is overloaded, reduce to the core claim and suggest appendix or backup slides.

## Output Expectations

- Explain the presentation-level change, not just the TeX diff.
- Flag any compile risks caused by missing theme files, fonts, or external images.
- If the request crosses into TikZ-heavy diagram work, use `latex-tikz` for the figure design.
- If the main issue is a compile error, package conflict, or `.cls` behavior, use `latex-bug`.
