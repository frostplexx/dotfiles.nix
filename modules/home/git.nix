_: {
  flake.modules.homeManager.git = {
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
          gpg.format = "ssh";
          "gpg \"ssh\"".program =
            if pkgs.stdenv.isDarwin
            then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          commit.gpgsign = true;
          credential.helper =
            if pkgs.stdenv.isDarwin
            then "osxkeychain"
            else "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret";
          difftool = {
            prompt = false;
            trustExitCode = true;
            nvim.cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
          };
          merge.tool = "nvim";
          mergetool.nvim.cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
          ghq.root = "~/Developer";
          alias = {
            br = "branch";
            co = "checkout";
            st = "status";
            ls = "log --graph --oneline --decorate";
            ll = "log -p --stat";
            cm = "commit -m";
            ca = "commit -am";
            dc = "diff --cached";
            amend = "commit --amend -m";
            update = "submodule update --init --recursive";
            foreach = "submodule foreach";
            dt = "difftool";
            mt = "mergetool";
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
  };
}
