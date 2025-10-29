#!/usr/bin/env bash

# Age Key Restore Script
# This script restores your age key from an encrypted backup

set -e

AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
BACKUP_DIR="$HOME/age-key-backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create sops directory if it doesn't exist
mkdir -p "$(dirname "$AGE_KEY_FILE")"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    print_error "Backup directory not found: $BACKUP_DIR"
    echo "Please ensure you have backups in this directory."
    exit 1
fi

# List available backups
echo "Available backups:"
echo "=================="
BACKUPS=("$BACKUP_DIR"/*.enc)
if [ ${#BACKUPS[@]} -eq 0 ] || [ ! -f "${BACKUPS[0]}" ]; then
    print_error "No backup files found in $BACKUP_DIR"
    exit 1
fi

for i in "${!BACKUPS[@]}"; do
    echo "$((i+1)). $(basename "${BACKUPS[$i]}")"
done

echo
read -p "Select backup number to restore: " -r BACKUP_NUM

if ! [[ "$BACKUP_NUM" =~ ^[0-9]+$ ]] || [ "$BACKUP_NUM" -lt 1 ] || [ "$BACKUP_NUM" -gt ${#BACKUPS[@]} ]; then
    print_error "Invalid selection"
    exit 1
fi

SELECTED_BACKUP="${BACKUPS[$((BACKUP_NUM-1))]}"

print_status "Selected backup: $(basename "$SELECTED_BACKUP")"

# Get password
echo
read -s -p "Enter the backup password: " -r BACKUP_PASSWORD
echo

# Test decryption first
print_status "Testing decryption..."
if ! echo "$BACKUP_PASSWORD" | openssl enc -aes-256-cbc -d -in "$SELECTED_BACKUP" -pass stdin > /dev/null 2>&1; then
    print_error "Failed to decrypt backup. Wrong password or corrupted file."
    exit 1
fi

print_success "Password verified. Decrypting..."

# Decrypt and restore
echo "$BACKUP_PASSWORD" | openssl enc -aes-256-cbc -d -in "$SELECTED_BACKUP" -pass stdin -out "$AGE_KEY_FILE"

# Set correct permissions
chmod 600 "$AGE_KEY_FILE"

print_success "Age key restored to $AGE_KEY_FILE"

# Test that sops can use the key
if command -v sops >/dev/null 2>&1; then
    print_status "Testing SOPS decryption..."
    if sops --decrypt "$(dirname "$0")/../secrets/git.yaml" >/dev/null 2>&1; then
        print_success "SOPS decryption test successful!"
    else
        print_warning "SOPS test failed. Please verify the age key is correct."
    fi
fi

echo
print_success "Restore complete! Your secrets should now be accessible."