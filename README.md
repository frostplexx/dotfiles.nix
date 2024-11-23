# Nix Configuration

[![Nix Configuration Validation](https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml/badge.svg)](https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml) ![GitHub repo size](https://img.shields.io/github/repo-size/frostplexx/dotfiles.nix) ![GitHub License](https://img.shields.io/github/license/frostplexx/dotfiles.nix)

This repository contains my personal system configurations for NixOS and MacOS.
It provides a reproducible setup for macOS systems using declarative configuration.

|               | MacOS                 | Linux                                              |
|---------------|-------------------------|--------------------------------------------------|
| **Shell:**    | zsh | zsh                                                |
| **WM:**       | aerospace       | kde plasma 6 |
| **Editor:**   | neovim | neovim                                                |
| **Terminal:** | kitty                    | kitty                                               |
| **Launcher:** | raycast                    | krunner                                                |
| **Browser:**  | arc                 | firefox                                                |


---

## Quick Start

0. On MacOS run `xcode-select --install` to install make and git
1. Clone this repo into your home directory and cd into it
1.5. On MacOS run `make install`
2. Run `make` it will prompt you to select a config.


## Management

### Add a New Host

1. Create a folder in `hosts/machines`. That folder should contain the following
    - `configuration.nix` for system configurtion
    - `hardware-configuration.nix` (optional) for hardware configs
    - `apps.nix` (optioanal) for specific apps that only that host should have
    - `stylix.nix` (optional) if you want to specify stylix settings, e.g. font, cursor
2. Add you config to `hosts/default.nix`. My computers are named after `<location>-<type>-<name>` but the make 
script only looks at the name part so make sure that matches in the config:
```nix
# or darwinConfigurations
nixosConfigurations = {
    #...
  foo = {
    system = "x86_64-linux";
    stateVersion = "24.05";
    modules = [
      ./base # Base configuration
      ./machines/foo/configuration.nix # Machine-specific configs
    ];
  };
    #...
};
```
3. Add the home manager modules to your newly created `configuration.nix`:
```nix
# Home Manager configuration
home-manager.users.${config.user.name} = mkHomeManagerConfiguration.withModules [
  "editor"
  "firefox"
  "kitty"
  "git"
  "shell"
  "plasma"
  "nixcord"
  "spicetify"
];
```

### Add New Programs

If the programs are shared across all configs e.g. neovim, git, ffmpeg then add them to `hosts/base/apps.nix`. 
Else add them to your the appropriate host config `hosts/machines/<hostname>/apps.nix`

### Home Manager

Home Manager dotfiles are saved in `home`. 
To add a new module you need to: 

1. Create a folder with a `default.nix` inside
2. Configure what you want to configure
3. Add it to the `allModules` list in `home/default.nix`
4. Inside one of your hosts configs (located in `hosts/machines/<hostname>/configuration.nix`) add the module to the list of 
   modules for the home-manager config
   ```nix
    # Home Manager configuration
    home-manager.users.${vars.user} = mkHomeManagerConfiguration.withModules [
      "aerospace"
      "editor"
      "firefox"
      "kitty"
      "git"
      "shell"
      "nixcord"
      "spicetify"
      "ssh"
      "<your_module>"
    ];
   ```
