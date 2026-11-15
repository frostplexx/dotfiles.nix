{inputs, ...}: {
  flake.homeManagerModules.neovim = {pkgs, ...}: {
    home.packages = [
      inputs.nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
