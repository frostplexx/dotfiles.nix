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
        tool = "jetbrains";
        guitool = "jetbrains";
      };
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program =
          if pkgs.stdenv.isDarwin
          then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          else "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      commit = {
        gpgsign = true;
      };
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
      };
      difftool = {
        prompt = false;
        trustExitCode = true;
        jetbrains = {
          cmd = ''
            /usr/bin/env idea diff \
            "$LOCAL" \
            "$REMOTE" \
          '';
        };
        nvim = {
          cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        };
      };
      merge = {
        tool = "jetbrains";
      };
      mergetool = {
        jetbrains = {
          cmd = "touch \"$LOCAL\" \"$REMOTE\" \"$BASE\" \"$MERGED\" && /usr/bin/env idea merge
            \"$LOCAL\" \"$REMOTE\" \"$BASE\" \"$MERGED\"";
          trustExitCode = true;
        };
        nvim = {
          cmd = "nvim -d \"$LOCAL\" \"$MERGED\" \"$REMOTE\" -c 'wincmd J'";
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
