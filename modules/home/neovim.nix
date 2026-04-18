_: {
  flake.homeManagerModules.neovim = {
    pkgs,
    lib,
    inputs,
    defaults,
    ...
  }: let
    # Helper files prefixed with _ to prevent import-tree from importing them as modules
    langaugesConfig = import ./neovim/_languages.nix {inherit pkgs;};
    keymapsConfig = import ./neovim/_keymap.nix {};
    optionsConfig = import ./neovim/_options.nix {};
    customPluginsConfig = import ./neovim/_customPlugins.nix {inherit pkgs lib inputs;};
    transparent_terminal = false;
  in {
    home.file = {
      ".vimrc".source = ./neovim/vimrc;
    };

    programs.nvf = {
      enable = true;
      enableManpages = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;
          globals.editorconfig = true;

          extraPackages = with pkgs; [
            fish-lsp
            rustup
          ];

          terminal.toggleterm = {
            setupOpts = {
              direction = "float";
              highlights.FloatBorder.guifg = "#${defaults.settings.accent_color}";
              float_opts = {
                border = "rounded";
              };
              enable_winbar = true;
            };
            # mappings.open = "<leader>tt";
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
              sourcekit-lsp = {
                cmd = [
                  (lib.getExe pkgs.sourcekit-lsp)
                ];
                filetypes = ["swift"];
                root_markers = [
                  ".git"
                  "src"
                  "Sources"
                  "sources"
                ];
              };

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

              mappings.suggestion.accept = "<C-CR>";
              setupOpts = {
                suggestion = {
                  enabled = true;
                  auto_trigger = true;
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
            enable = false;
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
              keymap = {
                preset = "none";
                "<C-space>" = [
                  "show"
                  "show_documentation"
                  "hide_documentation"
                ];
                "<C-e>" = [
                  "hide"
                  "fallback"
                ];
                "<Tab>" = [
                  (lib.generators.mkLuaInline ''
                    function(cmp)
                      if cmp.snippet_active() then return cmp.accept()
                      else return cmp.select_and_accept() end
                    end'')
                  "snippet_forward"
                  "fallback"
                ];
                "<S-Tab>" = [
                  "snippet_backward"
                  "fallback"
                ];

                "<Up>" = [
                  "select_prev"
                  "fallback"
                ];
                "<Down>" = [
                  "select_next"
                  "fallback"
                ];
                "<C-p>" = [
                  "select_prev"
                  "fallback_to_mappings"
                ];
                "<C-n>" = [
                  "select_next"
                  "fallback_to_mappings"
                ];

                "<C-b>" = [
                  "scroll_documentation_up"
                  "fallback"
                ];
                "<C-f>" = [
                  "scroll_documentation_down"
                  "fallback"
                ];

                "<C-k>" = [
                  "show_signature"
                  "hide_signature"
                  "fallback"
                ];
              };

              friendly-snippets.enable = true;
              cmdline = {
                keymap = {
                  preset = "none";
                  "<Tab>" = [
                    "show_and_insert_or_accept_single"
                    "select_next"
                  ];
                  "<S-Tab>" = [
                    "show_and_insert_or_accept_single"
                    "select_prev"
                  ];

                  "<C-space>" = [
                    "show"
                    "fallback"
                  ];

                  "<C-n>" = [
                    "select_next"
                    "fallback"
                  ];
                  "<C-p>" = [
                    "select_prev"
                    "fallback"
                  ];
                  "<Right>" = [
                    "select_next"
                    "fallback"
                  ];
                  "<Left>" = [
                    "select_prev"
                    "fallback"
                  ];

                  "<C-y>" = [
                    "select_and_accept"
                    "fallback"
                  ];
                  "<C-e>" = [
                    "cancel"
                    "fallback"
                  ];
                };
                completion.menu.auto_show = true;
              };
              signature.enabled = true;
              completion = {
                ghost_text.enabled = false;
                menu = {
                  border = "rounded";
                  auto_show = true;
                };
                documentation.auto_show = true;
              };
            };
          };

          snippets.luasnip = {
            enable = true;
            loaders = "require('luasnip.loaders.from_vscode').lazy_load()";
            setupOpts.enable_autosnippets = true;
            providers = [
              "friendly-snippets"
              "blink-cmp"
            ];
          };

          navigation.harpoon = {
            enable = true;
            mappings = {
              file1 = "<leader>1";
              file2 = "<leader>2";
              file3 = "<leader>3";
              file4 = "<leader>4";
              listMarks = "<C-e>";
              markFile = "<leader>a";
            };
          };

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
                  [vim.diagnostic.severity.INFO] = " ",
                  [vim.diagnostic.severity.HINT] = "",
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

              vim.cmd("packadd nvim.undotree")
              vim.keymap.set("n", "<leader>u", require("undotree").open)
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
