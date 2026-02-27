_: {
  flake.modules.homeManager.neovim = {
    pkgs,
    lib,
    ...
  }: let
    # Helper files prefixed with _ to prevent import-tree from importing them as modules
    langaugesConfig = import ./neovim/_languages.nix {inherit pkgs;};
    keymapsConfig = import ./neovim/_keymap.nix {};
    optionsConfig = import ./neovim/_options.nix {};
    customPluginsConfig = import ./neovim/_customPlugins.nix {inherit pkgs lib;};
    transparent_terminal = false;
  in {
    home.file = {
      ".vimrc".source = ./neovim/vimrc;
    };

    programs.nvf = {
      enable = true;
      enableManpages = true;
      settings = {
        # Inject the latex language module into the nvf submodule
        imports = [./neovim/_latex.nix];

        vim = {
          viAlias = true;
          vimAlias = true;
          globals.editorconfig = true;

          extraPackages = with pkgs; [
            fish-lsp
          ];

          terminal.toggleterm = {
            enable = true;
            lazygit.enable = true;
          };

          lsp = {
            enable = true;
            lspkind.enable = true;
            inlayHints.enable = true;
            harper-ls.enable = true;

            mappings = {
              codeAction = "<leader>ca";
              openDiagnosticFloat = "<leader>cd";
              renameSymbol = "<leader>cr";
              goToDefinition = "<leader>gd";
              goToDeclaration = "<leader>gD";
              hover = "K";
              nextDiagnostic = "]d";
              previousDiagnostic = "[d";
            };

            servers = {
              fish-lsp = {
                cmd = [
                  (lib.getExe pkgs.fish-lsp)
                  "start"
                ];
                filetypes = ["fish"];
                root_markers = [
                  ".git"
                  "src"
                ];
              };
            };
          };

          assistant = {
            copilot = {
              enable =
                if pkgs.stdenv.isDarwin
                then true
                else false;
              cmp.enable = true;
              mappings.suggestion.accept = "<C-CR>";
              setupOpts = {
                suggestion = {
                  enabled = true;
                  auto_trigger = true;
                };
              };
            };

            avante-nvim = {
              enable =
                if pkgs.stdenv.isDarwin
                then true
                else false;
              setupOpts = {
                input = {
                  provider = "native";
                  provider_opts = {};
                };
                providers.copilot.model = "oswe-vscode-prime";
                mode = "legacy";
                provider = "copilot";
                hints.enabled = false;
                windows = {
                  width = 40;
                  sidebar_header.enabled = false;
                };
              };
            };
          };

          debugger = {
            nvim-dap = {
              enable = true;
              ui.enable = true;
            };
          };

          inherit (optionsConfig) options;
          inherit (langaugesConfig) languages;
          inherit (keymapsConfig) keymaps;
          inherit (customPluginsConfig) lazy;

          treesitter = {
            enable = true;
            addDefaultGrammars = true;
            autotagHtml = true;
            grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
          };

          statusline.lualine = {
            enable = true;
            theme = "catppuccin";
          };

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
            transparent = transparent_terminal;
          };

          autocomplete.blink-cmp = {
            enable = true;
            setupOpts = {
              keymap.preset = "super-tab";
              signature.enabled = true;
              completion = {
                ghost_text.enabled = false;
                menu.border = "rounded";
              };
            };
          };

          snippets.luasnip.enable = true;

          ui = {
            noice.enable = true;
            borders = {
              enable = true;
              globalStyle = "rounded";
              plugins.lsp-signature.enable = true;
            };
            breadcrumbs = {
              enable = false;
              navbuddy.enable = false;
            };
          };

          git = {
            gitsigns.enable = true;
            gitsigns.codeActions.enable = false;
          };

          diagnostics = {
            enable = true;
            nvim-lint.enable = true;
            config = {
              signs.text = lib.generators.mkLuaInline ''
                {
                  [vim.diagnostic.severity.ERROR] = "󰅚 ",
                  [vim.diagnostic.severity.WARN] = "󰀪 ",
                  [vim.diagnostic.severity.INFO] = " ",
                  [vim.diagnostic.severity.HINT] = " ",
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
            diffview-nvim = {
              enable = true;
              setupOpts = {
                enhanced_diff_hl.enable = true;
                merge_tool = {
                  layout = "diff3_mixed";
                  disable_diagnostics = true;
                  winbar_info = true;
                };
              };
            };
            smart-splits.enable = true;
            yazi-nvim = {
              enable = true;
              setupOpts = {
                open_for_directories = true;
                yazi_floating_window_border = "rounded";
              };
              mappings.openYazi = "<leader>e";
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
                mappings.choose_marked = "<C-q>";
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
                  prompt_prefix = " ";
                };
                options.use_cache = true;
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

          luaConfigRC.my-config = ''
            vim.keymap.set(
              "v",
              "<leader>s",
              'y:%s/<C-r>"//gc<Left><Left><Left>',
              { desc = "Search and replace selected text across file" }
            )

            -- Toggle floating terminal
            local term_buf = nil
            local term_win = nil

            vim.keymap.set('n', '<leader>t', function()
              -- If window is open, close it
              if term_win and vim.api.nvim_win_is_valid(term_win) then
                vim.api.nvim_win_close(term_win, true)
                term_win = nil
                return
              end

              -- Reuse existing terminal buffer if still valid
              if not (term_buf and vim.api.nvim_buf_is_valid(term_buf)) then
                term_buf = vim.api.nvim_create_buf(false, true)
              end

              local width = math.floor(vim.o.columns * 0.8)
              local height = math.floor(vim.o.lines * 0.7)
              local row = math.floor((vim.o.lines - height) / 2)
              local col = math.floor((vim.o.columns - width) / 2)

              term_win = vim.api.nvim_open_win(term_buf, true, {
                relative = 'editor',
                width = width,
                height = height,
                row = row,
                col = col,
                style = 'minimal',
                border = 'rounded',
              })

              -- Only start the terminal job if the buffer doesn't have one yet
              if vim.bo[term_buf].buftype ~= 'terminal' then
                vim.fn.termopen(os.getenv('SHELL') or 'sh', {
                  cwd = vim.fn.getcwd(),
                })
              end

              vim.cmd('startinsert')
            end, { desc = "Toggle floating terminal" })

            -- Close the float from terminal mode too
            vim.keymap.set('t', '<Esc>', function()
              if term_win and vim.api.nvim_win_is_valid(term_win) then
                vim.api.nvim_win_close(term_win, false)
                term_win = nil
              end
            end, { desc = "Close floating terminal" })
          '';

          augroups = [{name = "MergeTool";}];

          autocmds = [
            # Open DiffView automatically when entering diff mode.
            {
              event = ["OptionSet"];
              pattern = ["diff"];
              group = "MergeTool";
              desc = "Open DiffView when vim.difftool is activated";
              callback = lib.generators.mkLuaInline ''
                function()
                  if vim.o.diff then
                    require("diffview").open()
                  end
                end
              '';
            }
          ];
        };
      };
    };
  };
}
