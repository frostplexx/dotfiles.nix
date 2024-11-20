{vars, ...}:
#############################################################
#
#  Host & Users configuration
#
#############################################################
{
  networking.hostName = "pc-dev-lyra";
  networking.computerName = "pc-dev-lyra";
  system.defaults.smb.NetBIOSName = "pc-dev-lyra";

  users.users."${vars.user}" = {
    home = "/Users/${vars.user}";
    description = vars.user;
  };

  nix.settings.trusted-users = [vars.user];
}
