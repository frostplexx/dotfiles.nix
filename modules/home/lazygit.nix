_: {
  flake.homeManagerModules.lazygit = _: {
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
          # Return straight to lazygit when a terminal command (e.g. pi) exits.
          promptToReturnFromSubprocess = false;
          theme = {
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
        };
        customCommands = [
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
            key = "<c-a>";
            description = "Split worktree into focused commits with pi";
            context = "files";
            output = "terminal";
            prompts = [
              {
                type = "confirm";
                title = "Split worktree with pi";
                body = "Hand the whole worktree to pi so it can stage and commit the changes as focused, self-contained commits?";
              }
            ];
            # lazygit runs this through fish, which has no heredocs; a single-quoted
            # string is fine as long as the prompt contains no ' or \.
            command = ''
              pi --no-session 'This git worktree contains a large set of uncommitted changes, potentially spanning many unrelated concerns.
              Your job is to turn it into a series of small, focused, self-contained commits.

              Steps:
              1. Run `git status` and `git diff` (and `git diff --cached`) to understand every change, including untracked files.
              2. Group hunks by logical concern (one feature, fix, refactor, or chore per group). Do not group by file: a single file may belong to several commits.
              3. For each group, in a sensible order (dependencies first): stage exactly those hunks (`git add -p` / `git apply --cached` with patches), verify with `git diff --cached`, then commit with a conventional-commit message (`type(scope): summary`) plus a short body explaining why.
              4. Never modify file contents, never use `git add -A` or `git commit -a`, never amend or rewrite existing commits, and never push.
              5. Finish when `git status` is clean, then print `git log --oneline` for the commits you created.'
            '';
          }
        ];
      };
    };
  };
}
