<p align="center">
    <img src="https://nixos.wiki/images/thumb/2/20/Home-nixos-logo.png/414px-Home-nixos-logo.png" width=200/>
    <h1 align="center">Nix Configuration </h1>
    <div style="display: grid;" align="center">
    <img src="https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml/badge.svg" height=20/>
    <img src="https://img.shields.io/github/repo-size/frostplexx/dotfiles.nix" height=20/>
    <img src="https://img.shields.io/github/license/frostplexx/dotfiles.nix" height=20/>
    </div>
</p>

This repository contains my personal system configurations for NixOS and MacOS.
It provides a reproducible setup for macOS systems using declarative configuration.

<table align="center">
    <tr>
        <td></td><td>MacOS</td><td>NixOS</td>
    </tr>
    <tr>
        <td>Shell</td><td>zsh</td><td>zsh</td>
    </tr>
    <tr>
        <td>WM</td><td>Aerospace</td><td>KDE Plasma</td>
    </tr>
    <tr>
        <td>Editor</td><td>NeoVim</td><td>NeoVim</td>
    </tr>
    <tr>
        <td>Terminal</td><td>kitty</td><td>kitty</td>
    </tr>
    <tr>
        <td>Launcher</td><td>Raycast</td><td>krun</td>
    </tr>
    <tr>
        <td>Browser</td><td>Zen Browser</td><td>Zen Browser</td>
    </tr>
</table>

---

## Getting Started

### Prerequisites

- A Computer running macOS or NixOS
- Make available
  - On macOS install it using `xcode-select --install`
  - On NixOS you can get a shell with make by running `nix-shell -p gnumake`

### Installation

1. Clone this repo into your home directory and cd into it
2. On macOS run `make install` to install Nix, nix-darwin and home-manager
3. Use `make` to deploy the system. This will prompt you to select a config.

### Available Commands

The Makefile offers the following targets that can be run for managing the system:

- `all`:      same as deploy
- `deploy`:   lints, auto-detects OS and deploys appropriate configuration
- `update`:   updates flake and deploys
- `bootstrap`:  first-time setup for MacOS
- `lint`:     format and lint nix files using alejandra, statix and deadnix
- `clean`:    remove old system generations (runs `nh clean all`)
- `repair`:   verify nix store and repair

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

