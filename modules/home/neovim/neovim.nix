_: {
  flake.homeManagerModules.neovim = {
    pkgs,
    lib,
    defaults,
    ...
  }: {
    home.file = {
      ".vimrc".source = ./vimrc;
    };

    programs.nvf = {
      enable = true;
      enableManpages = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;
          globals.editorconfig = true;

          visuals = {
            nvim-web-devicons.enable = true;
            rainbow-delimiters.enable = true;
          };

          extraPackages = with pkgs; [
            copilot-language-server
            fish-lsp
            rustup
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
              listDocumentSymbols = "<leader>ls";
              listImplementations = "<leader>li";
              listReferences = "<leader>lr";
              nextDiagnostic = "]d";
              openDiagnosticFloat = "<leader>cd";
              previousDiagnostic = "[d";
              renameSymbol = "<leader>cr";
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

              rust-analyzer = {
                lsp.opts = ''
                  ["rust-analyzer"] = {
                       files = { excludeDirs = { ".direnv" } }
                     }
                '';
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

          debugger = {
            nvim-dap = {
              enable = true;
              ui.enable = true;

              # nvf's `adapters` `oneOf` doesn't dispatch on `type`, so the
              # codelldb preset's `executable` sub-attr is rejected.
              # Bypass via `luaInline` — it's the first type `oneOf` checks.
              adapters.codelldb = let
                codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
              in
                lib.mkForce (lib.generators.mkLuaInline ''
                  {
                    type = "server",
                    port = "${"$"}{port}",
                    executable = {
                      command = "${codelldb}/bin/codelldb",
                      args = { "--liblldb", "${codelldb}/share/lldb/lib/liblldb.so", "--port", "${"$"}{port}" },
                    },
                  }
                '');
            };
          };

          # Options, keymaps, languages and lazy-loaded plugins are split into
          # sibling flake-parts modules (./options.nix, ./keymaps.nix,
          # ./languages.nix, ./plugins/*.nix). nvf's settings submodule
          # deep-merges them across home-manager modules.
          lazy.enable = true;

          treesitter = {
            enable = true;
            addDefaultGrammars = true;
            autotagHtml = true;
            grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
          };

          theme = {
            enable = true;
            name =
              {
                "catppuccin" = "catppuccin";
                "rose-pine" = "rose-pine";
              }
                .${
                defaults.settings.theme
              };
            style =
              {
                "catppuccin" = "mocha";
                "rose-pine" = "moon";
              }
                .${
                defaults.settings.theme
              };
            transparent = true;
          };
          autocomplete.blink-cmp = {
            enable = true;

            # nvf builds setupOpts.keymap from these `mappings` (active because
            # vim.vendoredKeymaps is enabled) and MERGES it with our explicit
            # setupOpts.keymap below. Since each key is `listOf …`, the module
            # system *concatenates* the lists with nvf's entries first — so
            # nvf's default `next = "<Tab>" -> select_next` ran before our
            # super-tab accept and shadowed it ("just selects the next item").
            # Null every mapping we define ourselves so our keymap is the single
            # source of truth; keep `confirm` so <CR> still accepts.
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
                # super-tab: Tab checks for copilot NES first, then accepts
                # the (pre)selected completion or jumps the snippet.
                "<Tab>" = [
                  (lib.generators.mkLuaInline ''
                    function(cmp)
                      if vim.b[vim.api.nvim_get_current_buf()].nes_state then
                        cmp.hide()
                        return (
                          require("copilot-lsp.nes").apply_pending_nes()
                          and require("copilot-lsp.nes").walk_cursor_end_edit()
                        )
                      end
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
                statuscolumn = {
                  folds.git_hl = true;
                };
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
                open_for_directories = true;
                yazi_floating_window_border = "rounded";
              };
              mappings.openYazi = "<leader>e";
            };
          };

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

          luaConfigRC.my-config = ''

            vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#585b70" })
            vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#313244" })

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
            # vim.schedule defers out of the OptionSet autocmd context,
            # where splits/buffer edits are not allowed (E788).
            # The "Claude Code" guard prevents diffview from hijacking
            # claudecode.nvim's own native diff buffers. The reentrancy flag and
            # get_current_view() check stop diffview from re-triggering itself:
            # opening it sets 'diff' on its own buffers, which re-fires this
            # OptionSet autocmd and would otherwise spawn tabs forever.
            {
              event = ["OptionSet"];
              pattern = ["diff"];
              group = "MergeTool";
              desc = "Open DiffView when vim.difftool is activated";
              callback = lib.generators.mkLuaInline ''
                function()
                  if not vim.o.diff then return end
                  if vim.g._diffview_auto_opening then return end

                  local bufname = vim.api.nvim_buf_get_name(0)
                  if bufname:find("Claude Code", 1, true) then return end

                  -- Already inside a diffview tab: don't open another.
                  local ok, lib = pcall(require, "diffview.lib")
                  if ok and lib.get_current_view() then return end

                  vim.g._diffview_auto_opening = true
                  vim.schedule(function()
                    pcall(function()
                      require("diffview").open()
                    end)
                    vim.g._diffview_auto_opening = false
                  end)
                end
              '';
            }
          ];
        };
      };
    };
  };
}
