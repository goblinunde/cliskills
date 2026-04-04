---
name: latex-tex-translate
description: Use when the user asks to translate a LaTeX source document or fragment (`.tex`, section, abstract, caption, theorem, appendix) between Chinese, English, French, German, Japanese, or similar languages while preserving commands, environments, citations, labels, equations, macros, and overall structure. Strong triggers include "翻译 tex", "把 LaTeX 论文改成英文", "论文翻译", "translate this .tex", "caption 翻译", and "摘要翻译". Do not use for PDF-first translation, Beamer slide translation, or compiler debugging.
---

# LaTeX TeX Translate

Use this skill for source-level translation of LaTeX documents. The primary goal is to translate human-readable prose without corrupting LaTeX structure.

Read `references/tex-translation-rules.md` when translating a full paper, multi-file project, or document with heavy macro usage.

## Language Handling

- Match the user's working language for explanations.
- Preserve LaTeX commands, environment names, citation keys, labels, macro names, and math verbatim unless the user explicitly asks to localize them.
- Translate visible prose only: titles, paragraphs, captions, theorem text, list items, and comments when requested.

## Workflow

1. Identify the target language and the translation scope: full document, selected section, abstract only, captions only, or appendix.
2. Inspect the source structure before editing. Note custom macros, multilingual packages, bibliography style, and any generated content.
3. Translate prose while preserving command boundaries and argument structure.
4. Keep technical terminology consistent across repeated terms, section titles, figure captions, and theorem statements.
5. Flag any compile risks if the translated text introduces unsupported characters, encoding issues, or package requirements.

## Editing Rules

- Do not translate `\label{}`, `\ref{}`, `\cite{}`, `\eqref{}`, file names, or macro identifiers by default.
- Preserve math mode content unless the user explicitly wants notation rewritten.
- Be careful with optional arguments and moving arguments such as section titles and captions.
- If the request is actually about slide translation, use `latex-beamer-translate`.
- If the source is a PDF rather than `.tex`, use `latex-pdf-translate`.

## Example Triggers

- "把这个 tex 文件翻译成英文。"
- "Translate this LaTeX paper to Chinese without breaking the commands."
- "帮我把摘要和图注改成法语。"
- "Keep the formulas and citations unchanged, but translate the prose."

## Output Expectations

- State the target language and translated scope clearly.
- Mention any protected elements left unchanged.
- Call out encoding or engine concerns when non-ASCII text is introduced.
