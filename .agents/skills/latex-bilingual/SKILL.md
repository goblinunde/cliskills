---
name: latex-bilingual
description: Use when the user asks to generate a bilingual LaTeX document, bilingual abstract, dual-language captions, or side-by-side translated output such as Chinese-English or English-French. Strong triggers include "中英对照", "双语摘要", "bilingual LaTeX", "双语讲义", and "parallel translation". This skill is for paired output, not just one-way translation. Do not use for plain translation-only requests, PDF extraction, or compile debugging.
---

# LaTeX Bilingual

Use this skill to produce paired-language output from one source document. The main job is to choose a readable bilingual structure and keep the two languages aligned.

Read `references/bilingual-patterns.md` when the user wants full-document dual-language output or multiple layout options.

## Language Handling

- Confirm the language pair, for example Chinese-English, English-French, or Chinese-Japanese.
- Preserve LaTeX structure, labels, citations, macros, and math.
- Keep terminology aligned across both languages so the paired output stays comparable.

## Workflow

1. Determine the bilingual format: paragraph-then-paragraph, side-by-side columns, mirrored sections, or bilingual abstract/captions only.
2. Identify the scope: full document, abstract, slides, captions, or notes.
3. Translate and align visible prose while preserving technical structure.
4. Keep heading order and numbering synchronized across languages.
5. Flag places where one language becomes much longer and may require layout-specific adjustments.

## Editing Rules

- Do not treat bilingual output as plain translation; the structure must make cross-language comparison easy.
- Preserve equations, references, and labels once rather than duplicating them carelessly.
- If the user only wants one target language, use `latex-tex-translate` instead.
- If the text needs stylistic cleanup after translation, use `latex-academic-polish`.

## Example Triggers

- "帮我做一个中英对照摘要。"
- "Create a bilingual Chinese-English LaTeX handout."
- "把这个论文引言改成英法对照版本。"
- "I need parallel bilingual captions for all figures."

## Output Expectations

- State the language pair and chosen bilingual layout.
- Mention any sections where alignment may need manual layout tuning.
- Keep cross-language terminology consistent and easy to compare.
