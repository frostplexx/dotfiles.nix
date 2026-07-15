_: {
  flake.homeManagerModules.vscode = {
    pkgs,
    defaults,
    ...
  }: {
    programs.vscodium = {
      enable = true;
      profiles.default = {
        enableMcpIntegration = false;
        extensions = with pkgs; [
          # Latex
          vscode-extensions.davidlday.languagetool-linter
          vscode-extensions.valentjn.vscode-ltex
          vscode-extensions.james-yu.latex-workshop
          vscode-extensions.tecosaur.latex-utilities
          vscode-extensions.dendron.dendron-paste-image
          # Jupyter
          vscode-extensions.ms-toolsai.jupyter
          vscode-extensions.ms-python.python
          vscode-extensions.ms-python.pylint
          vscode-extensions.ms-python.debugpy

          # Other
          # vscode-extensions.github.copilot-chat
          vscode-extensions.ms-vscode-remote.remote-ssh
          vscode-extensions.jgclark.vscode-todo-highlight
          vscode-extensions.vscodevim.vim
          vscode-extensions.mvllow.rose-pine
          vscode-extensions.alefragnani.project-manager
          vscode-extensions.catppuccin.catppuccin-vsc
          vscode-extensions.catppuccin.catppuccin-vsc-icons
          vscode-extensions.mkhl.direnv
          vscode-extensions.leonardssh.vscord
          vscode-extensions.editorconfig.editorconfig
          vscode-extensions.bbenoist.nix
        ];

        userSettings = {
          "editor.inlineSuggest.enabled" = true;
          "editor.accessibilitySupport" = "off";
          "editor.minimap.enabled" = false;
          "diffEditor.hideUnchangedRegions.enabled" = true;
          "workbench.startupEditor" = "none";
          "security.workspace.trust.untrustedFiles" = "open";
          "editor.fontLigatures" = true;
          # "catppuccin.accentColor" = "blue";
          "github.copilot.chat.agentDebugLog.enabled" = false;
          "workbench.colorTheme" =
            {
              "catppuccin" = "Catppuccin Mocha";
              "rose-pine" = "Rose Pine";
            }
              .${
              defaults.settings.theme
            };
          "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
          "workbench.colorCustomizations" = {};
          "git.enableSmartCommit" = true;
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "editor.fontFamily" = "Maple Mono NF";
          "github.copilot.enable" = {
            "*" = true;
            plaintext = false;
            markdown = false;
            scminput = false;
          };
          "github.copilot.nextEditSuggestions.enabled" = true;
          "[bibtex]" = {
            "editor.defaultFormatter" = "James-Yu.latex-workshop";
            "editor.formatOnSave" = true;
            "editor.tabSize" = 2;
            "editor.wordWrap" = "off";
          };
          "[latex]" = {
            "editor.defaultFormatter" = "James-Yu.latex-workshop";
            "editor.formatOnSave" = true;
            "editor.formatOnPaste" = false;
            "editor.wordWrap" = "on";
            "editor.wordWrapColumn" = 100;
            "editor.rulers" = [100 120];
            "editor.autoClosingBrackets" = "always";
            "editor.autoClosingQuotes" = "always";
            "editor.snippetSuggestions" = "top";
            "editor.lineHeight" = 24;
            "editor.letterSpacing" = 0.5;
            "editor.bracketPairColorization.enabled" = true;
            "editor.guides.bracketPairs" = true;
            "editor.guides.highlightActiveBracketPair" = true;
            "editor.smoothScrolling" = true;
            "editor.cursorBlinking" = "phase";
            "editor.cursorSmoothCaretAnimation" = "on";
            "editor.renderLineHighlight" = "all";
            "editor.occurrencesHighlight" = "multiFile";
          };
          "editor.stickyScroll.enabled" = false;
          "window.commandCenter" = false;
          "editor.overviewRulerBorder" = false;
          "editor.hideCursorInOverviewRuler" = true;
          "workbench.editor.decorations.colors" = false;
          "workbench.editor.decorations.badges" = false;
          "breadcrumbs.icons" = false;
          "outline.icons" = false;
          "outline.problems.enabled" = false;
          "outline.problems.badges" = false;
          "outline.problems.colors" = false;
          "explorer.decorations.colors" = false;
          "explorer.decorations.badges" = false;
          "explorer.compactFolders" = false;
          "explorer.autoReveal" = false;
          "explorer.openEditors.visible" = 0;
          "vim.smartRelativeLine" = true;
          "editor.lineNumbers" = "relative";
          "workbench.activityBar.location" = "top";
          "workbench.layoutControl.enabled" = false;
          "git.branchSortOrder" = "committerdate";
          "git.branchProtection" = ["main" "master"];
          "git.showHistoryGraph" = true;
          "git.mergeEditor" = true;
          "git.showInlineOpenFileAction" = true;
          "scm.defaultViewMode" = "tree";
          "scm.alwaysShowActions" = true;
          "scm.diffDecorations" = "all";
          "scm.showHistoryGraph" = true;
          "workbench.iconTheme" = "catppuccin-mocha";

          # ── LaTeX Workshop ──────────────────────────────────────────
          "latex-workshop.latex.autoBuild.run" = "onSave";
          "latex-workshop.latex.autoClean.run" = "onBuilt";
          "latex-workshop.latex.clean.fileTypes" = [
            "*.aux"
            "*.bbl"
            "*.blg"
            "*.fdb_latexmk"
            "*.fls"
            "*.idx"
            "*.ilg"
            "*.ind"
            "*.lof"
            "*.log"
            "*.lot"
            "*.out"
            "*.toc"
            "*.acn"
            "*.acr"
            "*.alg"
            "*.glg"
            "*.glo"
            "*.gls"
            "*.ist"
            "*.lol"
            "*.run.xml"
            "*.syg"
            "*.syi"
            "*.synctex.gz"
            "*.bcf"
          ];
          "latex-workshop.latex.recipe.default" = "latexmk (lualatex)";
          "latex-workshop.latex.recipes" = [
            {
              name = "latexmk (lualatex)";
              tools = ["lualatexmk"];
            }
            {
              name = "latexmk (pdflatex)";
              tools = ["pdflatexmk"];
            }
            {
              name = "latexmk (xelatex)";
              tools = ["xelatexmk"];
            }
            {
              name = "latexmk (lualatex) -> biber -> latexmk (lualatex) x 2";
              tools = ["lualatexmk" "biber" "lualatexmk" "lualatexmk"];
            }
            {
              name = "latexmk (pdflatex) -> bibtex -> latexmk (pdflatex) x 2";
              tools = ["pdflatexmk" "bibtex" "pdflatexmk" "pdflatexmk"];
            }
          ];
          "latex-workshop.latex.tools" = [
            {
              name = "lualatexmk";
              command = "latexmk";
              args = ["-lualatex" "-file-line-error" "-halt-on-error" "-interaction=nonstopmode" "-outdir=%OUTDIR%" "%DOC%"];
            }
            {
              name = "pdflatexmk";
              command = "latexmk";
              args = ["-pdf" "-file-line-error" "-halt-on-error" "-interaction=nonstopmode" "-outdir=%OUTDIR%" "%DOC%"];
            }
            {
              name = "xelatexmk";
              command = "latexmk";
              args = ["-xelatex" "-file-line-error" "-halt-on-error" "-interaction=nonstopmode" "-outdir=%OUTDIR%" "%DOC%"];
            }
            {
              name = "biber";
              command = "biber";
              args = ["%DOC%"];
            }
            {
              name = "bibtex";
              command = "bibtex";
              args = ["%DOC%"];
            }
          ];
          "latex-workshop.linting.chktex.enabled" = true;
          "latex-workshop.intellisense.citation.type" = "all";
          "latex-workshop.bibtex-format.tab" = true;
          "latex-workshop.bibtex-format.brackets" = "parentheses";
          "latex-workshop.bibtex-format.surround" = "braces";
          "latex-workshop.bibtex-format.sortby" = "key";
          "latex-workshop.intellisense.package.enabled" = true;
          "latex-workshop.intellisense.citation.enabled" = true;
          "latex-workshop.intellisense.label.enabled" = true;
          "latex-workshop.intellisense.bibtexJSON.enabled" = true;
          "latex-workshop.hover.preview.enabled" = true;
          "latex-workshop.hover.preview.cite.enabled" = true;
          "latex-workshop.hover.ref.enabled" = true;
          "latex-workshop.hover.preview.numbering.enabled" = true;
          "latex-workshop.synctex.afterBuild.enabled" = true;
          "latex-workshop.view.pdf.viewer" = "tab";
          "latex-workshop.view.pdf.zoom" = "page-width";
          "latex-workshop.view.pdf.internal.synctex.keybinding" = "ctrl-click";
          "latex-workshop.message.badbox.show" = true;
          "latex-workshop.message.update.show" = true;
          "latex-workshop.formatting.latex" = "latexindent";
          "editor.wordWrapColumn" = 120;
          "vim.textwidth" = 100;
          "vim.enableNeovim" = true;
          "vim.highlightedyank.enable" = true;
          "vim.highlightedyank.color" = "rgba(205, 214, 244, 0.2)";
          "vim.searchHighlightColor" = "rgba(205, 214, 244, 0.2)";
          "vim.searchMatchColor" = "rgba(137, 180, 250,0.2)";
          "vim.showMarksInGutter" = true;
          "vim.useSystemClipboard" = true;
          "vim.normalModeKeyBindings" = [
            {
              before = [
                "<leader>"
                "e"
              ];
              commands = [
                "workbench.explorer.fileView.focus"
              ];
            }
            {
              before = [
                "<leader>"
                "g"
                "g"
              ];
              commands = [
                "workbench.scm.focus"
              ];
            }
            {
              before = [
                "<leader>"
                "p"
                "s"
              ];
              commands = [
                "fuzzySearch.activeTextEditor"
              ];
            }
            {
              before = [
                "<leader>"
                "l"
                "f"
              ];
              commands = [
                "editor.action.formatDocument"
              ];
            }
          ];
          "vim.visualModeKeyBindingsNonRecursive" = [
            {
              before = [
                "<leader>"
                "a"
                "e"
              ];
              commands = [
                "github.copilot.chat.fix"
              ];
            }
          ];
          "vim.leader" = " ";
          "vim.commandLineModeKeyBindings" = [];
          "projectManager.git.baseFolders" = [
            "~/Projects"
          ];
          "extensions.ignoreRecommendations" = true;
          # ── LTeX – Grammar & Spell Check ────────────────────────────
          "ltex.enabled" = true;
          "ltex.language" = "en-US";
          "ltex.additionalRules.motherTongue" = "en-US";
          "ltex.additionalRules.languageModel" = "en";
          "ltex.additionalRules.enablePickyRules" = true;
          "ltex.completionEnabled" = true;
          "ltex.diagnosticSeverity" = "warning";
          "ltex.sentenceCacheSize" = 2000;
          "ltex.checkFrequency" = "onEdit";
          "ltex.statusBarItem" = true;
          "ltex.markShortRegions" = false;
          "search.exclude" = {
            "**/.direnv" = true;
          };
          "files.exclude" = {
            "**/*.{aux,bbl,blg,fdb_latexmk,fls,idx,ilg,ind,lof,log,lot,out,toc,acn,acr,alg,glg,glo,gls,ist,lol,run.xml,syg,syi,bcf,synctex.gz}" = true;
          };
          "git.blame.editorDecoration.disableHover" = true;
          "git.blame.editorDecoration.enabled" = true;
        };
      };
    };
  };
}
