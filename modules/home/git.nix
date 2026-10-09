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
      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user = {
            inherit (defaults.personalInfo) name;
            inherit (defaults.personalInfo) email;
            inherit (defaults.personalInfo) signingKey;
          };
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          diff = {
            tool = "nvim";
            guitool = "nvim";
          };
          # Commits are only signed on macOS, through 1Password's SSH agent.
          gpg = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
            format = "ssh";
            ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
          };
          commit.gpgsign = pkgs.stdenv.hostPlatform.isDarwin;
          # gitFull ships the libsecret helper and is in the binary cache;
          # overriding pkgs.git with withLibsecret rebuilt git from source.
          credential.helper =
            if pkgs.stdenv.hostPlatform.isDarwin
            then "osxkeychain"
            else "${pkgs.gitFull}/bin/git-credential-libsecret";
          difftool = {
            prompt = false;
            trustExitCode = true;
            nvim.cmd = ''
              nvim -d -c "DiffviewOpen "$LOCAL" "$MERGED" "$REMOTE""
            '';
          };
          merge.tool = "nvim";
          mergetool.nvim.cmd = "nvim +DiffviewOpen '$LOCAL' '$MERGED' '$REMOTE'";
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
            br = "branch";
            co = "checkout";
            st = "status";
            ls = "log --graph --oneline --decorate";
            ll = "log -p --stat";
            cm = "commit -m";
            ca = "commit -am";
            dc = "diff --cached";
            amend = "commit --amend -m";
            foreach = "submodule foreach";
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
