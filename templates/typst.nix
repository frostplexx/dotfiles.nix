{pkgs}:
pkgs.mkShell {
  name = "latex";
  buildInputs = with pkgs; [
    typst
    zathura # PDF viewer
  ];

  shellHook = ''

    export LATEX_SHELL=1

    echo "📚 Typst development environment activated!"
    echo "Use zathura to view PDF files."
  '';
}
