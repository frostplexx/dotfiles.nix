{ pkgs }:

pkgs.mkShell {
  name = "latex";
  buildInputs = with pkgs; [
    # Base TeX Live installation
    texlive.combined.scheme-full

    # Additional tools
    texlab # Language server
    zathura # PDF viewer
    biber # Bibliography
  ];

  shellHook = ''

    export LATEX_SHELL=1

    echo "📚 LaTeX development environment activated!"
    echo "Use zathura to view PDF files. biber is available for bibliography management."
  '';
}
