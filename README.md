<p align="center">
    <a href="http://www.hexley.com/license.html">
    <img src="https://github.com/user-attachments/assets/3db65c06-1c36-4ddd-bcb9-66beaae39d5d" width=225/>
    </a>
    <h1 align="center"><code>Nix Dotfiles</code></h1>
    <div style="display: grid;" align="center">
    <img src="https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml/badge.svg" height=20/>
    <img src="https://img.shields.io/github/repo-size/frostplexx/dotfiles.nix" height=20/>
    <img src="https://img.shields.io/github/license/frostplexx/dotfiles.nix" height=20/>
    </div>
</p>

This repository contains my personal system configuration for macOS and NixOS.
It provides a reproducible setup for macOS and NixOS systems using flakes and declarative configuration.

Wallpapers and other assets are stored in a separate git lfs repo: [frostplexx/dotfiles-assets.nix/tree/main/wallpapers](https://github.com/frostplexx/dotfiles-assets.nix/tree/main/wallpapers)

---

## Getting Started

### Prerequisites

- A Computer running the latest macOS or any Linux Distro
- An internet connection

### Installation

<details>
<summary>MacOS</summary>
    
#### Automatic

```bash
# Run in a terminal:
/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/frostplexx/dotfiles.nix/HEAD/scripts/install.sh)"
```

The installer will attempt to pull the SOPS age key from iCloud Keychain automatically.
If the key hasn't synced yet, you can seed it from an existing machine before running the install:
```bash
ssh <existing-machine> 'mkdir -p ~/.config/sops/age && security add-generic-password -a "$USER" -s "sops-age-key" -w < ~/.config/sops/age/keys.txt'
```

#### Manual

1. Clone this repo into your home directory and `cd` into it.

```bash
git clone https://github.com/frostplexx/dotfiles.nix.git ~/dotfiles.nix
cd ~/dotfiles.nix

```

2. install determinate nix from https://docs.determinate.systems.
3. run `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles.nix#<config-name>` to build and switch to the configuration.
</details>

<details>
<summary>Linux/NixOS</summary>

#### Using nixos-anywhere (recommended)

This approach needs two computers: *host* = PC you install from and *target* = PC you install to. 
Additionally the host PC also needs to have nix or NixOS installed.
Using nixos-anywhere will completely **overwrite the target PCs OS** and replace it with NixOS!
Before installing, make sure the following disk UUID is the correct one as it needs to be changed when installing to a new/different PC:
https://github.com/frostplexx/dotfiles.nix/blob/2345eff47fda054796660a35b1b589c091ab7637/modules/hosts/tiramisu/configuration.nix#L71 

**Instructions**

1. Boot your target PC into Linux or a live Linux ISO
2. Make sure `sshd` is enabled and ssh access with password is turned on
4. On your host PC clone this repo and cd into it
5. Run `SSHPASS="<ssh password>" nix run github:nix-community/nixos-anywhere -- --env-password --flake .<config-name> --target-host <user>@<ip> --build-on remote`. The user used in the command needs sudo access.
6. After the command finished the target PC should have booted into NixOS with the config correctly applied.

#### Manually

1. Go to https://nixos.org/download/#nix-install-linux and install NixOS on your PC
2. Enable [flakes](https://wiki.nixos.org/wiki/Flakes#Enabling_flakes_permanently).
3. Clone this repo into your home directory and `cd` into it.

```bash
git clone https://github.com/frostplexx/dotfiles.nix.git ~/dotfiles.nix
cd ~/dotfiles.nix
```
4. Deploy the config by running `sudo nixos-rebuild switch --flake .#<config-name>`

</details>

#### Post-install Checklist

- [ ] Reboot the computer or log out and back in for all the changes to take effect.
- [ ] Log into 1Password and 1Password-cli
- [ ] Enable SSH Agent and CLI integration in 1Password settings
- [ ] Run `determinate-nixd login`
- [ ] Run `gh auth login`
- [ ] Run `jinx generate_ssh_hosts` to generate the hosts file from 1Password entries for easy access.
- [ ] Seed the SOPS age key into iCloud Keychain (if not picked up by the installer):
      `mkdir -p ~/.config/sops/age && security add-generic-password -a "$USER" -s "sops-age-key" -w < ~/.config/sops/age/keys.txt`
- [ ] (On macOS) Run `jinx set_screen_hidpi` to set your external screen to HiDPI mode
- [ ] Restore folders from Time Machine

## Management

### Available Commands

This config comes with the `jinx` command which lets you manage your system. You can deploy, update, clean, repair and much more with it.
Run `jinx` to get a list of possible commands. You can also chain them e.g. `jinx clean optimise`

### Home Manager

Home Manager dot files are saved in `modules/home`.
To add a new module you need to:

1. Create a nix file e.g. `neovim.nix` inside `modules/home/`
2. Configure what you want to configure using flake parts
3. The config will automatically be picked up and applied on the rebuild

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

You can then add it to the `taps` attribute in your host configuration file (e.g. `modules/hosts/macbook-m4-pro.nix`):

```nix
# ...
nix-homebrew = {
  # ...
  taps = with inputs; {
    "homebrew/homebrew-core" = homebrew-core;
    # More taps...
  };
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

---

“NixOS Logo” by Simon Frankau, Tim Cuthbertson, and Daniel Baker (maintained by the NixOS Marketing Team), from nixos/branding, licensed under CC BY 4.0. <br>
Hexley DarwinOS Mascot Copyright 2000 by Jon Hooper All Rights Reserved.
