#!/usr/bin/env bash

# Age Key Backup Script
# This script creates an encrypted backup of your age key for cloud storage

set -e

AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
BACKUP_DIR="$HOME/age-key-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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

# Check if age key exists
if [ ! -f "$AGE_KEY_FILE" ]; then
    print_error "Age key file not found at $AGE_KEY_FILE"
    echo "Please ensure your age key is set up first."
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Generate a random password for encryption
BACKUP_PASSWORD=$(openssl rand -base64 32)
BACKUP_FILE="$BACKUP_DIR/age-key-backup_$TIMESTAMP.enc"

print_status "Creating encrypted backup of age key..."

# Create encrypted backup
echo "$BACKUP_PASSWORD" | openssl enc -aes-256-cbc -salt -in "$AGE_KEY_FILE" -out "$BACKUP_FILE" -pass stdin

print_success "Encrypted backup created: $BACKUP_FILE"

# Display instructions
echo
echo "=================================================================="
echo "BACKUP CREATED SUCCESSFULLY!"
echo "=================================================================="
echo
echo "Backup file: $BACKUP_FILE"
echo "Encryption password: $BACKUP_PASSWORD"
echo
echo "IMPORTANT: Store these TWO items separately:"
echo "1. Upload the backup file ($BACKUP_FILE) to cloud storage"
echo "   (Google Drive, Dropbox, iCloud, etc.)"
echo "2. Store the password in a DIFFERENT secure location:"
echo "   - Different password manager"
echo "   - Physical paper/metal backup"
echo "   - Family member"
echo "   - Safe deposit box"
echo
echo "To restore: ./scripts/restore-age-key.sh"
echo
echo "=================================================================="
echo "NEVER store the password and file together!"
echo "=================================================================="