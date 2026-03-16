_: {
  # Jinx module for Darwin
  flake.modules.darwin.repodex = {pkgs, ...}: let
    repodex = pkgs.rustPlatform.buildRustPackage rec {
      pname = "repodex";
      version = "0.1.0"; # adjust if needed
      src = ./repodex;

      cargoHash = "sha256-57prOQy6Hju1y7xvhRPgpnm0sPehsGpJzyVDaSplxwg=";

      # Optional: you can define build inputs if your Rust project uses e.g., openssl
      buildInputs = with pkgs; [
        openssl
      ];

      nativeBuildInputs = with pkgs; [
        pkg-config
      ];

      # Optional: if you want to install binaries
      cargoInstallFlags = ["--locked"];
    };
  in {
    environment.systemPackages = [repodex];
  };
}
