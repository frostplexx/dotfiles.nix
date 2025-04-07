<p align="center">
    <img src="https://nixos.wiki/images/thumb/2/20/Home-nixos-logo.png/414px-Home-nixos-logo.png" width=200/>
    <h1 align="center"><code>Nix System Configurations</code></h1>
    <div style="display: grid;" align="center">
    <img src="https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml/badge.svg" height=20/>
    <img src="https://img.shields.io/github/repo-size/frostplexx/dotfiles.nix" height=20/>
    <img src="https://img.shields.io/github/license/frostplexx/dotfiles.nix" height=20/>
    </div>
</p>

![CleanShot 2025-04-07 at 17 51 45@2x](https://github.com/user-attachments/assets/705ebc82-d671-4ccd-845c-01d26904e430)


This repository contains my personal system configurations for NixOS and MacOS.
It provides a reproducible setup for macOS and NixOS systems using flakes and declarative configuration.

This repository is home to the nix code that builds my systems:

1. NixOS Desktops: NixOS with home-manager, kde plasma, steam, etc.
2. macOS Laptops: nix-darwin with home-manager, share the same home-manager configuration with NixOS Desktops.

See [./machines](./machines) for details of each host.<br>
Wallpaper: [./assets/wallpaper.png](./assets/wallpaper.png)

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

#### Setup
Clone this repo into your home directory and cd into it.
```bash
git clone https://github.com/frostplexx/dotfiles.nix.git ~/
cd ~/dotfiles.nix

```

#### Installing on MacOS
On macOS run `./scripts/system-bootstrap.sh` to install Lix.
The script will then also deploy the first generation on your device

#### Installing on NixOS
Run `nix run nixpkgs#just -- deploy <hostname>`[^1] to deploy the system.

### Available Commands

The Makefile offers the following targets that can be run for managing the system:

- `deploy`:         lints, auto-detects OS and deploys appropriate configuration
- `update`:         updates flake and deploys
- `lint`:           format and lint nix files using alejandra, statix and deadnix
- `clean`:          remove old system generations (runs `nh clean all`)
- `repair`:         verify nix store and repair
- `format`:         Format nix files
- `diff`:           Show diff between current and commited changes
- `update-refs`:    Update every fetchFromGithub with its newest commit and hash

In addition `nix-tree`, `nix-output-monitor`, `nh` and `nvd` come installed.

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

If the programs are shared across all configs e.g. neovim, git, ffmpeg then add them to `machines/shared.nix`. 
Else add them to your appropriate host config `machines/<hostname>/apps.nix`

### Home Manager

Home Manager dotfiles are saved in `./home`. 
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

Modules should be added to the `modules` array in `./lib/mksystem.nix`.
If a module should only be applied to one operating system use `isDarwin` to determine the OS type.

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


[^1]: After the first deployment `just` and its alias `j` will be available system wide
