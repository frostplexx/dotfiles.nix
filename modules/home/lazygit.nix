_: {
  flake.homeManagerModules.lazygit = {defaults, ...}: {
    programs.lazygit = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        notARepository = "quit";
        git.overrideGpg = true;
        os.editPreset = "nvim";
        gui = {
          border = "rounded";
          nerdFontsVersion = 3;
          theme =
            {
              "catppuccin" = {
                activeBorderColor = ["#a6e3a1" "bold"];
                inactiveBorderColor = ["#6c7086"];
                searchingActiveBorderColor = ["#f5c2e7" "bold"];
                optionsTextColor = ["#89b4fa"];
                selectedLineBgColor = ["#585b70"];
                inactiveViewSelectedLineBgColor = ["#45475a" "bold"];
                cherryPickedCommitFgColor = ["#1e1e2e"];
                cherryPickedCommitBgColor = ["#f5c2e7"];
                markedBaseCommitFgColor = ["#89b4fa"];
                markedBaseCommitBgColor = ["#fab387"];
                unstagedChangesColor = ["#f38ba8"];
                defaultFgColor = ["#cdd6f4"];
              };
              "rose-pine" = {
                activeBorderColor = ["#31748f" "bold"];
                inactiveBorderColor = ["#6e6a86"];
                searchingActiveBorderColor = ["#ebbcba" "bold"];
                optionsTextColor = ["#9ccfd8"];
                selectedLineBgColor = ["#31748f"];
                inactiveViewSelectedLineBgColor = ["#26233a" "bold"];
                cherryPickedCommitFgColor = ["#1f1d2e"];
                cherryPickedCommitBgColor = ["#ebbcba"];
                markedBaseCommitFgColor = ["#9ccfd8"];
                markedBaseCommitBgColor = ["#f6c177"];
                unstagedChangesColor = ["#eb6f92"];
                defaultFgColor = ["#e0def4"];
              };
            }
            .${
              defaults.settings.theme
            };
        };
        customCommands = [
          # AI Commit using opencode
          {
            key = "C";
            command = "git commit -m '{{ .Form.title }}'";
            context = "files";
            loadingText = "Generating commit messages...";
            prompts = [
              {
                key = "title";
                type = "input";
                suggestions.command = ''/bin/bash -c "fm respond --model pcc 'Generate a set of conventional commit titles from the following git diff, separated by new lines! Do not return anything except the commits: $(git diff HEAD)'" '';
                title = "Commit Message:";
              }
            ];
          }
          {
            key = "p";
            prompts = [
              {
                type = "input";
                title = "PR id:";
              }
            ];
            command = "gh pr checkout {{index .PromptResponses 0}}";
            context = "localBranches";
            loadingText = "Checking out PR...";
          }
          {
            key = "v";
            context = "localBranches";
            loadingText = "Checking out GitHub Pull Request...";
            command = "gh pr checkout {{.Form.PullRequestNumber}}";
            prompts = [
              {
                type = "menuFromCommand";
                title = "Which PR do you want to chekout?";
                key = "PullRequestNumber";
                command = ''
                  gh pr list --json number,title,headRefName,updatedAt --template '{{`{{range .}}{{printf "#%v: %s - %s (%s)" .number .title .headRefName (timeago .updatedAt)}}{{end}}`}}'
                '';
                filter = "#(?P<number>[0-9]+): (?P<title>.+) - (?P<ref_name>[^ ]+).*";
                valueFormat = "{{.number}}";
                labelFormat = ''
                  {{"#" | black | bold}}{{.number | white | bold}} {{.title | yellow | bold}}{{" [" | black | bold}}{{.ref_name | green}}{{"]" | black | bold}}
                '';
              }
            ];
          }
        ];
      };
    };
  };
}
