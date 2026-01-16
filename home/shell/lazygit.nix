_: {
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
              command = ''
                opencode run --model "github-copilot/gemini-3-flash-preview" "Generate a conventional commit
                                    title from the following git diff: $(git diff HEAD). ONLY RETRUN THE COMMIT TITLE
                                    AND NOTHING ELSE and prefix it with COMMIT:" | grep "COMMIT:" | sed 's/COMMIT: //g'
              '';
              key = "title";
              type = "menuFromCommand";
              title = "AI Commit Message:";
              # filter = "(?P<title>.+)";
              # labelFormat = "{{.title}}";
              loadingText = "Generating commit messages...";
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
          prompt = {
            type = "menuFromCommand";
            title = "Which PR do you want to chekout?";
            key = "PullRequestNumber";
            command = ''
              gh pr list --json number,title,headRefName,updatedAt --temaplte '{{`{{range .}}{{printf "#%v: %s - %s (%s)" .number .title .headRefName (timeago .updatedAt)}}{{end}}`}}'
            '';
            filter = "#(?P<number>[0-9]+): (?P<title>.+) - (?P<ref_name>[^ ]+).*";
            valueFormat = "{{.number}}";
            labelFormat = ''
              {{"#" | black | bold}}{{.number | white | bold}} {{.title | yellow | bold}}{{" [" | black | bold}}{{.ref_name | green}}{{"]" | black | bold}}
            '';
          };
        }
      ];
    };
  };

  programs.lazydocker = {
    enable = true;
  };
}
