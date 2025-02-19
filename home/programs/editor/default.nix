# programs/editor/default.nix
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  # Filter out lazy-lock.json from the source directory
  nvimConfigFiltered = lib.cleanSourceWith {
    src = ./nvim;
    filter = path: _type: let
      baseName = baseNameOf path;
    in
      baseName != "lazy-lock.json";
  };
  treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (_plugins: pkgs.tree-sitter.allGrammars);
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      git
      nodejs

      # Debug
      # vscode-extensions.vadimcn.vscode-lldb
    ];

    plugins = [
      treeSitterWithAllGrammars
    ];
  };

  # Copy your Neovim configuration
  xdg.configFile = {
    # Copy the filtered nvim configuration directory
    "nvim" = {
      source = nvimConfigFiltered;
      recursive = true;
    };
  };

  # home.packages = [
  #   codelldb-fhs
  # ];

  home.file = {
    # Copy LTeX configuration files
    "ltex.hiddenFalsePositives.en-US.txt".text = builtins.readFile ./ltex/ltex.dictionary.en-US.txt;
    "ltex.dictionary.en-US.txt".text = builtins.readFile ./ltex/ltex.hiddenFalsePositives.en-US.txt;

    # Copy vimrc and ideavimrc
    ".vimrc".text = builtins.readFile ./vimrc;
    ".ideavimrc".text = builtins.readFile ./ideavimrc;

    # Ensure the .local/share/nvim directory exists with correct permissions
    ".local/share/nvim/.keep" = {
      text = "";
      onChange = ''
        mkdir -p $HOME/.local/share/nvim
        chmod 755 $HOME/.local/share/nvim
      '';
    };

    # Treesitter is configured as a locally developed module in lazy.nvim
    # we hardcode a symlink here so that we can refer to it in our lazy config
    ".local/share/nvim/nix/nvim-treesitter/" = {
      recursive = true;
      source = treeSitterWithAllGrammars;
    };

    # ".local/share/codelldb" = {
    #   source = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
    #   recursive = true;
    # };
  };
}
