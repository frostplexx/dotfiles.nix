_: {
  flake.homeManagerModules.neovim-smart-splits = {pkgs, ...}: let
    # nvf pins smart-splits v2, which predates pluggable mux backends.
    smart-splits-source = pkgs.fetchFromGitHub {
      owner = "smart-splits-nvim";
      repo = "smart-splits.nvim";
      rev = "6a03b298635205802ee1d390826f02414a13290d";
      hash = "sha256-6gB1vSxJposF5MyuoVcbxkp3tlhkueENSruQWDVEGig=";
      name = "smart-splits";
    };
  in {
    programs.nvf.settings.vim = {
      lazy.plugins."smart-splits" = {
        package = smart-splits-source;
        lazy = false;
        # Without setupModule nvf emits no setup() call, so setupOpts are dropped
        setupModule = "smart-splits";
        setupOpts.mux.backend = "smart-splits-backend-rex";
        keys = [
          {
            key = "<C-h>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').move_cursor_left() end";
          }
          {
            key = "<C-j>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').move_cursor_down() end";
          }
          {
            key = "<C-k>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').move_cursor_up() end";
          }
          {
            key = "<C-l>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').move_cursor_right() end";
          }
          {
            key = "<A-h>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').resize_left() end";
          }
          {
            key = "<A-j>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').resize_down() end";
          }
          {
            key = "<A-k>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').resize_up() end";
          }
          {
            key = "<A-l>";
            mode = "n";
            lua = true;
            action = "function() require('smart-splits').resize_right() end";
          }
        ];
      };

      extraPlugins.smart-splits-backend-rex = {
        package = pkgs.fetchFromGitHub {
          owner = "rawnly";
          repo = "smart-splits-backend-rex";
          rev = "45785cf5d15dd5e0e6cf25ab9682a146acb93379";
          hash = "sha256-lqLdyVticzh0uv0dX1LBhfep3doRpKuidkp8QbzVG6Y=";
          name = "smart-splits-backend-rex";
        };
        setup = "require('smart-splits-backend-rex').setup {}";
      };
    };
  };
}
