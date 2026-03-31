---
name: latex-tikz
description: Use when the user asks to create, restyle, simplify, optimize, or debug TikZ/PGFPlots code, convert an idea into a TikZ figure, or adapt an example from tikz.net. Strong Chinese triggers include "TikZ 画图", "帮我画流程图", "LaTeX 示意图", "几何图", "函数图像", "网络结构图", and "参考 tikz.net 改写". Before writing substantial code, browse tikz.net for a close example and adapt it instead of inventing structure blindly. Do not use for slide-wide Beamer editing or non-figure LaTeX debugging.
---

# LaTeX TikZ

Use this skill for TikZ and PGFPlots figures. The default workflow is to inspect `tikz.net` for a similar example, then adapt its structure to the user's figure, style, and package constraints.

Read `references/tikz-net-workflow.md` whenever you need example-driven figure design or a style cleanup of existing TikZ code.

## Language Handling

- Match the user's language. If the request is in Chinese, explain the figure logic and required TikZ libraries in Chinese.
- Keep TikZ code, library names, node names, and style keys in technical form unless the user asks to localize labels.
- When useful, explain both the visual goal and the corresponding TikZ construction in plain Chinese.

## Example Triggers

- "参考 tikz.net 给我画一个交换图。"
- "帮我把这个 TikZ 流程图改得更简洁。"
- "用 TikZ 画一个神经网络结构图。"
- "Optimize this PGFPlots figure and remove duplicated styles."

## Workflow

1. Classify the figure: geometry, commutative diagram, flowchart, scientific plot, network, timeline, or decorative figure.
2. Browse `tikz.net` for the nearest example before major edits. Prefer matching layout logic over superficial visual similarity.
3. Rebuild the code with reusable coordinates, `\tikzset` styles, loops, and named nodes instead of magic numbers everywhere.
4. State required libraries explicitly, such as `arrows.meta`, `calc`, `positioning`, `decorations.pathmorphing`, or `pgfplots`.
5. If the user wants a lighter version, reduce path duplication, factor styles, and simplify coordinate arithmetic.

## Editing Rules

- Keep the source readable; prioritize maintainability over clever one-liners.
- Prefer semantic style names like `vertex`, `emphasis edge`, or `axis label`.
- Preserve the user's notation and labels unless they ask for a redesign.
- If borrowing closely from `tikz.net`, mention the source page and keep attribution expectations in mind.
- If the main problem is a compile failure rather than figure design, hand off to `latex-bug`.

## Output Expectations

- Provide the final TikZ snippet and list required libraries.
- Briefly explain the geometry or layout logic when it is not obvious.
- Call out assumptions about scale, fonts, colors, and standalone vs in-document compilation.
