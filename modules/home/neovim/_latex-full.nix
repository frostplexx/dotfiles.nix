# Comprehensive LaTeX editing module for nvf
# Provides: vimtex, texlab LSP, ltex-ls (LanguageTool), luasnip snippets,
#           blink-cmp-latex completions, Skim PDF viewer, bibtex tooling
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.dag) entryAnywhere entryAfter;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;

  cfg = config.vim.languages.latexFull;

  sioyekPath = lib.getExe pkgs.sioyek;
in {
  options.vim.languages.latexFull = {
    enable = mkEnableOption "full LaTeX editing environment";

    treesitter = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableTreesitter;
        description = "Enable LaTeX treesitter support";
      };
      package = mkGrammarOption pkgs "latex";
    };

    texlab.enable = mkEnableOption "texlab LSP" // {default = true;};

    ltex.enable = mkEnableOption "ltex-ls (LanguageTool) LSP" // {default = true;};
  };

  config = mkIf cfg.enable (mkMerge [
    # ── Treesitter ─────────────────────────────────────────────────────────
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    # ── Core config: runtime packages + vimtex + snippets + completions ───
    {
      vim = {
        # texlive and bibtool are intentionally omitted — the project flake
        # is expected to provide a LaTeX distribution with all required packages.
        extraPackages = with pkgs; [
          texlab
          ltex-ls
          sioyek
        ];

        startPlugins = [
          pkgs.vimPlugins.vimtex
          pkgs.vimPlugins."blink-cmp-latex"
          # luasnip-latex-snippets-nvim disabled for now — conflicts with nvf's
          # managed luasnip instance at build time. Re-enable once upstream fixes
          # the nixpkgs dependency propagation or nvf exposes a hook for it.
          # (pkgs.vimPlugins.luasnip-latex-snippets-nvim.overrideAttrs (_: {
          #   dependencies = [];
          #   nvimRequireCheck = [];
          # }))
        ];

        globals = {
          # VimTeX: use Sioyek for forward search
          vimtex_view_method = "sioyek";
          vimtex_compiler_method = "latexmk";
          vimtex_compiler_progname = "nvim";
          vimtex_compiler_latexmk = {
            options = [
              "-pdf"
              "-shell-escape"
              "-verbose"
              "-file-line-error"
              "-synctex=1"
              "-interaction=nonstopmode"
            ];
          };
          # Disable vimtex defaults we replace with our own
          vimtex_mappings_enabled = 0;
          vimtex_fold_enabled = 0;
          vimtex_imaps_enabled = 0;
          vimtex_syntax_conceal_disable = 0;
          vimtex_compiler_latexmk_engines._ = "-lualatex";
          # Only open the quickfix list automatically when there are errors, not warnings
          vimtex_quickfix_open_on_warning = 0;
        };

        pluginRC = {
          vimtex-setup = entryAnywhere ''
            -- luasnip-latex-snippets disabled for now (see startPlugins comment)
            -- vim.api.nvim_create_autocmd("FileType", {
            --   pattern = { "tex", "plaintex" },
            --   callback = function()
            --     require("luasnip-latex-snippets").setup({ use_treesitter = true })
            --     require("luasnip").config.setup({ enable_autosnippets = true })
            --   end,
            -- })
          '';

          vimtex-help = entryAnywhere ''
            vim.api.nvim_create_user_command("LatexHelp", function()
              local lines = {
                "  vtex — LaTeX keybinds                                        ",
                "                                                                ",
                "  ── Compile & View ─────────────────────────────────────────  ",
                "  <leader>lb   Toggle continuous compile (latexmk)             ",
                "  <leader>lv   Forward search / open PDF in Sioyek             ",
                "  <leader>le   Show errors (quickfix list)                     ",
                "  <leader>lo   Show raw compiler output log                    ",
                "  <leader>ls   Stop compiler                                   ",
                "  <leader>lS   Show compiler status                            ",
                "  <leader>lc   Clean auxiliary files                           ",
                "  <leader>lC   Clean ALL output files (incl. PDF)              ",
                "                                                                ",
                "  ── Navigation ─────────────────────────────────────────────  ",
                "  <leader>lt   Open table of contents                          ",
                "  <leader>lT   Toggle table of contents                        ",
                "  ]]  /  [[    Jump to next / previous section end/start       ",
                "  ][  /  []    Jump to next / previous section start/end       ",
                "                                                                ",
                "  ── Environments & Commands ────────────────────────────────  ",
                "  dse          Delete surrounding environment                  ",
                "  cse          Change surrounding environment                  ",
                "  dsc          Delete surrounding command                      ",
                "  csc          Change surrounding command                      ",
                "  <leader>li   Toggle starred environment (e.g. equation*)     ",
                "  <leader>lm   Change environment                              ",
                "  <leader>lw   Change command                                  ",
                "                                                                ",
                "  ── Text Objects (normal / visual / operator) ──────────────  ",
                "  ic / ac      inner / outer command                           ",
                "  ie / ae      inner / outer environment                       ",
                "  i$ / a$      inner / outer inline math                       ",
                "                                                                ",
                "  ── LSP (texlab + ltex-ls) ─────────────────────────────────  ",
                "  <leader>la   Code action (add word to dict, disable rule…)   ",
                "  K            Hover documentation                             ",
                "  <leader>gd   Go to definition                                ",
                "  <leader>ca   Code action                                     ",
                "  <leader>cr   Rename symbol                                   ",
                "  ]d  /  [d    Next / previous diagnostic                      ",
                "  <leader>cd   Open diagnostic float                           ",
                "                                                                ",
                "  ── Sioyek inverse search (one-time setup) ─────────────────  ",
                "  In sioyek_config.txt set:                                    ",
                "    inverse_search_command nvim --headless -c               \\ ",
                "      \"VimtexInverseSearch %2 '%1'\"                            ",
              }

              local buf = vim.api.nvim_create_buf(false, true)
              vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
              vim.bo[buf].modifiable = false
              vim.bo[buf].filetype = "help"

              local width = 66
              local height = #lines
              local win = vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                width = width,
                height = height,
                col = math.floor((vim.o.columns - width) / 2),
                row = math.floor((vim.o.lines - height) / 2),
                style = "minimal",
                border = "rounded",
                title = " LaTeX Help ",
                title_pos = "center",
              })
              vim.wo[win].cursorline = true

              -- close with q / Esc
              for _, key in ipairs({ "q", "<Esc>" }) do
                vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, nowait = true })
              end
            end, { desc = "Show vtex LaTeX keybind reference" })
          '';

          vimtex-keymaps = entryAfter ["vimtex-setup"] ''
            -- Refocus our terminal after every forward search (manual or auto).
            -- VimtexEventView fires after vimtex opens/updates the PDF viewer.
            local nvim_pid = tostring(vim.fn.getpid())
            vim.api.nvim_create_autocmd("User", {
              pattern = "VimtexEventView",
              callback = function()
                vim.defer_fn(function()
                  vim.fn.system(
                    "osascript -e 'tell application \"System Events\" to set frontmost of first process whose unix id is "
                    .. nvim_pid .. " to true' 2>/dev/null"
                  )
                end, 200)
              end,
            })

            local function tex_map(lhs, rhs, desc, mode)
              mode = mode or "n"
              vim.api.nvim_create_autocmd("FileType", {
                pattern = { "tex", "plaintex", "bib" },
                callback = function(ev)
                  vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
                end,
              })
            end

            -- ── Compile & View ──────────────────────────────────────────────
            tex_map("<leader>lb", "<cmd>VimtexCompile<cr>",       "LaTeX: Toggle continuous compile")
            tex_map("<leader>lv", "<cmd>VimtexView<cr>",          "LaTeX: Forward search / open PDF")
            tex_map("<leader>lc", "<cmd>VimtexClean<cr>",         "LaTeX: Clean aux files")
                        tex_map("<leader>lC", "<cmd>VimtexClean!<cr>",        "LaTeX: Clean ALL output files")
                        tex_map("<leader>le", "<cmd>VimtexErrors<cr>",        "LaTeX: Show errors (quickfix)")
                        tex_map("<leader>ls", "<cmd>VimtexStop<cr>",          "LaTeX: Stop compiler")
                        tex_map("<leader>lS", "<cmd>VimtexStatus<cr>",        "LaTeX: Show compiler status")
                        tex_map("<leader>lo", "<cmd>VimtexCompileOutput<cr>", "LaTeX: Show compiler output log")

                        -- ── Navigation ──────────────────────────────────────────────────
                        tex_map("<leader>lt", "<cmd>VimtexTocOpen<cr>",   "LaTeX: Open table of contents")
                        tex_map("<leader>lT", "<cmd>VimtexTocToggle<cr>", "LaTeX: Toggle table of contents")
                        tex_map("]]", "<plug>(vimtex-]])", "LaTeX: Next section end")
                        tex_map("[[", "<plug>(vimtex-[[)", "LaTeX: Previous section start")
                        tex_map("][", "<plug>(vimtex-][)", "LaTeX: Next section start")
                        tex_map("[]", "<plug>(vimtex-[])", "LaTeX: Previous section end")

                        -- ── Text objects ─────────────────────────────────────────────────
                        for _, mode in ipairs({ "o", "v" }) do
                          tex_map("ic", "<plug>(vimtex-ic)", "LaTeX: inner command",     mode)
                          tex_map("ac", "<plug>(vimtex-ac)", "LaTeX: outer command",     mode)
                          tex_map("ie", "<plug>(vimtex-ie)", "LaTeX: inner environment", mode)
                          tex_map("ae", "<plug>(vimtex-ae)", "LaTeX: outer environment", mode)
                          tex_map("i$", "<plug>(vimtex-i$)", "LaTeX: inner math",        mode)
                          tex_map("a$", "<plug>(vimtex-a$)", "LaTeX: outer math",        mode)
                        end

                        -- ── Environment / command helpers ─────────────────────────────────
                        tex_map("<leader>li", "<plug>(vimtex-env-toggle-star)", "LaTeX: Toggle starred env")
                        tex_map("<leader>lm", "<plug>(vimtex-env-change)",      "LaTeX: Change environment")
                        tex_map("<leader>lw", "<plug>(vimtex-cmd-change)",      "LaTeX: Change command")
                        tex_map("dse",        "<plug>(vimtex-env-delete)",      "LaTeX: Delete surrounding env")
                        tex_map("dsc",        "<plug>(vimtex-cmd-delete)",      "LaTeX: Delete surrounding cmd")
                        tex_map("cse",        "<plug>(vimtex-env-change)",      "LaTeX: Change surrounding env")
                        tex_map("csc",        "<plug>(vimtex-cmd-change)",      "LaTeX: Change surrounding cmd")

            -- ── LanguageTool (ltex) ──────────────────────────────────────────
            tex_map("<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",
              "LaTeX: LSP code action (add word / disable rule)")

            -- ── Help ─────────────────────────────────────────────────────────
            tex_map("<leader>l?", "<cmd>LatexHelp<cr>", "LaTeX: Show keybind reference")
          '';
        };

        augroups = [{name = "LatexEditing";}];

        autocmds = [
          {
            event = ["FileType"];
            pattern = ["tex" "plaintex" "bib"];
            group = "LatexEditing";
            desc = "LaTeX buffer-local settings";
            callback = lib.generators.mkLuaInline ''
              function()
                vim.opt_local.wrap = true
                vim.opt_local.linebreak = true
                vim.opt_local.spell = true
                vim.opt_local.spelllang = "en_us"
                vim.opt_local.conceallevel = 2
                vim.opt_local.textwidth = 0
              end
            '';
          }
        ];
      };
    }

    # ── texlab LSP ─────────────────────────────────────────────────────────
    (mkIf cfg.texlab.enable {
      vim.lsp.servers.texlab = {
        cmd = [(getExe pkgs.texlab)];
        filetypes = ["tex" "bib" "plaintex"];
        root_markers = [
          ".git"
          ".latexmkrc"
          "latexmkrc"
          ".texlabroot"
          "texlabroot"
          "Tectonic.toml"
        ];
        settings.texlab = {
          build = {
            executable = "latexmk";
            args = ["-pdf" "-interaction=nonstopmode" "-synctex=1" "%f"];
            onSave = true;
            forwardSearchAfter = true;
          };
          forwardSearch = {
            executable = sioyekPath;
            args = ["--reuse-window" "--forward-search-file" "%f" "--forward-search-line" "%l" "%p"];
          };
          chktex = {
            onOpenAndSave = true;
            onEdit = false;
          };
        };
      };
    })

    # ── ltex-ls (LanguageTool grammar/spell) ───────────────────────────────
    (mkIf cfg.ltex.enable {
      vim = {
        lsp.servers.ltex = {
          cmd = [(getExe pkgs.ltex-ls)];
          filetypes = ["tex" "bib" "plaintex" "markdown" "rst"];
          root_markers = [".git" ".ltex"];
          settings.ltex = {
            language = "en-US";
            enabled = ["latex" "markdown"];
            additionalRules = {
              enablePickyRules = true;
              motherTongue = "";
            };
          };
        };

        startPlugins = [pkgs.vimPlugins."ltex_extra-nvim"];

        # ltex_extra persists user dictionary / false-positive rules across sessions.
        # Must be set up inside on_attach so the ltex client is guaranteed to exist.
        pluginRC.ltex-extra = entryAfter ["lsp-setup"] ''
          vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
              local client = vim.lsp.get_client_by_id(ev.data.client_id)
              if client and client.name == "ltex" then
                require("ltex_extra").setup({
                  load_langs = { "en-US" },
                  init_check = true,
                  path = vim.fn.stdpath("data") .. "/ltex",
                  log_level = "none",
                })
              end
            end,
          })
        '';
      };
    })
  ]);
}
