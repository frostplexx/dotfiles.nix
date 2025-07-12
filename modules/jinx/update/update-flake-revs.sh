#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'
# Formatted output prefixes
SUCCESS="${GREEN}${BOLD}[SUCCESS]${RESET}"
ERROR="${RED}${BOLD}[ERROR]${RESET}"
WARN="${YELLOW}${BOLD}[WARN]${RESET}"
INFO="${BLUE}${BOLD}[INFO]${RESET}"

# Check for required dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi

    if ! command -v fd >/dev/null 2>&1; then
        missing_deps+=("fd")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Error: Missing required dependencies:${RESET}"
        printf '%s\n' "${missing_deps[@]}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Store updates in an array
declare -A updates=()
declare -A current_revs=()
declare -A latest_revs=()

# Function to show diff-style changes
show_change() {
    local old="$1"
    local new="$2"
    if [ "$old" != "$new" ]; then
        echo -e "${RED}- ${old}${RESET}"
        echo -e "${GREEN}+ ${new}${RESET}"
    else
        echo "  $old (unchanged)"
    fi
}

# Function to update a single fetchFromGitHub block in a file
update_repo() {
    local file="$1"
    local owner="$2"
    local repo="$3"
    local current_rev="$4"
    local repo_key="${file}:${owner}/${repo}"

    echo -e "${BLUE}Checking ${owner}/${repo} in ${file}${RESET}"

    # Get the latest commit hash
    latest_rev=$(curl -s "https://api.github.com/repos/$owner/$repo/commits/main" | jq -r '.sha')
    echo -e "$latest_rev"

    if [ "$latest_rev" = "$current_rev" ]; then
        echo -e "${GREEN}Already at latest revision${RESET}"
        return 0
    fi

    # Generate the new sha256 using nix-prefetch-url
    # For more info on hashes in nixos refer to: https://nixos.wiki/wiki/Nix_Hash
    url="https://github.com/$owner/$repo/archive/$latest_rev.tar.gz"
    new_sha256=$(nix-prefetch-url --unpack "$url")

    # Convert the sha256 to sri
    new_sha256_base64=$(nix-hash --type sha256 --to-sri "$new_sha256")

    echo "Current revision: $current_rev"
    echo "Latest revision:  $latest_rev"
    echo "New SHA256 (base64): $new_sha256_base64"

    # Create a backup of the file
    cp "$file" "${file}.bak"

    # Handle both hash and sha256 attributes
    if grep -q "hash =" "$file"; then
        hash_attr="hash"
    else
        hash_attr="sha256"
    fi

    # Update the file
    # First, update the rev that matches with the current owner/repo combo
    awk -v owner="$owner" -v repo="$repo" -v old_rev="$current_rev" -v new_rev="$latest_rev" '
    {
        if ($0 ~ "owner = \"" owner "\"") {
            owner_found = 1
        } else if (owner_found && $0 ~ "repo = \"" repo "\"") {
            repo_found = 1
        } else if (owner_found && repo_found && $0 ~ "rev = \"" old_rev "\"") {
            sub(old_rev, new_rev)
            owner_found = 0
            repo_found = 0
        }
        print
    }' "${file}.bak" > "$file"

    # Then update the corresponding sha256 using awk
    echo -e "Updating Hash..."

    # Update the hash that corresponds to this owner/repo combo
    awk -v owner="$owner" -v repo="$repo" -v new_hash="$new_sha256_base64" -v hash_attr="$hash_attr" '
    {
        if ($0 ~ "owner = \"" owner "\"") {
            owner_found = 1
            print
            next
        }
        if (owner_found && $0 ~ "repo = \"" repo "\"") {
            repo_found = 1
            print
            next
        }
        if (owner_found && repo_found && $0 ~ hash_attr " = ") {
            sub(/"[^"]*"/, "\"" new_hash "\"")
            owner_found = 0
            repo_found = 0
        }
        print
    }' "${file}" > "${file}.tmp" && mv "${file}.tmp" "$file"

    # Remove backup if everything went well
    rm -f "${file}.bak"

    echo -e "${GREEN}Successfully updated ${owner}/${repo}${RESET}"
}

# Function to extract value from a line
extract_value() {
    echo "$1" | sed -n 's/.*"\([^"]*\)".*/\1/p'
}

# Function to find and process fetchFromGitHub blocks
find_and_update_repos() {
    local dir="${1:-.}"

    # Find all Nix files recursively using fd
    fd --extension nix . "$dir" | while read -r file; do
        echo -e "${BLUE}Scanning ${file}${RESET}"

        # Process the file line by line to find fetchFromGitHub blocks
        {
            in_block=0
            owner=""
            repo=""
            rev=""
            while IFS= read -r line; do
                if echo "$line" | grep -q "fetchFromGitHub"; then
                    in_block=1
                    owner=""
                    repo=""
                    rev=""
                elif [ $in_block -eq 1 ]; then
                    if echo "$line" | grep -q "owner ="; then
                        owner=$(extract_value "$line")
                    elif echo "$line" | grep -q "repo ="; then
                        repo=$(extract_value "$line")
                    elif echo "$line" | grep -q "rev ="; then
                        rev=$(extract_value "$line")
                    elif echo "$line" | grep -q "};"; then
                        if [ -n "$owner" ] && [ -n "$repo" ] && [ -n "$rev" ]; then
                            echo "${owner}|${repo}|${rev}"
                        fi
                        in_block=0
                    fi
                fi
            done < "$file"
        } | while IFS='|' read -r owner repo rev; do
            if [ -n "$owner" ] && [ -n "$repo" ] && [ -n "$rev" ]; then
                update_repo "$file" "$owner" "$repo" "$rev"
            fi
        done
    done
}

# Main script
check_dependencies

echo -e "${BLUE}Checking for available updates...${RESET}"

find_and_update_repos "${1:-.}"

echo -e "${GREEN}Done updating all repositories${RESET}"
