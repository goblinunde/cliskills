# tikz.net Workflow

## How to Use the Site

- Start at `https://tikz.net/`.
- Use category clues from the home page such as Science, Topics, and Authors to narrow style and domain.
- Search by figure type or concept, for example `site:tikz.net commutative diagram`, `site:tikz.net flowchart`, or `site:tikz.net geometry`.

## Adaptation Strategy

- Copy structure, not clutter. Reuse coordinate systems, scopes, and style patterns that match the target figure.
- Replace hard-coded coordinates with named coordinates when the user will likely revise the figure later.
- Convert repeated drawing options into `\tikzset` styles.
- Remove decorative details unless they support the user's actual goal.

## PGF/TikZ Hygiene

- List libraries explicitly in the answer.
- Prefer `positioning` or calculated coordinates over manual spacing guesses when layout relationships matter.
- For plots, note whether `pgfplots` is required and whether compatibility settings are needed.

## Attribution Note

`tikz.net` states that the site is licensed under CC BY-SA 4.0. If a solution stays very close to a specific example, mention the source page and preserve attribution expectations.

## Final Check

- Can the user rename nodes or change labels without redrawing everything?
- Are styles centralized?
- Are library requirements complete?
- Does the code still make sense outside a standalone example page?
