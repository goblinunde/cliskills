# TeX Translation Rules

## Always Preserve

- control sequences such as `\section`, `\caption`, `\newcommand`
- citation and reference keys
- labels and cross-reference targets
- file paths and bibliography file names
- math notation unless the user explicitly asks for notation changes

## Usually Translate

- visible prose in titles, paragraphs, captions, theorem text, proofs, and itemized lists
- footnotes and acknowledgements when they are reader-facing
- comments only if the user asks for them

## High-Risk Areas

- optional arguments: `\section[Short]{Long}`
- moving arguments: captions, section titles, bookmarks
- macro-heavy templates where visible text is wrapped in custom commands
- documents mixing CJK, `fontspec`, or engine-specific settings

## Quality Checklist

- Terminology is consistent across title, abstract, and captions.
- No braces or command arguments were broken.
- Line-level edits do not change citation or reference behavior.
- The answer states whether a follow-up compile check is advisable.
