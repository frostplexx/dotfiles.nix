
{ pkgs }:
pkgs.fetchgit {
  url = "https://github.com/frostplexx/dotfiles-assets.nix";
  branchName = "main";
  hash = "sha256-pnHMrmAW9cSa/KzTKcHAR63H7LotU2U0M93YwUuhoi8=";
  fetchLFS = true;
}
