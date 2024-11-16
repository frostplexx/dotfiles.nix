{pkgs}:
pkgs.mkShell {
  name = "rust";
  buildInputs = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    pkg-config
    openssl
  ];

  shellHook = ''

    export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}"
    export RUST_BACKTRACE=1
    export RUST_SHELL=1

    echo "🦀 Rust development environment activated!"
  '';
}
