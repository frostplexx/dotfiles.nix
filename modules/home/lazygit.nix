_: {
  flake.modules.homeManager.lazygit = _: {
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
                # command = ''/bin/bash -c "git diff HEAD | opencode run --model 'github-copilot/github-copilot/gpt-4.1' 'Generate a conventional commit title from the following git diff:' {}" '';
                key = "title";
                type = "input";
                suggestions.command = ''/bin/bash -c "git diff HEAD | opencode run --model 'github-copilot/gpt-4.1' 'Generate a set of conventional commit titles from the following git diff, separated by new lines! Do not return anything except the commits:' {}" '';
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
