---
name: latex-pdf-translate
description: Use when the user asks to translate a PDF paper, handout, article, thesis, or slide deck into another language, especially for LaTeX-generated academic PDFs. Strong triggers include "翻译 PDF", "论文 PDF 改成中文", "translate this paper PDF", "讲义翻译", and "把 PDF 变成英文". Start by determining whether the PDF is text-based or scan-based, and avoid promising perfect layout reconstruction unless the user explicitly wants a recreation workflow. Do not use for direct `.tex` source translation or compiler debugging.
---

# LaTeX PDF Translate

Use this skill when the source artifact is a PDF rather than editable LaTeX. The main job is to extract readable content, translate it, and be explicit about fidelity limits.

Read `references/pdf-translation-workflow.md` when the PDF is long, scan-like, or expected to become a translated LaTeX draft afterward.

## Language Handling

- Match the user's language for explanations and status notes.
- Preserve equations, symbols, citation markers, figure/table numbering, and section hierarchy where extraction quality allows.
- Do not claim exact layout preservation unless you are actually rebuilding the document.

## Workflow

1. Determine whether the PDF is text-based, image-based, or mixed.
2. Decide the output format: plain translated text, structured Markdown, bilingual notes, or a reconstructed LaTeX draft.
3. Translate extracted prose while preserving equations, references, and document order as much as possible.
4. If extraction quality is poor, state that clearly and reduce confidence in fine-grained formatting or sentence boundaries.
5. Recommend a follow-up path when the user actually needs editable LaTeX rather than translated reading notes.

## Editing Rules

- Separate translation quality from extraction quality; poor extraction can dominate the result.
- Preserve formulas and numbered references verbatim unless the user asks for notation changes.
- When the PDF is clearly a Beamer deck, prefer `latex-beamer-translate` if the user wants slide-aware output.
- If the user later provides `.tex` sources, switch to `latex-tex-translate`.

## Example Triggers

- "把这篇论文 PDF 翻译成中文。"
- "Translate this PDF article to French."
- "帮我把这个 PDF 讲义变成英文学习笔记。"
- "I only have the PDF. Translate it and keep formulas intact."

## Output Expectations

- State whether the PDF appears text-based or scan-based.
- Say what output form you are delivering.
- Flag OCR or extraction uncertainty when relevant.
