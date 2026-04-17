_: {
  flake.homeManagerModules.vscode = {pkgs, ...}: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default = {
        enableMcpIntegration = true;
        extensions = with pkgs; [
          # Latex
          vscode-extensions.davidlday.languagetool-linter
          vscode-extensions.valentjn.vscode-ltex
          vscode-extensions.james-yu.latex-workshop
          vscode-extensions.tecosaur.latex-utilities

          # Jupyter
          vscode-extensions.ms-toolsai.jupyter
          vscode-extensions.ms-python.python
          vscode-extensions.ms-python.pylint
          vscode-extensions.ms-python.debugpy

          # Other
          # vscode-extensions.github.copilot-chat
          vscode-extensions.jgclark.vscode-todo-highlight
          vscode-extensions.vscodevim.vim
          vscode-extensions.eamodio.gitlens
          vscode-extensions.alefragnani.project-manager
          vscode-extensions.catppuccin.catppuccin-vsc
          vscode-extensions.catppuccin.catppuccin-vsc-icons
          vscode-extensions.mkhl.direnv
          vscode-extensions.leonardssh.vscord
          vscode-extensions.editorconfig.editorconfig
          vscode-extensions.tomoki1207.pdf
        ];

        userSettings = {
          "editor.inlineSuggest.enabled" = true;
          "ltex.additionalRules.motherTongue" = "en-US";
          "editor.minimap.enabled" = false;
          "diffEditor.hideUnchangedRegions.enabled" = true;
          "workbench.startupEditor" = "none";
          "security.workspace.trust.untrustedFiles" = "open";
          "editor.fontLigatures" = true;
          # "catppuccin.accentColor" = "blue";
          "github.copilot.chat.agentDebugLog.enabled" = false;
          "workbench.colorTheme" = "Catppuccin Mocha";
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
          "[latex]" = {
            "editor.defaultFormatter" = "James-Yu.latex-workshop";
          };
          "editor.stickyScroll.enabled" = false;
          "window.commandCenter" = false;
          "vim.smartRelativeLine" = true;
          "editor.lineNumbers" = "relative";
          "workbench.activityBar.location" = "top";
          "workbench.layoutControl.enabled" = false;
          "workbench.iconTheme" = "catppuccin-mocha";
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
            "~/Developer"
          ];
          "extensions.ignoreRecommendations" = true;
          "ltex.additionalRules.languageModel" = "en";
          "ltex.additionalRules.enablePickyRules" = true;
          "ltex.completionEnabled" = true;
          "ltex.diagnosticSeverity" = "warning";
          "search.exclude" = {
            "**/.direnv" = true;
          };
          "git.blame.editorDecoration.disableHover" = true;
          "git.blame.editorDecoration.enabled" = true;
          "latex-workshop.latex.recipe.default" = "latexmk (lualatex)";
        };
      };
    };
  };
}
