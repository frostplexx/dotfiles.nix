{ vars, ... }:

#############################################################
#
#  Host & Users configuration
#
#############################################################

{
  networking.hostName = "daniels-MacBook-Pro";
  networking.computerName = "daniels-MacBook-Pro";
  system.defaults.smb.NetBIOSName = "daniels-MacBook-Pro";

  users.users."${vars.user}" = {
    home = "/Users/${vars.user}";
    description = vars.user;
  };

  nix.settings.trusted-users = [ vars.user ];
}
