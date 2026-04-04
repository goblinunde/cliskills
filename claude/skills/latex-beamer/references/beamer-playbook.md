# Beamer Playbook

## Structure First

- Open with motivation, problem, or contribution before details.
- Keep section boundaries visible with `\section` and optional outline frames only when they help navigation.
- Move proofs, full tables, and backup material to appendix frames.

## Frame Density

- Target one claim per frame.
- Prefer 3 to 5 bullets. If there are more, split the frame or convert to a diagram/table.
- For equations, show the final form first and reveal derivation only if needed for the talk.

## Visual Consistency

- Keep title capitalization, punctuation, and notation consistent.
- Align figure widths and table sizing across adjacent frames.
- Define repeated colors or box styles once in the preamble.

## Overlays

- Use `<+->`, `\pause`, or overlay specifications only when sequence matters.
- Avoid overlays that cause large layout jumps between steps.
- For handouts, check whether overlay behavior needs `handout`-specific adjustments.

## Common Rewrite Patterns

- Bullet wall -> two frames or one diagram plus one takeaway frame.
- Dense table -> highlight only rows/columns discussed orally.
- Long theorem/proof -> theorem frame plus intuition frame.
- Screenshot-heavy frame -> crop tightly and add one caption with the point.

## Final Check

- Verify every frame title says what the audience should learn.
- Check appendix, bibliography, and cross-references still compile.
- Confirm theme and fonts match the target engine (`pdflatex`, `xelatex`, or `lualatex`).
