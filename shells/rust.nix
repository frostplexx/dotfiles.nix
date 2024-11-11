{ pkgs }:
pkgs.mkShell {
  name = "rust";
  buildInputs = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
  ];

  shellHook = ''
    # Inherit existing environment
    source ~/.zshrc 2>/dev/null || true

    # Rust-specific configuration
    export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"

    echo "Rust development environment activated!"
  '';
}
