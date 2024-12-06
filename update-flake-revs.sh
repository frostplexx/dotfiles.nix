#!/usr/bin/env bash

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Store updates in an array
declare -A updates=()
declare -A current_revs=()
declare -A latest_revs=()

# Function to show diff-style changes
show_change() {
    local old="$1"
    local new="$2"
    if [ "$old" != "$new" ]; then
        echo -e "${RED}- ${old}${NC}"
        echo -e "${GREEN}+ ${new}${NC}"
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
    
    echo -e "${BLUE}Checking ${owner}/${repo} in ${file}${NC}"
    
    # Get the latest commit hash
    latest_rev=$(curl -s "https://api.github.com/repos/$owner/$repo/commits/main" | jq -r '.sha')
    echo -e "$latest_rev"
    
    if [ "$latest_rev" = "$current_rev" ]; then
        echo -e "${GREEN}Already at latest revision${NC}"
        return 0
    fi
    
    # Generate the new sha256 using nix-prefetch-url
    url="https://github.com/$owner/$repo/archive/$latest_rev.tar.gz"
    new_sha256=$(nix-prefetch-url --unpack "$url")


    echo "New SHA256: $new_sha256 "
    
    # Convert the sha256 to base64
    new_sha256_base64=$(nix hash convert --hash-algo sha256 --to sri "$new_sha256")
    
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
    
    echo -e "${GREEN}Successfully updated ${owner}/${repo}${NC}"
}

# Function to extract value from a line
extract_value() {
    echo "$1" | sed -n 's/.*"\([^"]*\)".*/\1/p'
}

# Function to find and process fetchFromGitHub blocks
find_and_update_repos() {
    local dir="${1:-.}"
    
    # Find all Nix files recursively
    find "$dir" -type f -name "*.nix" | while read -r file; do
        echo -e "${BLUE}Scanning ${file}${NC}"
        
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
echo -e "${BLUE}Checking for available updates...${NC}"

find_and_update_repos "${1:-.}"

echo -e "${GREEN}Done updating all repositories${NC}"
