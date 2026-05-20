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

This repository contains my personal system configuration for macOS.
It provides a reproducible setup for macOS and NixOS systems using flakes and declarative configuration.

Wallpapers and other assets are stored in a separate git lfs repo: [frostplexx/dotfiles-assets.nix/tree/main/wallpapers](https://github.com/frostplexx/dotfiles-assets.nix/tree/main/wallpapers)

---

## Getting Started

### Prerequisites

- A Computer running the latest macOS
- An internet connection

### Installation

#### Automatic

```bash
# Run in a terminal:
/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/frostplexx/dotfiles.nix/HEAD/scripts/install.sh)"
```

#### Manual

1. Clone this repo into your home directory and `cd` into it.

```bash
git clone https://github.com/frostplexx/dotfiles.nix.git ~/dotfiles.nix
cd ~/dotfiles.nix

```

2. install determinate nix from https://docs.determinate.systems.
3. run `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles.nix#<config-name>` to build and switch to the configuration.

#### Post-install Checklist

- [ ] Reboot the computer or log out and back in for all the changes to take effect.
- [ ] Log into 1Password and 1Password-cli
- [ ] Enable SSH Agent and CLI integration in 1Password settings
- [ ] Run `determinate-nixd login`
- [ ] Run `gh auth login`
- [ ] Run `jinx generate_ssh_hosts` to generate the hosts file from 1Password entries for easy access.
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
