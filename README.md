# Nix Configuration

[![Nix Configuration Validation](https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml/badge.svg)](https://github.com/frostplexx/dotfiles.nix/actions/workflows/validate.yml) ![GitHub repo size](https://img.shields.io/github/repo-size/frostplexx/dotfiles) ![GitHub License](https://img.shields.io/github/license/frostplexx/dotfiles)

This repository contains my personal system configuration using `nix-darwin` and `home-manager`. It provides a reproducible setup for macOS systems using declarative configuration.

## Structure

```
 .
├──  flake.lock
├──  flake.nix
├── 󱂵 home
│   ├──  default.nix
│   ├──  programs
│   │   ├──  aerospace
│   │   ├──  editor
│   │   ├──  git
│   │   ├──  kitty
│   │   ├──  plasma
│   │   └──  shell
│   └──  README.md
├──  hosts
│   ├──  darwin
│   │   ├──  apps.nix
│   │   ├──  configuration.nix
│   │   ├──  custom_icons
│   │   ├──  host-users.nix
│   │   ├──  README.md
│   │   └──  system.nix
│   └──  nixos
│       ├──  apps.nix
│       ├──  configuration.nix
│       ├──  hardware-configuration.nix
│       ├──  system.nix
│       └──  users.nix
├──  LICENSE
├──  Makefile
├──  README.md
└──  result -> /nix/store/...
```

## Key Files and Their Purpose

### System Configuration

- `flake.nix`: Entry point for the Nix configuration, defining input sources and outputs.
- `flake.lock`: Lock file for reproducibility.
- `Makefile`: Automation scripts for deploying configurations.

### User Configuration

- `home/default.nix`: Main `home-manager` configuration file with user-specific settings.
- `home/programs/`: Configurations for various programs:
  - `aerospace/`
    - `aerospace.toml`
    - `default.nix`
  - `editor/`
  - `git/`
  - `kitty/`
  - `plasma/`
  - `shell/`

### Host-Specific Configuration

- `hosts/darwin/`: macOS-specific configurations using `nix-darwin`.
  - `apps.nix`: Applications to be installed (Nix packages, Homebrew, App Store apps).
  - `configuration.nix`: Main macOS configuration file.
  - `system.nix`: System preferences and settings.
  - `host-users.nix`: Host and user configurations.
  - `custom_icons/`: Custom icon resources.
- `hosts/nixos/`: NixOS-specific configurations.
  - `apps.nix`: Applications to be installed.
  - `configuration.nix`: Main NixOS configuration file.
  - `hardware-configuration.nix`: Hardware specifics.
  - `system.nix`: System-level settings.
  - `users.nix`: User accounts and permissions.

## Installation

1. **Install Nix:**

   ```bash
   make install
   ```

   *Note: After Nix installation, restart your terminal and run `make install` again. Ensure Homebrew is installed correctly and you're logged into the App Store.*

2. **Deploy Configuration:**

   ```bash
   make deploy
   ```

## Available Commands

```bash
# Full system deployment
make deploy

# Deploy only for macOS
make deploy-darwin

# Deploy only for NixOS
make deploy-nixos

# Update packages and configurations
make update

# Run linters
make lint

# Clean old generations
make clean
```

## Configuration Guide

### Adding a New Program

#### As a User Package

1. **Create a new directory under `programs`:**

   ```bash
   mkdir -p home/programs/newprogram
   ```

2. **Create a `default.nix` in the new directory:**

   ```nix
   { config, pkgs, ... }: {
     programs.newprogram = {
       enable = true;
       # Program-specific configuration
     };
   }
   ```

#### As a System Package

- **For macOS:** Open 

apps.nix

 and add your package to `environment.systemPackages`.
- **For NixOS:** Open 

apps.nix

 and add your package to `environment.systemPackages`.

### Modifying System Settings

- **macOS:** Edit 

system.nix

 to change system-level settings.
- **NixOS:** Edit 

system.nix

 for system-level configurations.

## Maintenance

### Updating

To update all packages and configurations:

```bash
make update
```

### Cleaning Up

To remove old generations and free up space:

```bash
make clean
```

## Troubleshooting

### Common Issues

1. **Nix command not found**

   - Restart your terminal after installation.
   - Run `make install` again.

2. **Darwin rebuild fails**

   - Check your 

flake.nix

 for syntax errors.
   - Ensure all required files exist.
   - Run with `--show-trace` for detailed error messages.

3. **Home-manager issues**

   - Verify your configuration syntax.
   - Check program availability in `nixpkgs`.
   - Look for conflicting configurations.

## Contributing

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Push to the branch.
5. Create a Pull Request.

## License

This project is licensed under the Apache License 2.0.
