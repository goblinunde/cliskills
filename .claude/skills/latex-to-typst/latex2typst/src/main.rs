use clap::Parser;
use regex::Regex;
use std::fs;
use std::io::{self, Read};

#[derive(Parser)]
#[command(name = "latex2typst", about = "Convert LaTeX to typst")]
struct Args {
    /// Input file (stdin if not provided)
    #[arg(short, long)]
    input: Option<String>,
    
    /// Output file (stdout if not provided)
    #[arg(short, long)]
    output: Option<String>,
}

fn convert(latex: &str) -> String {
    let mut result = latex.to_string();
    
    // Sections
    let section = Regex::new(r"\\section\{([^}]+)\}").unwrap();
    result = section.replace_all(&result, "= $1").to_string();
    
    let subsection = Regex::new(r"\\subsection\{([^}]+)\}").unwrap();
    result = subsection.replace_all(&result, "== $1").to_string();
    
    let subsubsection = Regex::new(r"\\subsubsection\{([^}]+)\}").unwrap();
    result = subsubsection.replace_all(&result, "=== $1").to_string();
    
    // Text formatting
    let textbf = Regex::new(r"\\textbf\{([^}]+)\}").unwrap();
    result = textbf.replace_all(&result, "*$1*").to_string();
    
    let textit = Regex::new(r"\\textit\{([^}]+)\}").unwrap();
    result = textit.replace_all(&result, "_$1_").to_string();
    
    let texttt = Regex::new(r"\\texttt\{([^}]+)\}").unwrap();
    result = texttt.replace_all(&result, "`$1`").to_string();
    
    // Math - display equations
    let display_math = Regex::new(r"\$\$([^$]+)\$\$").unwrap();
    result = display_math.replace_all(&result, "$ $1 $").to_string();
    
    let equation_env = Regex::new(r"\\begin\{equation\*?\}([\s\S]*?)\\end\{equation\*?\}").unwrap();
    result = equation_env.replace_all(&result, "$ $1 $").to_string();
    
    let align_env = Regex::new(r"\\begin\{align\*?\}([\s\S]*?)\\end\{align\*?\}").unwrap();
    result = align_env.replace_all(&result, "$ $1 $").to_string();
    
    // Math commands
    let frac = Regex::new(r"\\frac\{([^}]+)\}\{([^}]+)\}").unwrap();
    result = frac.replace_all(&result, "frac($1, $2)").to_string();
    
    let sqrt = Regex::new(r"\\sqrt\{([^}]+)\}").unwrap();
    result = sqrt.replace_all(&result, "sqrt($1)").to_string();
    
    let sum = Regex::new(r"\\sum_\{([^}]+)\}\^\{([^}]+)\}").unwrap();
    result = sum.replace_all(&result, "sum_($1)^($2)").to_string();
    
    let int = Regex::new(r"\\int_\{([^}]+)\}\^\{([^}]+)\}").unwrap();
    result = int.replace_all(&result, "integral_($1)^($2)").to_string();
    
    // Greek letters
    let greek = [
        ("\\alpha", "alpha"), ("\\beta", "beta"), ("\\gamma", "gamma"),
        ("\\delta", "delta"), ("\\epsilon", "epsilon"), ("\\theta", "theta"),
        ("\\lambda", "lambda"), ("\\mu", "mu"), ("\\pi", "pi"),
        ("\\sigma", "sigma"), ("\\phi", "phi"), ("\\omega", "omega"),
        ("\\Gamma", "Gamma"), ("\\Delta", "Delta"), ("\\Sigma", "Sigma"),
    ];
    for (latex_cmd, typst_cmd) in greek {
        result = result.replace(latex_cmd, typst_cmd);
    }
    
    // Citations
    let cite = Regex::new(r"\\cite\{([^}]+)\}").unwrap();
    result = cite.replace_all(&result, "@$1").to_string();
    
    // Remove common preamble
    let doc_class = Regex::new(r"\\documentclass.*\n?").unwrap();
    result = doc_class.replace_all(&result, "").to_string();
    
    let usepackage = Regex::new(r"\\usepackage.*\n?").unwrap();
    result = usepackage.replace_all(&result, "").to_string();
    
    let begin_doc = Regex::new(r"\\begin\{document\}\n?").unwrap();
    result = begin_doc.replace_all(&result, "").to_string();
    
    let end_doc = Regex::new(r"\\end\{document\}\n?").unwrap();
    result = end_doc.replace_all(&result, "").to_string();
    
    result.trim().to_string()
}

fn main() -> io::Result<()> {
    let args = Args::parse();
    
    let input = match args.input {
        Some(path) => fs::read_to_string(path)?,
        None => {
            let mut buf = String::new();
            io::stdin().read_to_string(&mut buf)?;
            buf
        }
    };
    
    let output = convert(&input);
    
    match args.output {
        Some(path) => fs::write(path, output)?,
        None => println!("{}", output),
    }
    
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_sections() {
        assert_eq!(convert(r"\section{Hello}"), "= Hello");
        assert_eq!(convert(r"\subsection{World}"), "== World");
    }
    
    #[test]
    fn test_formatting() {
        assert_eq!(convert(r"\textbf{bold}"), "*bold*");
        assert_eq!(convert(r"\textit{italic}"), "_italic_");
    }
    
    #[test]
    fn test_math() {
        assert_eq!(convert(r"\frac{a}{b}"), "frac(a, b)");
        assert_eq!(convert(r"\sqrt{x}"), "sqrt(x)");
    }
}
