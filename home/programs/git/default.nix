{
  lib,
  ...
}: {
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';
  programs.git = {
    enable = true;
    lfs.enable = true;

    # Default configuration (used when no conditional includes match)
    userName = "daniel";
    userEmail = "daniel.inama02@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;

      # Configure different credentials based on repository URL
      "user \"https://github.com/**\"" = {
        name = "daniel";
        email = "daniel.inama02@gmail.com";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
      };

      "user \"https://gitlab.lrz.de/**\"" = {
        name = "Inama, Daniel"; # Replace with your university name
        email = "D.Inama@campus.lmu.de"; # Replace with your university email
      };

      # GPG signing configuration (only for GitHub)
      # "gpg \"https://github.com/**\"" = {
      #   format = "ssh";
      # };
      #
      # "gpg \"ssh\" \"https://github.com/**\"" = {
      #   program =
      #     if pkgs.stdenv.isDarwin
      #     then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
      #     else "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      # };

      "commit \"https://github.com/**\"" = {
        gpgsign = true;
      };

      # Diff tool configuration
      diff = {
        tool = "kitty";
        guitool = "kittygui";
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

    # Work directory specific configuration
    includes = [
      {
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];

    delta = {
      enable = true;
      options = {
        features = "side-by-side";
      };
    };

    aliases = {
      br = "branch";
      co = "checkout";
      st = "status";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      cm = "commit -m";
      ca = "commit -am";
      dc = "diff --cached";
      amend = "commit --amend -m";
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
    };
  };
}
