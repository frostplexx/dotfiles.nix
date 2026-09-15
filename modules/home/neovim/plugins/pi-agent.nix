_: {
  flake.homeManagerModules.neovim-plugin-pi-agent = {
    pkgs,
    lib,
    ...
  }: {
    programs.nvf.settings.vim.lazy.plugins."pi-agent.nvim" = {
      package = pkgs.stdenvNoCC.mkDerivation {
        pname = "pi-agent.nvim";
        name = "pi-agent.nvim";
        version = "c722decc083d1007e3db006b75b415aef4a958cb";
        src = pkgs.fetchFromGitHub {
          owner = "Run1e";
          repo = "pi-agent.nvim";
          rev = "c722decc083d1007e3db006b75b415aef4a958cb";
          hash = "sha256-8rywRsDCBG5Ge6rzzdztXg84lGdEyuFUjIz7okXMhTI=";
        };
        dontBuild = true;
        installPhase = ''
          mkdir -p $out
          cp -r ./* $out/
        '';
      };
      lazy = true;
      setupModule = "pi-agent";
      setupOpts = lib.mkLuaInline ''
        {
          pi_bin = "${pkgs.pi-coding-agent}/bin/pi",
          surface = require("pi-agent.surfaces.nvim"),
        }
      '';
      keys = [
        {
          key = "<leader>as";
          action = "function() require('pi-agent').start() end";
          lua = true;
          mode = "n";
          desc = "Open Pi Agent";
        }
        {
          key = "<leader>af";
          action = "function() require('pi-agent').focus() end";
          lua = true;
          mode = "n";
          desc = "Focus Pi Agent";
        }
        {
          key = "<leader>ac";
          action = "function() require('pi-agent').close() end";
          lua = true;
          mode = "n";
          desc = "Close Pi Agent";
        }
        {
          key = "<leader>al";
          action = "function() require('pi-agent').paste_cursor_location() end";
          lua = true;
          mode = [
            "n"
            "x"
          ];
          desc = "pi: Paste Cursor Location";
        }
        {
          key = "<leader>ar";
          action = "function() require('pi-agent').paste_section_location() end";
          lua = true;
          mode = [
            "n"
            "x"
          ];
          desc = "pi: Paste Cursor Location";
        }
        {
          key = "<leader>ap";
          action = "function() require('pi-agent').paste_selection_contents() end";
          lua = true;
          mode = [
            "n"
            "x"
          ];
          desc = "pi: Paste Selection Contents";
        }
      ];
    };
  };
}
