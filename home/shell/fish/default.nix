{
  pkgs,
  lib,
  ...
}: {
  programs = {
    fish = {
      enable = true;
      plugins = with pkgs.fishPlugins; [
        {
          name = "macos";
          inherit (macos) src;
        }
        {
          name = "tide";
          inherit (tide) src;
        }
      ];

      shellAliases = {
        v = "nvim";
        g = "lazygit";
        s = "spotify_player";
        c = "clear";
        q = "exit";
        j = "just";
        p = "cd $(ls -d -1 ~/Developer/* |fzf); kitten @ launch --location=hsplit --bias=20 --cwd $PWD;nvim .";
        cat = "bat";
        tree = "eza --icons --git --header --tree";
        vimdiff = "nvim -d";
        cd = "z";
        compress_to_mp4 = "~/dotfiles.nix/home/shell/scripts/compress_mp4.sh";
        ssh = "~/dotfiles.nix/home/shell/scripts/ssh.sh";
        ff = "~/dotfiles.nix/home/shell/scripts/window_select.sh";
        shinit = "~/dotfiles.nix/home/shell/scripts/shell_select.sh";
      };

      shellAbbrs = {
        copy = "rsync -avz --partial --progress";
        transfer = "kitten transfer --direction=receive";
        nhs = "nh search";
      };

      shellInit = ''
        set -g fish_greeting ""
        fish_vi_key_bindings
      '';

      interactiveShellInit = ''
        fish_config theme choose "Catppuccin Mocha"
      '';
    };
  };

  # Themes cant be installed as plugins so I load it directly into the themes folder
  xdg.configFile = {
    "fish/themes/Catppuccin Mocha.theme" = {
      text = builtins.readFile (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/fish/main/themes/Catppuccin%20Mocha.theme";
        sha256 = "kdA9Vh23nz9FW2rfOys9JVmj9rtr7n8lZUPK8cf7pGE=";
      });
    };
  };

  # Tide config command:
  # tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=Yes
  # Custom activation script to configure tide
  home.activation.configureTide = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ${pkgs.fish}/bin/fish -c "tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=Yes"
  '';
}
