<p align="center">
    <img src="https://nixos.wiki/images/thumb/2/20/Home-nixos-logo.png/414px-Home-nixos-logo.png" width=200/>
    <h1 align="center"><code>Nix Dotfiles</code></h1>
    <div style="display: grid;" align="center">
    <img src="https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml/badge.svg" height=20/>
    <img src="https://img.shields.io/github/repo-size/frostplexx/dotfiles.nix" height=20/>
    <img src="https://img.shields.io/github/license/frostplexx/dotfiles.nix" height=20/>
    </div>
</p>

This repository contains my personal system configurations for NixOS and macOS.
It provides a reproducible setup for macOS and NixOS systems using flakes and declarative configuration.

This repository is home to the nix code that builds my systems:

1. NixOS Desktops: NixOS with home-manager, KDE plasma, steam, etc.
2. macOS Laptops: nix-darwin with home-manager, share the same home-manager configuration with NixOS Desktops.

See [modules/hosts](./modules/hosts) for details of each host.<br>
Wallpapers and other assets are stored in a separate git lfs repo: [frostplexx/dotfiles-assets.nix/tree/main/wallpapers](https://github.com/frostplexx/dotfiles-assets.nix/tree/main/wallpapers)

---

## Getting Started

<!-- prettier-ignore -->
> :red_circle: **IMPORTANT**: **You should NOT deploy this flake directly on your machine :exclamation:
> It will not succeed.** This flake contains my hardware configuration(such as
> [hardware-configuration.nix](machines/pc-nixos/hardware-configuration.nix),
> [Nvidia Support](https://github.com/frostplexx/dotfiles.nix/blob/53bd351febdff82a9f0a2c5de6d6fcf55b58d0aa/machines/pc-nixos/hardware-configuration.nix#L63C1-L72C7),
> etc.) which is not suitable for your hardware to deploy. You
> may use this repo as a reference to build your own configuration.

### Prerequisites

- A Computer running the latest macOS or NixOS
- An internet connection

### Disable SIP (Optional)

To take full advantage of yabai you need to disable system integrity protection on macOS. To do this follow these steps (taken from the yabai wiki), or alternatively use aerospace by modifying the config.

1. Turn off your device
2. **Intel (apple docs):** 
    Hold down command ⌘R while booting your device.
   **Apple Silicon (apple docs):**
    Press and hold the power button on your Mac until “Loading startup options” appears.
    Click Options, then click Continue.
3. In the menu bar, choose Utilities, then Terminal
4. ```bash
    #
    # APPLE SILICON
    #
    
    # If you're on Apple Silicon macOS 13.x.x OR newer
    # Requires Filesystem Protections, Debugging Restrictions and NVRAM Protection to be disabled
    # (printed warning can be safely ignored)
    csrutil enable --without fs --without debug --without nvram
    
    # If you're on Apple Silicon macOS 12.x.x
    # Requires Filesystem Protections, Debugging Restrictions and NVRAM Protection to be disabled
    # (printed warning can be safely ignored)
    csrutil disable --with kext --with dtrace --with basesystem
    
    #
    # INTEL
    #
    
    # If you're on Intel macOS 11.x.x OR newer
    # Requires Filesystem Protections and Debugging Restrictions to be disabled (workaround because --without debug does not work)
    # (printed warning can be safely ignored)
    csrutil disable --with kext --with dtrace --with nvram --with basesystem
    ```
5. Reboot
6. For Apple Silicon; enable non-Apple-signed arm64e binaries
```bash
# Open a terminal and run the below command, then reboot
sudo nvram boot-args=-arm64e_preview_abi
```
7. You can verify that System Integrity Protection is turned off by running csrutil status, which returns System Integrity Protection status: disabled. if it is turned off (it may show unknown for newer versions of macOS when disabling SIP partially).

If you ever want to re–enable System Integrity Protection after uninstalling yabai; repeat the steps above, but run csrutil enable instead at step 4.
Please note that System Integrity Protection will be re–enabled during device repairs or analysis at any Apple Retail Store or Apple Authorized Service Provider. You will have to repeat this step after getting your device back.

### Installation

#### Automatic

```bash
# Run in a terminal:
/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/frostplexx/dotfiles.nix/HEAD/scripts/install.sh)"
```

#### Manual

Clone this repo into your home directory and `cd` into it.
```bash
git clone https://github.com/frostplexx/dotfiles.nix.git ~/
cd ~/dotfiles.nix

```

##### Installing on macOS
1. Install Determinate Nix from https://docs.determinate.systems.
2. Run `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake <path/to/flake>#<config-name>`

##### Installing on NixOS
Run `nixos-rebuild switch --flake <path/to/flake>#<config-name>` to deploy the system.

#### Post-install Checklist

- [ ] Reboot the computer or log out and back in for all the changes to take effect.
- [ ] Log into 1Password and 1Password-cli
- [ ] Enable SSH Agent and CLI integration in 1Password settings
- [ ] Run `determinate-nixd login`
- [ ] Run `gh auth login`
- [ ] Run `jinx generate_ssh_hosts` to generate the hosts file from 1Password entries for easy access.
- [ ] (On macOS) Run `jinx set_screen_hidpi` to set your external screen to HiDPI mode
- [ ] Restore folders from Time Machine

### Available Commands

This config comes with the `jinx` command which lets you manage your system. You can deploy, update, clean, repair and much more with it.
Run `jinx` to get a list of possible commands. You can also chain them e.g. `jinx clean optimise`

## Management

### Add a New Host

1. Create a nix file in `modules/hosts` with the name of the machine.
2. Add you config to `modules/meta/systems.nix`:

### Add New Programs

If the programs are shared across all configs e.g. neovim, git, FFmpeg then add them to `modules/apps/shared-packages.nix`.
Else add them to your appropriate host config `modules/hosts/<hostname>.nix`

### Home Manager

Home Manager dot files are saved in `modules/home`.
To add a new module you need to:

1. Create a nix file e.g. `neoovim.nix` inside `modules/home/`
2. Configure what you want to configure using flake parts
4. The config will automatically be picked up and applied on the rebuild

### Homebrew

Homebrew is also fully managed using nix, which means you're not able to add taps the normal way.
To add a tap instead you first have to add it as an input to your `flake.nix`
```nix
# ...
homebrew-core = {
  url = "github:homebrew/homebrew-core";
  flake = false;
};
# ...
```
You can then add it to `taps = {}` inside `./lib/mksystem.nix`:
```nix
# ...
inherit user;
# Optional: Enable fully-declarative tap management
# With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
mutableTaps = false;
taps = with inputs; {
  "homebrew/homebrew-core" = homebrew-core;
  # More taps...
};
# ...
```

In Homebrew, the repo part of all taps always have `homebrew-` prepended.
- https://docs.brew.sh/Taps
- https://docs.brew.sh/Interesting-Taps-and-Forks

`brew tap <user>/<repo>` makes a clone of the repository at `https://github.com/<user>/homebrew-<repo>` into `$(brew --repository)/Library/Taps`.

When declaring taps, please ensure to name the key as a unique folder starting with `homebrew-`, e.g.:
```diff
       nix-homebrew.taps = {
-        "mtslzr/marmaduke-chromium" = inputs.marmaduke-chromium;
+        "mtslzr/homebrew-marmaduke-chromium" = inputs.marmaduke-chromium;
```
The exact GitHub `<user>/<repo>` should almost always work.

Except this one quirk homebrew can be used like normal. It is however strongly preferred to add apps using `nix-darwin` because I'm using the
cleanup mode "zap" which will automatically uninstall any non-declaratively defined package.

## References

Other dotfiles and flakes:

- https://github.com/ryan4yin/nix-config/blob/main/README.md?plain=1
- https://github.com/mitchellh/nixos-config
- https://github.com/dustinlyons/nixos-config
- https://github.com/wimpysworld/nix-config

