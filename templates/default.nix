{pkgs}: let
  # Import shell templates
  shells = {
    c = import ./c.nix {inherit pkgs;};
    latex = import ./latex.nix {inherit pkgs;};
    node = import ./node.nix {inherit pkgs;};
    python = import ./python.nix {inherit pkgs;};
    rust = import ./rust.nix {inherit pkgs;};
    typst = import ./typst.nix {inherit pkgs;};
  };
in
  shells
