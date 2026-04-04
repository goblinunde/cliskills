# PDF Translation Workflow

## First Decision

- Text-based PDF: translate directly from extracted text.
- Scan-based PDF: expect OCR-like errors, broken paragraphs, and uncertain symbols.
- Mixed PDF: treat tables, figures, and headers cautiously.

## Recommended Output Modes

- Translated Markdown for reading and revision
- Structured notes preserving section headings
- Draft LaTeX reconstruction only when the user needs editable output
- Bilingual notes when comparison with the source matters

## Fidelity Rules

- Preserve equations, numbering, and citation markers.
- Do not promise identical pagination or layout unless rebuilding.
- Be explicit when extraction quality is poor around tables, footnotes, and multi-column pages.

## Hand-off Guidance

- If the user later provides the original `.tex`, switch to `latex-tex-translate`.
- If the real need is slide translation, use `latex-beamer-translate`.
- If the translated text needs academic rewriting, use `latex-academic-polish`.
