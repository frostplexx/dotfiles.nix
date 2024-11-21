# Nix Configuration

[![Nix Configuration Validation](https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml/badge.svg)](https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml) ![GitHub repo size](https://img.shields.io/github/repo-size/frostplexx/dotfiles.nix) ![GitHub License](https://img.shields.io/github/license/frostplexx/dotfiles.nix)

This repository contains my personal system configuration using `nix-darwin` and `home-manager`. It provides a reproducible setup for macOS systems using declarative configuration.


- Inspiration: 
    - https://github.com/MatthiasBenaets/nix-config/blob/master/hosts/default.nix
    - https://github.com/shaunsingh/nix-darwin-dotfiles/blob/main/modules/parts/nixos.nix


TODO: 

- [ ] On first install it should show all compatible configs as an fzf list
- [ ] After the first install the device should have the correct hostname and the config for that should get applied
- [ ] Add man pages: man-pages man-pages-posix
- [ ] Set kitty trail to 3
- [ ] Rewrite the Makefile
