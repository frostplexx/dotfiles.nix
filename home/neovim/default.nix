_: {
  imports = [
    ./neovim.nix
    # ./opencode.nix
  ];

  home.file = {
    # Copy LTeX configuration files
    # "ltex.hiddenFalsePositives.en-US.txt".text = builtins.readFile ./ltex/ltex.dictionary.en-US.txt;
    # "ltex.dictionary.en-US.txt".text = builtins.readFile ./ltex/ltex.hiddenFalsePositives.en-US.txt;

    # Copy vimrc and ideavimrc
    ".vimrc".text = builtins.readFile ./vimrc;
    ".ideavimrc".text = builtins.readFile ./ideavimrc;
  };
}
