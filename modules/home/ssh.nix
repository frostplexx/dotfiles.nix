_: {
  flake.homeManagerModules.ssh = {pkgs, ...}: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
      includes = [
        "~/.ssh/hosts"
      ];
      # 1Password's SSH agent; ~/.ssh/hosts (from `jinx generate-ssh-hosts`)
      # points IdentityFile at public keys, which the agent then signs for.
      extraConfig = ''
        IdentityAgent = "${
          if pkgs.stdenv.hostPlatform.isDarwin
          then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          else "~/.1password/agent.sock"
        }"

        Match exec "echo %h | grep -qE '^10\.162\.233\.'"
          ProxyJump sorbet
      '';
    };
  };
}
