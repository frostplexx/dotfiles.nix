# This module fetches remote assets (e.g., dotfiles, secrets) using git LFS.
# It is used to provide shared resources to all systems.
{pkgs}:
pkgs.fetchgit {
  url = "https://github.com/frostplexx/dotfiles-assets.nix"; # Remote repository URL
  branchName = "main"; # Branch to fetch
  hash = "sha256-ySxfJm0P+0tWQVLlI8OGggCz+7AztXQR9PRVh/H5HzY="; # Content hash for reproducibility
  fetchLFS = true; # Enable Git LFS support
}
