{config, ...}: {
  services = {
    tailscale.enable = true;

    xserver = {
      enable = true;
      xkb.layout = "us";
      videoDrivers = ["nvidia"];
    };

    displayManager = {
      sddm = {
        enable = true;
        # wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = config.user.name;
      };
      defaultSession = "plasmax11";
    };

    desktopManager.plasma6.enable = true;

    # Audio
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    # Other services
    printing.enable = true;
    openssh.enable = true;
  };
}
