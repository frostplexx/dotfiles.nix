_: {
  flake.homeManagerModules.neovim = {
    pkgs,
    lib,
    ...
  }: {
    programs.nvf = {
      enable = true;
      enableManpages = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;
          globals.editorconfig = true;

          assistant = {
            copilot = {
              enable =
                if pkgs.stdenv.hostPlatform.isDarwin
                then true
                else false;

              mappings.suggestion.accept = "<C-cr>";
              setupOpts = {
                suggestion = {
                  enabled = true;
                  auto_trigger = true;
                };
                nes.enabled = false;
              };
            };
          };

          visuals = {
            nvim-web-devicons.enable = true;
            rainbow-delimiters.enable = true;
          };

          presence.cord-nvim.enable = true;

          extraPackages = with pkgs; [
            copilot-language-server
          ];

          lsp = {
            enable = true;
            lspkind.enable = true;
            inlayHints.enable = true;

            mappings = {
              codeAction = "<leader>ca";
              goToDeclaration = "<leader>gD";
              goToDefinition = "<leader>gd";
              goToType = "<leader>gt";
              hover = "K";
              signatureHelp = "<leader>lk";
              listDocumentSymbols = "<leader>ls";
              listImplementations = "<leader>li";
              listReferences = "<leader>lr";
              nextDiagnostic = "]d";
              openDiagnosticFloat = "<leader>cd";
              previousDiagnostic = "[d";
              renameSymbol = "<leader>cr";
            };
          };

          debugger = {
            nvim-dap = {
              enable = true;
              ui.enable = true;

              # nvf's `adapters` `oneOf` doesn't dispatch on `type`, so the
              # codelldb preset's `executable` sub-attr is rejected.
              # Bypass via `luaInline` — it's the first type `oneOf` checks.
              adapters.codelldb = let
                codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
                liblldb = "liblldb${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
              in
                lib.mkForce (
                  lib.generators.mkLuaInline ''
                    {
                      type = "server",
                      port = "${"$"}{port}",
                      executable = {
                        command = "${codelldb}/bin/codelldb",
                        args = { "--liblldb", "${codelldb}/share/lldb/lib/${liblldb}", "--port", "${"$"}{port}" },
                      },
                    }
                  ''
                );
            };
          };

          lazy.enable = true;

          treesitter = {
            enable = true;
            addDefaultGrammars = true;
            grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
              toml
              diff
              gitcommit
              git_rebase
              gitignore
              dockerfile
              css
              sql
              regex
            ];
          };

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
            textwidth = 120;
          };

          theme = {
            enable = true;
            name = "catppuccin";
            style = "mocha";
            transparent = true;
          };
          autocomplete.blink-cmp = {
            enable = true;
            mappings = {
              next = null;
              previous = null;
              complete = null;
              close = null;
              scrollDocsUp = null;
              scrollDocsDown = null;
            };

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
            ];
          };

          ui = {
            noice.enable = true;
            borders = {
              enable = true;
              globalStyle = "rounded";
              plugins.lsp-signature.enable = true;
            };
          };

          git = {
            gitsigns.enable = true;
            gitsigns.codeActions.enable = false;
          };

          statusline.lualine = {
            enable = true;
            integrations.breadcrumbs = {
              nvim-navic.enable = false;
              navbuddy.enable = false;
            };
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
            snacks-nvim = {
              enable = true;
              setupOpts = {
                styles = {
                  term = {
                    position = "float";
                    backdrop = 60;
                    height = 0.9;
                    width = 0.9;
                    zindex = 50;
                    border = true;
                  };
                };

                picker = {};
                gh = {};
                indent = {
                  animate.enabled = false;
                };
                input = {};
                lazygit = {};
                notifier = {};
                quickfile = {};
                scope = {};
                words = {};
                terminal = {
                  win = {
                    style = "term";
                  };
                };
              };
            };

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
            yazi-nvim = {
              enable = true;
              setupOpts = {
                open_for_directories = false;
                yazi_floating_window_border = "rounded";
              };
              mappings.openYazi = "<leader>e";
            };
          };

          #TODO: Migrate to snacks
          mini = {
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

          luaConfigRC.my-config =
            /*
            lua
            */
            ''

              vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#585b70" })
              vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#313244" })

              vim.g.loaded_netrwPlugin = 1

              vim.keymap.set(
                "v",
                "<leader>s",
                'y:%s/<C-r>"//gc<Left><Left><Left>',
                { desc = "Search and replace selected text across file" }
              )

              vim.keymap.set("n", "<leader>u", function()
                vim.cmd("packadd nvim.undotree")
                require("undotree").toggle()
              end)
            '';
        };
      };
    };
  };
}
