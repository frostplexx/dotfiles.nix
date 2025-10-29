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

- A Computer running the latest macOS or NixOS
- An internet connection
- Age key for decrypting secrets (stored in 1Password as "dotfiles-age" or your own age key)

### Secrets Management

This configuration uses [sops-nix](https://github.com/Mic92/sops-nix) to manage encrypted secrets. Personal information like git user details are stored encrypted in the `secrets/` directory.

**Age Key Setup:**
- The age key is stored in 1Password under "Personal/dotfiles-age/Private Key"
- Alternatively, you can generate your own age key with `age-keygen -o ~/.config/sops/age/keys.txt`
- The key file should be placed at `~/.config/sops/age/keys.txt`

**Age Key Backup:**
To prevent losing access to your encrypted secrets, you should backup your age key in multiple locations:

1. **1Password** (already configured)
2. **Encrypted cloud backup** - Create an additional encrypted backup:
   ```bash
   # Create an encrypted backup of your age key
   openssl enc -aes-256-cbc -salt -in ~/.config/sops/age/keys.txt -out ~/age-key-backup.enc -k "$(openssl rand -base64 32)"

   # Store the encrypted file and password separately in cloud storage
   # Upload age-key-backup.enc to Google Drive/Dropbox/etc.
   # Store the encryption password in a separate secure location (different password manager, printed on paper, etc.)
   ```

3. **Recovery script** - Use the included backup script:
   ```bash
   # Create backup
   ./scripts/backup-age-key.sh

   # Restore from backup
   ./scripts/restore-age-key.sh
   ```

**Emergency Recovery:**
If you lose access to all your devices and need to recover:
1. Get your encrypted backup file from cloud storage
2. Get your backup password from your secure secondary location
3. On a new device, run: `./scripts/restore-age-key.sh`
4. Follow the prompts to restore your age key
5. Reinstall your dotfiles: `git clone <repo> && <installation steps>`

**Security Notes:**
- Never store the backup password and encrypted file together
- Use different storage services for each component
- Consider using a hardware security key for additional protection
- Regularly test your backup restoration process

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
# This will install Nix, clone the repository, set up SOPS secrets, and deploy the system
/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/frostplexx/dotfiles.nix/HEAD/scripts/install.sh)"
```

#### Manual

Clone this repo into your home directory and `cd` into it.
```bash
git clone https://github.com/frostplexx/dotfiles.nix.git ~/
cd ~/dotfiles.nix

# Set up SOPS for encrypted secrets
# Option 1: If using 1Password (recommended)
# Make sure 1Password CLI is installed and you're logged in
op read "op://Personal/dotfiles-age/Private Key" > ~/.config/sops/age/keys.txt

# Option 2: If you have your own age key
# Copy your age private key to ~/.config/sops/age/keys.txt

# Test decryption
sops --decrypt secrets/git.yaml

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
- [ ] Verify sops secrets are accessible: `cat ~/.config/sops/age/keys.txt` (should contain your age private key)
- [ ] Test sops decryption: `sops --decrypt ~/dotfiles.nix/secrets/git.yaml` (should show decrypted content)
- [ ] Create age key backup: `~/dotfiles.nix/scripts/backup-age-key.sh` (store password and file separately)
- [ ] Run `determinate-nixd login`
- [ ] Run `jinx generate_ssh_host` to generate the hosts file from 1Password entries for easy access.
- [ ] (On macOS) Run `jinx set_screen_hidpi` to set your external screen to HiDPI mode
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

## NeoVim

### Package management

The neovim config uses the built in package manager with a "unpack" (https://github.com/mezdelex/unpack) around it.

You can add plugins by adding them to a file inside `lua/plugins/`. Plugin definitions follow the following specification:

```lua
---@class UnPack.Spec : vim.pack.Spec
---@field config? fun()
---@field defer? boolean
---@field dependencies? UnPack.Spec[]
```

For more info about the vim.pack.Spec you can check out https://neovim.io/doc/user/pack.html#vim.pack

<!-- ### :Pack -->
<!---->
<!-- In addition to declarative package management the config also provides the `:Pack` command which will show a UI for easy uninstalling and updating of -->
<!-- plugins -->

## References

Other dotfiles and flakes:

- https://github.com/ryan4yin/nix-config/blob/main/README.md?plain=1
- https://github.com/mitchellh/nixos-config
- https://github.com/dustinlyons/nixos-config
- https://github.com/wimpysworld/nix-config

