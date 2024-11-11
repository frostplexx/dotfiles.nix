{ pkgs }:

pkgs.mkShell {
  name = "c";
  buildInputs = with pkgs; [
    gcc
    gnumake
    cmake
    clang-tools # For clangd LSP
  ];

  shellHook = ''
    export C_SHELL=1

    echo "🔧 C development environment activated!"
  '';
}
