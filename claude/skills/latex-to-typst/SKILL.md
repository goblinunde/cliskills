---
name: latex-to-typst
description: Convert LaTeX documents and equations to typst format with syntax validation
---

# LaTeX to Typst (L3 - Autonomous)

You are executing the latex-to-typst skill.

## User Request
$ARGUMENTS

## Purpose
Mechanically convert LaTeX documents to typst, validating syntax and compilation.

## Autonomy Level: L3 (Autonomous)
- **Human**: Provide input, accept output
- **AI**: Convert → validate → test compile → done

## Agent Loop
```
while not conversion_complete:
    coder.parse_latex(input)
    writer.generate_typst(parsed)
    prover.validate_syntax()
    prover.test_compile()
    if errors:
        coder.fix_errors()
    else:
        present_to_human(output)
```

## Conversion Rules

| LaTeX | Typst |
|-------|-------|
| `\section{X}` | `= X` |
| `\subsection{X}` | `== X` |
| `$...$` | `$...$` |
| `$$...$$` | `$ ... $` (block) |
| `\frac{a}{b}` | `a/b` or `frac(a,b)` |
| `\sqrt{x}` | `sqrt(x)` |
| `\begin{equation}` | `$ ... $` |
| `\cite{ref}` | `@ref` |
| `\textbf{X}` | `*X*` |
| `\textit{X}` | `_X_` |

## Input Required
- LaTeX source (file or text)
- Package dependencies to handle

## Output
- typst file with equivalent content
- Compilation test result

## Human Checkpoint
- Review edge cases AI might have missed
- Verify mathematical notation renders correctly

## Tool

`latex2typst` - Rust CLI for fast conversion.

```bash
cd latex2typst && cargo build --release

# Convert file
./target/release/latex2typst -i input.tex -o output.typ

# Pipe stdin
echo '\section{Hello} $\frac{a}{b}$' | ./target/release/latex2typst
```
