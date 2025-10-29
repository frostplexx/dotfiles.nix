{
  lib,
  pkgs,
  config,
  ...
}: {
  sops.secrets = {
    "user/name" = {
      sopsFile = ../../secrets/git.yaml;
    };
    "user/email" = {
      sopsFile = ../../secrets/git.yaml;
    };
    "user/signingKey" = {
      sopsFile = ../../secrets/git.yaml;
    };
  };

  home.activation.setupGitConfig = lib.hm.dag.entryAfter ["sops-nix"] ''
    # Create git config with decrypted secrets
    export SOPS_AGE_KEY_FILE="${config.home.homeDirectory}/.config/sops/age/keys.txt"
    cat > ~/.gitconfig << EOF
    [user]
        name = $(cat ${config.sops.secrets."user/name".path})
        email = $(cat ${config.sops.secrets."user/email".path})
        signingkey = $(cat ${config.sops.secrets."user/signingKey".path})
    [init]
        defaultBranch = main
    [push]
        autoSetupRemote = true
    [pull]
        rebase = true
    [diff]
        tool = nvim
        guitool = nvim
    [gpg]
        format = ssh
    [gpg "ssh"]
        program = ${
      if pkgs.stdenv.isDarwin
      then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
      else "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}"
    }
    [commit]
        gpgsign = true
    [credential]
        helper = ${
      if pkgs.stdenv.isDarwin
      then "osxkeychain"
      else "${pkgs.git.override {withLibsecret = true;}}/bin/git-credential-libsecret"
    }
    [difftool]
        prompt = false
        trustExitCode = true
    [difftool "nvim"]
        cmd = nvim -d "\$LOCAL" "\$REMOTE"
    [merge]
        tool = nvim
    [mergetool "nvim"]
        cmd = nvim -d \$LOCAL \$REMOTE \$MERGED -c '\$wincmd w' -c 'wincmd J'
    [ghq]
        root = ~/Developer
    [alias]
        br = branch
        co = checkout
        st = status
        ls = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate
        ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
        cm = commit -m
        ca = commit -am
        dc = diff --cached
        amend = commit --amend -m
        update = submodule update --init --recursive
        foreach = submodule foreach
        dt = difftool
        mt = mergetool
    EOF
  '';

  programs = {
    git = {
      enable = true;
      lfs.enable = true;
      includes = [
        {path = "~/.gitconfig";}
      ];
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
}
