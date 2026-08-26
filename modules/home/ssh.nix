_: {
  flake.homeManagerModules.ssh = {pkgs, ...}: {
    programs.ssh = {
      enable =
        if pkgs.stdenv.hostPlatform.isDarwin
        then true
        else false;
      enableDefaultConfig = false;
      settings."*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
      includes = [
        "~/.ssh/hosts"
      ];
      extraConfig = ''
        IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

        Match exec "echo %h | grep -qE '^10\.162\.233\.'"
          ProxyJump sorbet
      '';
    };
  };
}
