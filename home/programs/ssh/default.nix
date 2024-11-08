{
  programs.ssh = {
    enable = true;
    # Global SSH settings
    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 60
      Include ~/.orbstack/ssh/config
      IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}
