{
  lib,
  pkgs,
  ...
}: {
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "daniel";
    userEmail = "daniel.inama02@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      diff = {
        tool = "nvim";
        guitool = "nvim";
      };
      gpg = {
        format = "ssh";
      };
      # "gpg \"ssh\"" = {
      #   program =
      #     if pkgs.stdenv.isDarwin
      #     then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
      #     else "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      # };
      # commit = {
      #   gpgsign = true;
      # };
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
      };
      credential = {
        helper =
          if pkgs.stdenv.isDarwin
          then "git-credential-osxkeychain"
          else "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret";
      };
      difftool = {
        prompt = false;
        trustExitCode = true;
        nvim = {
          cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        };
      };
      merge = {
        tool = "nvim";
      };
      mergetool = {
        nvim = {
          cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
        };
      };
    };
    delta = {
      enable = true;
      options = {
        features = "side-by-side";
      };
    };
    aliases = {
      # common aliases
      br = "branch";
      co = "checkout";
      st = "status";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      cm = "commit -m";
      ca = "commit -am";
      dc = "diff --cached";
      amend = "commit --amend -m";
      # aliases for submodule
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
      # diff tool aliases
      dt = "difftool";
      mt = "mergetool";
    };
  };
}
