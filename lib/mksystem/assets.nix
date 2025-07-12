# This module fetches remote assets (e.g., dotfiles, secrets) using git LFS.
# It is used to provide shared resources to all systems.
{ pkgs }:
pkgs.fetchgit {
  url = "https://github.com/frostplexx/dotfiles-assets.nix"; # Remote repository URL
  branchName = "main";                                      # Branch to fetch
  hash = "sha256-pnHMrmAW9cSa/KzTKcHAR63H7LotU2U0M93YwUuhoi8="; # Content hash for reproducibility
  fetchLFS = true;                                          # Enable Git LFS support
}
