<p align="center">
    <img src="https://nixos.wiki/images/thumb/2/20/Home-nixos-logo.png/414px-Home-nixos-logo.png" width=200/>
    <h1 align="center"><code>Nix System Configurations</code></h1>
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

See [./machines](./machines) for details of each host.<br>
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

- A Computer running macOS or NixOS

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
- [ ] Run `jinx generate_ssh_host` to generate the hosts file from 1Password entries for easy access.
- [ ] (On macOS) Run `jinx set_screen_hidpi` to set your screen to HiDPI mode
- [ ] Restore folders from Time Machine

### Available Commands

This config comes with the `jinx` command which lets you manage your system. You can deploy, update, clean, repair and much more with it.
Run `jinx` to get a list of possible commands. You can also chain them e.g. `jinx clean optimise`

## Management

### Add a New Host

1. Create a folder in `./machines` wit the name of the machine. That folder should contain the following
    - `configuration.nix` for system configuration
    - `hardware-configuration.nix` (optional) for hardware configs
    - `apps.nix` (optional) for specific apps that only that host should have
2. Add you config to `flake.nix`:
```nix
# ...
# or darwinConfigurations
darwinConfigurations.<hostname> = mkSystem "<foldername>" {
  system = "aarch64-darwin";
  user = "<username>";
  # Home manager modules you want to include as defined in ./home
  hm-modules = [
    # ... List of modules found in ./home
  ];
};
# ...
```
### Add New Programs

If the programs are shared across all configs e.g. neovim, git, FFmpeg then add them to `machines/shared.nix`.
Else add them to your appropriate host config `machines/<hostname>/apps.nix`

### Home Manager

Home Manager dot files are saved in `./home`.
To add a new module you need to:

1. Create a folder with a `default.nix` inside `./home/`
2. Configure what you want to configure
4. Append the folder name to `hm-modules` in your `flake.nix` (see [[#Adding a New Host]])

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

### Modules

Modules should be added to the `imports` array in `./lib/mksystem/darwin.nix` or in `./lib/mksystem/linux.nix`.
Home Manager modules should be added to `./lib/mksystem/modules.nix` inside sharedModules.

### Overlays

Overlays can either be added to the overlays array inside `flake.nix` or
dropped as a file inside `./overlays/` which will then get automatically loaded.
You'll need to add `nixpkgs.overlays = import ../../lib/overlays.nix;`
to the configuration that should load its overlays from the folder

## References

Other dotfiles and flakes:

- https://github.com/ryan4yin/nix-config/blob/main/README.md?plain=1
- https://github.com/mitchellh/nixos-config
- https://github.com/dustinlyons/nixos-config
- https://github.com/wimpysworld/nix-config

