_: {
  flake.homeManagerModules.git = {
    pkgs,
    lib,
    defaults,
    ...
  }: {
    home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -f ~/.gitconfig
    '';

    programs = {
      lazygit = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          notARepository = "quit";
          git.overrideGpg = true;
          os.editPreset = "nvim";
          gui = {
            border = "rounded";
            nerdFontsVersion = 3;
            promptToReturnFromSubprocess = false;
            theme = {
              activeBorderColor = [
                "#a6e3a1"
                "bold"
              ];
              inactiveBorderColor = ["#6c7086"];
              searchingActiveBorderColor = [
                "#f5c2e7"
                "bold"
              ];
              optionsTextColor = ["#89b4fa"];
              selectedLineBgColor = ["#585b70"];
              inactiveViewSelectedLineBgColor = [
                "#45475a"
                "bold"
              ];
              cherryPickedCommitFgColor = ["#1e1e2e"];
              cherryPickedCommitBgColor = ["#f5c2e7"];
              markedBaseCommitFgColor = ["#89b4fa"];
              markedBaseCommitBgColor = ["#fab387"];
              unstagedChangesColor = ["#f38ba8"];
              defaultFgColor = ["#cdd6f4"];
            };
          };
        };
      };

      git = {
        enable = true;
        lfs.enable = true;
        ignores = [
          ".DS_Store"
          ".idea"
          ".vscode"
          "node_modules"
          "vendor"
          ".direnv"
        ];
        signing = {
          signByDefault = true;
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
          format = "ssh";
          signer =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else "${pkgs._1password-gui}/bin/op-ssh-sign";
        };
        settings = {
          user = {
            inherit (defaults.personalInfo) name;
            inherit (defaults.personalInfo) email;
            inherit (defaults.personalInfo) signingKey;
          };
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          credential.helper = "!gh auth git-credential";
          pull.rebase = true;
          diff = {
            tool = "nvim";
            guitool = "nvim";
          };

          difftool = {
            prompt = false;
            trustExitCode = true;
            nvim.cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
          };

          "ghq \"https://github.com/\"" = {
            vcs = "git";
            root = "~/Projects";
          };

          alias = {
            update =
              /*
              bash
              */
              ''
                !f() { \
                  branch="''${1:-''$(git rev-parse --abbrev-ref HEAD)}"; \
                  if [ -z "$branch" ]; then echo "No branch specified"; return 1; fi; \
                  git fetch --all || return $?; \
                  upstream=$(git for-each-ref --format='%(refname:short)' refs/remotes | fzf --prompt="Select upstream: " --header="$branch"); \
                  if [ -z "$upstream" ]; then echo "No upstream selected"; return 1; fi; \
                  git checkout "$branch" || return $?; \
                  remote=$(echo "$upstream" | cut -d'/' -f1); \
                  git rebase "$upstream" || { \
                    if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then \
                      echo "Rebase stopped for conflict resolution. After resolving:"; \
                      echo "  git add <files> && git rebase --continue"; \
                      echo "Then push with:"; \
                      echo "  git push --force-with-lease $remote $branch"; \
                    else \
                      echo "Rebase failed; run git rebase --abort if needed"; \
                    fi; \
                    return 1; \
                  }; \
                  git push --force-with-lease "$remote" "$branch" || return $?; \
                }; f
              '';
            wt =
              /*
              bash
              */
              "!f() { git worktree add -b $1 $(git rev-parse --show-toplevel)/../$(basename $(git rev-parse --show-toplevel))-$1;}; f";
            ls = "log --graph --oneline --decorate";
            ll = "log -p --stat";
            amend = "commit --amend -m";
            rc = "rebase --continue";
            ra = "rebase --abort";
          };
        };
      };

      gh = {
        enable = true;
        # Keep git's own credential helper (osxkeychain / libsecret above).
        gitCredentialHelper.enable = false;
        settings = {
          git_protocol = "https";
          aliases.co = "pr checkout";
        };
      };

      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          features = "side-by-side";
          theme = "Catppuccin Mocha";
        };
      };
    };
  };
}
