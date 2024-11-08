{ ... }:
{
  programs.ssh = {
    enable = true;
    # Global SSH settings
    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 60
      Include ~/.orbstack/ssh/config
      IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    '';
    # Host-specific configurations
    matchBlocks = {

      "NixOS" = {
        user = "daniel";
        hostname = "192.168.1.101";
         extraOptions = {
          "SetEnv" = "ONEPASSWORD_ITEM=\"Desktop PC\"";
        };
      };

      "CIP" = {
        hostname = "remote.cip.ifi.lmu.de";
        user = "inama";
         extraOptions = {
          "SetEnv" = "ONEPASSWORD_ITEM=\"LMU CIP\"";
        };
      };

      "Hetzner_VPS" = {
        hostname = "37.27.26.175";
        user = "ubuntu";
         extraOptions = {
          "SetEnv" = "ONEPASSWORD_ITEM=\"Hetzner VPS\"";
        };
      };

      "Proxmox" = {
          hostname = "192.168.1.85";
          user = "root";
         extraOptions = {
          "SetEnv" = "ONEPASSWORD_ITEM=Proxmox";
        };
      };

      "MetisBot" = {
        hostname = "129.152.13.213";
        user = "ubuntu";
      };

    };
  };
}
