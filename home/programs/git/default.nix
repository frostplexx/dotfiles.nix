{ lib, pkgs, ... }: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = "daniel";
    userEmail = "daniel.inama02@gmail.com";

    includes = [
      {
        # use diffrent email & name for work
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      diff = {
        tool = "kitty";
        guitool = "kittygui";
      };
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = if pkgs.stdenv.isDarwin
          then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          else "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      commit = {
        gpgsign = true;
      };

      user = {
        # this is the gpg public key
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
      };
      difftool = {
        prompt = false;
        trustExitCode = true;
        kitty = {
          cmd = "kitten diff --to $LOCAL --from $REMOTE";
        };
        kittygui = {
          cmd = "kitten diff --to $LOCAL --from $REMOTE";
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
    };
  };
}
