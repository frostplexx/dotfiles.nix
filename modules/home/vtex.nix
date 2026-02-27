_: {
  flake.modules.homeManager.vtex = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    # ── Shared base configuration (mirrors neovim.nix settings) ──────────
    # We import the same helper files as the main neovim config so the
    # editing experience is identical, then layer latex extras on top.
    languagesConfig = import ./neovim/_languages.nix {inherit pkgs;};
    keymapsConfig = import ./neovim/_keymap.nix {};
    optionsConfig = import ./neovim/_options.nix {};

    transparent_terminal = false;

    # ── Build the vtex neovim derivation ──────────────────────────────────
    vtexNeovim =
      (inputs.nvf.lib.nvim.neovimConfiguration {
        inherit pkgs;
        modules = [
          # Inject both the basic latex module (for vim.languages.latex)
          # and the full latex module (for vim.languages.latexFull)
          ./neovim/_latex.nix
          ./neovim/_latex-full.nix

          (_: {
            vim = {
              viAlias = false;
              vimAlias = false;
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
                    root_markers = [".git" "src"];
                  };
                };
              };

              debugger.nvim-dap = {
                enable = true;
                ui.enable = true;
              };

              inherit (optionsConfig) options;
              inherit (keymapsConfig) keymaps;

              # Merge base languages config with latex extras
              languages =
                languagesConfig.languages
                // {
                  latex.enable = true;
                  latexFull.enable = true;
                };

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
                starter.enable = true;
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
                  setupOpts.view = {
                    style = "sign";
                    signs = {
                      add = "┃";
                      change = "┃";
                      delete = "┃";
                    };
                  };
                };
                move = {
                  enable = true;
                  setupOpts.mappings = {
                    left = "<S-h>";
                    right = "<S-l>";
                    down = "<S-j>";
                    up = "<S-k>";
                  };
                };
                hipatterns = {
                  enable = true;
                  setupOpts.highlighters = {
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
                align.enable = true;
              };

              luaConfigRC.my-config = ''
                vim.keymap.set(
                  "v",
                  "<leader>s",
                  'y:%s/<C-r>"//gc<Left><Left><Left>',
                  { desc = "Search and replace selected text across file" }
                )
              '';

              augroups = [{name = "MergeTool";}];

              autocmds = [
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
          })
        ];
      }).neovim;

    # ── Expose as `vtex` ──────────────────────────────────────────────────
    vtexBin = pkgs.writeShellScriptBin "vtex" ''
      exec ${vtexNeovim}/bin/nvim "$@"
    '';
  in {
    home.packages = [vtexBin];

    # Sioyek config: yellow synctex highlight instead of the default magenta
    programs.sioyek = {
      enable = true;
      config = {
        synctex_highlight_color = "1.0 0.9 0.0";
      };
    };
  };
}
