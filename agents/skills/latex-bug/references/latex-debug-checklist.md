# LaTeX Debug Checklist

## First Pass

- Capture the exact compiler command.
- Read the first fatal error in the `.log`.
- Check whether the engine matches the packages in use.
- Verify whether the failing file is the main document, an included file, a class, or a generated auxiliary file.

## Common Root Causes

- `Undefined control sequence`: missing package, typo, wrong engine, or macro defined too late.
- `Missing } inserted` or runaway argument: unmatched braces, fragile commands in moving arguments, or malformed environments.
- Font errors: `fontspec` under `pdflatex`, missing system fonts, or mixed CJK/font packages.
- Bibliography errors: `bibtex` vs `biber` mismatch, missing backend run, malformed `.bib`.
- Reference issues: stale `.aux`, wrong compile order, or duplicated labels.

## Build-Chain Checks

- Does the project expect `latexmk` instead of a single engine run?
- Does it need `-shell-escape`, `minted`, or external conversion tools?
- Are custom build scripts passing the correct main file and output directory?

## `.cls` / `.sty` Review

- Confirm whether the class uses `\LoadClass` or reimplements behavior unnecessarily.
- Check option declaration and forwarding with `\DeclareOption`, `\ProcessOptions`, or `kvoptions`.
- Inspect package load order and duplicate package loading.
- Look for fragile global redefinitions of sectioning, captions, floats, or font commands.
- Check whether user-level macros are documented and stable.

## Minimal-Fix Principle

- Prefer a one-line package or engine fix over a large rewrite.
- If the design itself is broken, state that clearly before proposing a broader refactor.
