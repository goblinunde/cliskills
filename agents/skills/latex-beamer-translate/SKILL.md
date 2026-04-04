---
name: latex-beamer-translate
description: Use when the user asks to translate a Beamer slide deck, defense presentation, lecture slides, or talk outline into another language while keeping slides presentation-friendly. Strong triggers include "翻译 beamer", "答辩 PPT 改英文", "slides 翻译", "把演示文稿变成中文", and "translate this Beamer deck". Prioritize slide density, title length, and spoken delivery, not literal sentence-by-sentence translation. Do not use for general Beamer design work, figure-specific TikZ work, or PDF-first translation.
---

# LaTeX Beamer Translate

Use this skill for slide-aware translation of Beamer decks. The job is to translate the content and keep the result usable in an actual presentation.

Read `references/beamer-translation-rules.md` when the deck is long, dense, or intended for a live academic talk.

## Language Handling

- Match the user's language for explanations.
- Preserve LaTeX frame structure, macros, overlays, labels, and commands.
- Translate visible slide text, but condense aggressively when the target language becomes too long for the slide.

## Workflow

1. Identify the target language and audience: defense committee, lecture audience, conference talk, or classroom use.
2. Preserve the frame structure first; only split or merge frames when the translated slide becomes overcrowded.
3. Shorten titles and bullets to maintain presentation rhythm.
4. Keep equations, citations, and references intact unless the user asks for localized notation.
5. Flag frames that may need visual redesign after translation due to text expansion.

## Editing Rules

- Do not translate LaTeX control sequences or overlay syntax.
- Prefer spoken-style slide text over paragraph-like literal translation.
- Keep one key idea per frame when possible.
- If the request is about general deck design rather than translation, use `latex-beamer`.
- If the input is only a PDF deck, start with `latex-pdf-translate`.

## Example Triggers

- "把这个 Beamer 答辩 PPT 翻译成英文。"
- "Translate these lecture slides into Chinese and keep them concise."
- "帮我把这套 slides 改成法语，但不要让每页太挤。"
- "Keep the formulas and layout logic, but localize the slide text."

## Output Expectations

- State the target language and whether slide density was adjusted.
- Mention any frames that probably need manual visual cleanup.
- Explain when literal translation was intentionally shortened for presentation quality.
