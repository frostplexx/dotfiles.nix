_: {
flake.homeManagerModules.neovim-plugin-distant = {
  pkgs,
  inputs,
  ...
}: {
  programs.nvf.settings.vim.lazy.plugins."distant.nvim" = {
    package = pkgs.vimPlugins.distant-nvim;
    lazy = true;
    setupModule = "distant";
    # setupOpts = {};
    keys = [];
    cmd = ["DistantInstall" "DistantConnect"];
  };
};
}
