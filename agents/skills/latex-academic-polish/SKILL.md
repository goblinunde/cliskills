---
name: latex-academic-polish
description: Use when the user asks to polish academic prose in LaTeX or LaTeX-adjacent text without changing technical meaning, especially for abstracts, introductions, conclusions, captions, cover letters, rebuttals, and related writing. Strong triggers include "学术润色", "润色摘要", "improve academic writing", "polish this LaTeX paper", and "让语言更像论文". Do not use when the primary task is language translation, PDF extraction, or compiler debugging.
---

# LaTeX Academic Polish

Use this skill to improve academic tone, clarity, concision, and sentence flow while preserving the author's claims and LaTeX structure.

Read `references/academic-style-guidelines.md` when polishing a full paper or when the user asks for a stronger journal or conference tone.

## Language Handling

- Respond in the user's language, but preserve the target prose language being polished.
- Keep commands, citation keys, math, and labels intact unless the user explicitly asks for formatting changes.
- Do not silently change technical claims, results, or notation.

## Workflow

1. Identify the target output style: more concise, more formal, more native, more persuasive, or venue-specific.
2. Determine the scope: abstract, intro, conclusion, captions, response letter, or full manuscript.
3. Polish the prose while preserving structure and argument order.
4. Reduce repetition, hedge unsupported claims, and tighten long sentences.
5. If the text was machine-translated, fix tone and readability without re-opening the entire technical content.

## Editing Rules

- Prefer precise academic phrasing over ornamental wording.
- Keep terminology stable across abstract, section titles, and captions.
- Preserve author intent and evidence level; do not overclaim.
- If the request is actually cross-language translation, use `latex-tex-translate` or `latex-pdf-translate`.

## Example Triggers

- "帮我润色这段 LaTeX 摘要。"
- "Polish this introduction for an academic paper."
- "Make these figure captions sound more natural in English."
- "把这段英文学术写作改得更像论文，但不要改公式。"

## Output Expectations

- State the polishing goal briefly.
- Highlight major writing-level improvements if the user asks for explanation.
- Mention if the text would benefit from translation first or from venue-specific adaptation.
