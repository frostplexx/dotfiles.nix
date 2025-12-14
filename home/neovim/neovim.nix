{
  lib,
  pkgs,
  ...
}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        lazy.enable = false;
        viAlias = true;
        vimAlias = true;

        options = {
          clipboard = "unnamedplus";
          tabstop = 4;
          softtabstop = 4;
          shiftwidth = 4;
          expandtab = true;
          smartindent = true;
          fileencoding = "utf-8";
          wrap = false;
          swapfile = false;
          backup = false;
          undofile = true;
        };

        lsp = {
          enable = true;
        };

        assistant = {
          copilot = {
            enable = true;
            cmp.enable = true;
          };
        };

        languages = {
          enableTreesitter = true;
          nix.enable = true;
          ts.enable = true;
          rust.enable = true;
          python.enable = true;
        };

        treesitter = {
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

        keymaps = [
          {
            key = "<leader>go";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniDiff.toggle_overlay() end";
          }
          {
            key = "<leader>d";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniBufremove.delete() end";
          }
          {
            key = "<leader>f";
            mode = "n";
            silent = true;
            noremap = false;
            lua = true;
            action = "function() MiniPick.builtin.files() end";
          }
          {
            key = "<leader>gf";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniPick.builtin.grep_live() end";
          }
          {
            key = "<leader>ss";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniExtra.pickers.lsp({ scope = 'workspace_symbol' }) end";
          }
          {
            key = "<leader>tr";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniExtra.pickers.diagnostic() end";
          }
          {
            key = "<leader>bf";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniPick.builtin.buffers() end";
          }
          {
            key = "<leader>mk";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniExtra.pickers.keymaps() end";
          }
          {
            key = "<leader>ms";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() MiniExtra.pickers.marks() end";
          }
          {
            key = "yc";
            mode = "n";
            noremap = false;
            lua = true;
            silent = true;
            action = "function() vim.api.nvim_feedkeys('yygccp', 'm', false) end";
            desc = "Duplicate a line and comment out the first line";
          }
          {
            key = "<Esc>";
            mode = "n";
            silent = true;
            action = "<cmd>nohlsearch<CR>";
          }

          {
            key = "<c-u>";
            mode = "n";
            silent = true;
            action = "<c-u>zz";
            desc = "scroll up half a screen";
          }
          {
            key = "<c-d>";
            mode = "n";
            silent = true;
            action = "<c-d>zz";
            desc = "scroll down half a screen";
          }
          {
            key = "<leader>s";
            mode = "v";
            silent = true;
            action = "y:%s/<C-r>/\"//gc<Left><Left><Left>";
            desc = "Search and replace selected text across file";
          }
          {
            key = "<leader>n";
            mode = "n";
            silent = true;
            action = ":NoiceHistory<cr>";
            desc = "Search and replace selected text across file";
          }
          {
            key = "<leader>gg";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() Snacks.lazygit() end";
            desc = "Open Lazygit";
          }
        ];
      };
    };
  };
}
