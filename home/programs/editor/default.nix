# programs/editor/default.nix
{ pkgs, lib, ... }:
let
  # Filter out lazy-lock.json from the source directory
  nvimConfigFiltered = lib.cleanSourceWith {
    src = ./nvim;
    filter = path: type:
      let
        baseName = baseNameOf path;
      in
      baseName != "lazy-lock.json";
  };
in
{

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      tree-sitter
      git
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
  };
}
