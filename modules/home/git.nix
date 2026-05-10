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
          signing.format = "openpgp";
          gpg.format = "ssh";
          "gpg \"ssh\"".program =
            if pkgs.stdenv.isDarwin
            then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          commit.gpgsign =
            if pkgs.stdenv.isDarwin
            then true
            else false;
          credential.helper =
            if pkgs.stdenv.isDarwin
            then "osxkeychain"
            else "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret";
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

      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          features = "side-by-side";
          theme = "Catppuccin Mocha";
        };
      };
    };

    home.file = {
      ".claude/skills/new-feature/SKILL.md".text = ''
            ---
            name: new-feature
            description: >
              Creates a new git worktree for feature work using the `wt` shell function,
              changes into it, and completes the requested work from that directory.
              Use whenever user asks to: start a new feature, create a worktree, work on
              a branch in isolation, or says "new feature called X". Rings terminal bell
              on completion.
            ---

            # New Feature Worktree Skill

            ## What this skill does

            1. Derives branch name from user request (kebab-case, no special chars)
            2. Runs `wt <branch>` to create worktree + cd into it
            3. Does all work from that directory
            4. Rings terminal bell on completion

            ## Step-by-step

            ### 1. Derive branch name

            From user input, produce a short kebab-case name. Examples:
            - "auth refactor" → `auth-refactor`
            - "fix login bug" → `fix-login-bug`
            - "add payment flow" → `add-payment-flow`

            ### 2. Create worktree

        ```bash
            git wt <branch-name>
        ```

            `git wt` is a git alias for `git worktree add -b <branch-name> ../<repo>-<branch-name>`


            Verify: check that `../<repo>-<branch>` directory exists after running.

            ### 3. Work from the new directory

            All subsequent file reads, writes, and commands use the new worktree path:
            `../$(basename $(git rev-parse --show-toplevel))-<branch-name>/`

            Do not operate on the original repo directory.

            ### 4. Complete requested work

            Implement what the user asked for. Commit when done:

        ```bash
            cd <worktree-path> && git add -A && git commit -m "<message>"
        ```

            ### 5. Ring terminal bell

            After all work committed:

        ```bash
            printf '\a'
        ```

            ## Error handling

            - `git wt` not found → tell user to add shell function to `.bashrc`/`.zshrc` and reload
            - Branch already exists → suggest `git worktree list` to find it, or pick different name
            - Dirty working tree warnings → surface to user, don't silently skip
      '';
    };
  };
}
