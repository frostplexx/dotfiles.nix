#!/usr/bin/env bash

flakeDir="$HOME/dotfiles.nix"

# Script to automatically update the system

if [ -z "${flakeDir}" ]; then
	echo "Flake directory not specified. Use '--flake <path>' or set \$FLAKE_DIR."
	exit 1
fi

cd $flakeDir

echo "Pulling the latest version of the repository..."
git stash
git pull
git stash pop

echo "Updating..."
git add .
make update

echo "Cleaning up..."
make clean

echo "Done!"
git push
