{
  programs.ssh = {
    enable = true;
    # Global SSH settings
    # enableDefaultConfig = false;
    # matchBlocks."*" = {
    #   forwardAgent = true;
    #   addKeysToAgent = "yes";
    # };

    includes = [
      "~/.ssh/hosts"
    ];
    extraConfig = ''
      IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}
