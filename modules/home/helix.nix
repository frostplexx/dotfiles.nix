_: {
  flake.homeManagerModules.helix = {pkgs, ...}: {
    programs.helix = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        nixd
        typescript-language-server
        rust-analyzer
        fish-lsp
        bash-language-server
      ];
      settings = {
        editor = {
          line-number = "relative";
          lsp = {
            display-messages = true;
          };
        };
        keys = {
          normal = {
            "space" = {
              "e" = [
                ":sh rm -f /tmp/unique-file"
                ":insert-output yazi '%{buffer_name}' --chooser-file=/tmp/unique-file"
                ":sh printf '\x1b[?1049h\x1b[?2004h' > /dev/tty"
                ":open %sh{cat /tmp/unique-file}"
                ":redraw"
              ];
            };
          };
        };
        theme = "catppuccin_transparent";
      };
      themes = {
        "catppuccin_transparent" = {
          inherits = "catppuccin_mocha";
          "ui.background" = {};
        };
      };
    };
  };
}
