{
  lib,
  pkgs,
  ...
}: let
  langaugesConfig = import ./languages.nix {};
  keymapsConfig = import ./keymap.nix {};
  optionsConfig = import ./options.nix {};
  # autocmdsConfig = import ./autocmds.nix {inherit lib;};
in {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        lazy.enable = false;
        viAlias = true;
        vimAlias = true;

        lsp = {
          enable = true;
          inlayHints.enable = true;
          # lspSignature.enable = true; doesn't work with blink-cmp
        };

        assistant = {
          copilot = {
            enable = true;
            cmp.enable = true;
          };
        };

        inherit (optionsConfig) options;
        inherit (langaugesConfig) languages;
        inherit (keymapsConfig) keymaps;
        # inherit (autocmdsConfig) autocmds;

        treesitter = {
          enable = true;
          addDefaultGrammars = true;
          autotagHtml = true;
          grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
        };

        statusline.lualine.enable = true;

        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = true;
        };

        autocomplete.blink-cmp = {
          enable = true;
          setupOpts = {
            keymap.preset = "super-tab";
            signature.enabled = true;
            completion = {
              ghost_text.enabled = true;
              menu.border = "rounded";
            };
          };
          friendly-snippets.enable = true;
        };

        # FIXME: Find a better plugin that isnt slow as balls
        presence.neocord = {
          enable = false;
        };

        ui = {
          noice.enable = true;
          borders = {
            enable = true;
            globalStyle = "rounded";
          };
          breadcrumbs = {
            enable = false;
          };
        };

        git = {
          gitsigns.enable = true;
        };

        diagnostics = {
          enable = true;
          nvim-lint.enable = true;
          config = {
            signs.text = lib.generators.mkLuaInline ''
              {
                [vim.diagnostic.severity.ERROR] = "󰅚 ",
                [vim.diagnostic.severity.WARN] = "󰀪 ",
                [vim.diagnostic.severity.INFO] = " ",
                [vim.diagnostic.severity.HINT] = " ",
              }
            '';
            virtual_text = {
              prefix = "";
              spacing = 2;
              source = "if_many";
              format = lib.generators.mkLuaInline ''
                function(diagnostic)
                  return diagnostic.message
                end
              '';
            };
          };
        };

        utility = {
          snacks-nvim.enable = true;
          smart-splits.enable = true;
          yazi-nvim = {
            enable = true;
            setupOpts = {
              open_for_directories = true;
              yazi_floating_window_border = "rounded";
            };
            mappings.yaziToggle = "<leader>e";
          };
        };

        mini = {
          ai.enable = true;
          bufremove.enable = true;
          icons.enable = true;
          extra.enable = true;

          starter = {
            enable = true;
            setupOpts = lib.generators.mkLuaInline ''
              {
                  items = {
                      require("mini.starter").sections.builtin_actions(),
                      { name = "Open Last File", action = "'0", section = "Builtin actions" }
                  },
                  content_hooks = {
                      require("mini.starter").gen_hook.aligning('center', 'center'),
                  },
                  footer = "",
                  silent = true,
              }
            '';
          };

          pick = {
            enable = true;
            setupOpts = {
              mappings = {
                choose_marked = "<C-q>";
              };
              window = {
                config = lib.generators.mkLuaInline ''
                  function()
                    local picker_width = 80
                    local picker_height = 35
                    return {
                      anchor = 'NW',
                      col = math.floor((vim.o.columns - picker_width) / 2),
                      row = vim.o.lines - (picker_height + 3),
                      width = picker_width,
                      height = picker_height,
                      relative = 'editor',
                    }
                  end
                '';
                prompt_prefix = " ";
              };
              options = {
                use_cache = true;
              };
            };
          };

          diff = {
            enable = true;
            setupOpts = {
              view = {
                style = "sign";
                signs = {
                  add = "┃";
                  change = "┃";
                  delete = "┃";
                };
              };
            };
          };

          move = {
            enable = true;
            setupOpts = {
              mappings = {
                left = "<S-h>";
                right = "<S-l>";
                down = "<S-j>";
                up = "<S-k>";
              };
            };
          };

          hipatterns = {
            enable = true;
            setupOpts = {
              highlighters = {
                fixme = {
                  pattern = "%f[%w]()FIXME()%f[%W]";
                  group = "MiniHipatternsFixme";
                };
                hack = {
                  pattern = "%f[%w]()HACK()%f[%W]";
                  group = "MiniHipatternsHack";
                };
                todo = {
                  pattern = "%f[%w]()TODO()%f[%W]";
                  group = "MiniHipatternsTodo";
                };
                note = {
                  pattern = "%f[%w]()NOTE()%f[%W]";
                  group = "MiniHipatternsNote";
                };
              };
            };
          };
          align.enable = true;
        };
      };
    };
  };
}
