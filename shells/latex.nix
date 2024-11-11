{ pkgs }:

pkgs.mkShell {
  name = "latex";
  buildInputs = with pkgs; [
    # Base TeX Live installation
    texlive.combined.scheme-full

    # Additional tools
    latexmk # Build tool
    texlab # Language server
    zathura # PDF viewer
    biber # Bibliography
  ];

  shellHook = ''

    # Initialize project if it doesn't exist
    if [ ! -f "main.tex" ]; then
      echo "Creating new LaTeX project..."
      cat > main.tex << 'EOL'
\documentclass[12pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{amsmath}
\usepackage{amsfonts}
\usepackage{amssymb}
\usepackage{graphicx}
\usepackage{hyperref}

\title{Your Title Here}
\author{Your Name}
\date{\today}

\begin{document}

\maketitle

\section{Introduction}
Your content here.

\end{document}
EOL

      # Create a basic .gitignore
      cat > .gitignore << 'EOL'
## Core latex/pdflatex auxiliary files:
*.aux
*.lof
*.log
*.lot
*.fls
*.out
*.toc
*.fmt
*.fot
*.cb
*.cb2
.*.lb

## Generated if empty string is given at "Please type another file name for output:"
.pdf

## Bibliography auxiliary files (bibtex/biblatex/biber):
*.bbl
*.bcf
*.blg
*-blx.aux
*-blx.bib
*.run.xml

## Build tool auxiliary files:
*.fdb_latexmk
*.synctex
*.synctex(busy)
*.synctex.gz
*.synctex.gz(busy)
*.pdfsync
EOL

      echo "🎨 LaTeX project initialized! Use 'latexmk -pdf main.tex' to compile."
    fi

    export LATEX_SHELL=1

    echo "📚 LaTeX development environment activated!"
  '';
}
