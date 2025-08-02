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
    userName = "example-user"; # your username here
    userEmail = "mail@example.com"; # your eamil here
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
      commit = {
        gpgsign = false;
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
      ghq = {
        root = "~/Developer";
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
