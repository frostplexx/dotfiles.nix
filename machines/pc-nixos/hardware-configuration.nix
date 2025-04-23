{
  config,
  lib,
  pkgs,
  disko,  # Add this import
  ...
}: {
  imports = [
    disko.nixosModules.disko  # Add the Disko module
  ];

  # Keep your existing boot configuration
  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];
      systemd.enable = true;
      verbose = false;
    };
    kernelModules = ["kvm-amd" "i2c-dev"];
    extraModulePackages = [];
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      # Hardware optimizations
      "acpi_enforce_resources=lax"
      "amd_iommu=on"
      "iommu=pt"
      "zswap.enabled=1"
      # Memory management
      "default_hugepagesz=2M"
      "hugepagesz=2M"
      "hugepages=1024"
      "transparent_hugepage=always"
    ];
    consoleLogLevel = 0;
    loader = {
      # timeout = 3;
      systemd-boot = {
        enable = true;
        # configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Add Disko configuration
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-uuid/9dd20559-b9dd-4320-a392-7356b5391cbc";  # Your root disk
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "EF00";  # EFI System Partition
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };
            swap = {
              size = "8G";  # Adjust size as needed
              content = {
                type = "swap";
              };
            };
            root = {
              size = "100%";  # Use remaining space
              content = {
                type = "btrfs";
                extraArgs = ["-f"];  # Force formatting
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };
                  # Add additional subvolumes if needed
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems = {
    "/mnt/share" = {
      device = "//u397529.your-storagebox.de/backup";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
    };
    "/mnt/nas" = {
      device = "//192.168.1.122/data";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/etc/nixos/nas-secrets,uid=1000,gid=100"];
    };
  };

  # Note: When using disko, you may not need to explicitly define swapDevices
  # as they are managed by disko, but you can keep this if you prefer
  swapDevices = [{device = "/dev/disk/by-uuid/d74f495a-a51e-4fa6-a55a-2ce0a2b2c985";}];

  # Keep the rest of your hardware configuration
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    xone.enable = true;
    graphics.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
