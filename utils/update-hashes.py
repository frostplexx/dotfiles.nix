#!/usr/bin/env python3

import os
import re
import json
import subprocess
import sys
import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
import tempfile

@dataclass
class FetchBlock:
    start: int
    end: int
    type: str
    url: Optional[str] = None
    owner: Optional[str] = None
    repo: Optional[str] = None
    rev: Optional[str] = None
    current_hash: Optional[str] = None
    hash_type: Optional[str] = None  # 'sha256' or 'hash'
    hash_format: Optional[str] = None  # 'base32' or 'sri'

class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


class NixHashUpdater:
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
        self.stats = {
            'processed_files': 0,
            'updated_files': 0,
            'errors': 0,
            'skipped': 0
        }

        # Regex patterns for different fetch types
        self.patterns = {
            'fetchurl': r'fetchurl\s*{([^}]*)}',
            'fetchFromGitHub': r'fetchFromGitHub\s*{([^}]*)}',
            'builtins.fetchurl': r'builtins\.fetchurl\s*{([^}]*)}'
        }

        # Patterns for hash and URL extraction
        self.hash_patterns = [
            r'sha256\s*=\s*"([^"]*)"',
            r'hash\s*=\s*"sha256-([^"]*)"',
            r'hash\s*=\s*"([^"]*)"'
        ]
        self.url_pattern = r'url\s*=\s*"([^"]*)"'
        self.github_patterns = {
            'owner': r'owner\s*=\s*"([^"]*)"',
            'repo': r'repo\s*=\s*"([^"]*)"',
            'rev': r'rev\s*=\s*"([^"]*)"'
        }

    def log_status(self, message: str, color: str = Colors.BLUE, indent: int = 0):
        """Log a status message with color and indentation."""
        if self.verbose:
            indent_str = "  " * indent
            print(f"{indent_str}{color}{message}{Colors.ENDC}")

    def log_error(self, message: str, indent: int = 0):
        """Log an error message."""
        self.stats['errors'] += 1
        self.log_status(f"Error: {message}", Colors.RED, indent)

    def log_update(self, old_value: str, new_value: str, indent: int = 0):
        """Log an update with old and new values."""
        self.log_status("└─ Updated:", Colors.GREEN, indent)
        self.log_status(f"  - Old: {old_value}", Colors.YELLOW, indent + 1)
        self.log_status(f"  - New: {new_value}", Colors.GREEN, indent + 1)

    def detect_hash_format(self, hash_str: str) -> str:
        """Detect if a hash is in base32 or SRI format."""
        if hash_str.startswith('sha256-'):
            return 'sri'
        return 'base32'

    def convert_hash(self, hash_str: str, to_format: str) -> str:
        """Convert between base32 and SRI hash formats."""
        current_format = self.detect_hash_format(hash_str)
        if current_format == to_format:
            return hash_str

        if to_format == 'sri':
            # Convert base32 to SRI
            result = subprocess.run(
                ['nix', 'hash', 'convert', '--hash-algo', 'sha256', '--to', 'sri', hash_str],
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout.strip()
        else:
            # Convert SRI to base32
            result = subprocess.run(
                ['nix', 'hash', 'convert', '--hash-algo', 'sha256', '--to', 'base32', hash_str],
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout.strip()

    def should_unpack(self, url: str) -> bool:
        """Determine if a URL should be unpacked based on its extension or format."""
        archive_extensions = ('.tar.gz', '.tgz', '.tar.bz2', '.zip', '.tar.xz')
        is_github_archive = 'github.com' in url and '/archive/' in url
        return url.endswith(archive_extensions) or is_github_archive

    def get_new_hash(self, url: str) -> Tuple[str, str]:
        """Get both base32 and SRI format hashes for a URL."""
        cmd = ['nix-prefetch-url']
        if self.should_unpack(url):
            cmd.append('--unpack')
        cmd.append(url)

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            base32_hash = result.stdout.strip()

            # Convert to SRI format
            sri_hash = self.convert_hash(base32_hash, 'sri')
            return base32_hash, sri_hash
        except subprocess.CalledProcessError as e:
            print(f"Error fetching URL {url}: {e}")
            print(f"Error output: {e.stderr}")
            raise

    def get_latest_github_rev(self, owner: str, repo: str, branch: str = 'main') -> Optional[str]:
        """Get the latest commit hash from GitHub for a specific branch."""
        try:
            print(f'https://api.github.com/repos/{owner}/{repo}/commits/{branch}')
            result = subprocess.run(
                ['curl', '-s',
                 f'https://api.github.com/repos/{owner}/{repo}/commits/{branch}'],
                capture_output=True,
                text=True,
                check=True
            )
            data = json.loads(result.stdout)
            return data.get('sha')
        except subprocess.CalledProcessError as e:
            self.log_status(f"  Failed to check branch {branch}: subprocess error: {e}", Colors.YELLOW, 2)
            self.log_status(f"  Stderr: {e.stderr}", Colors.YELLOW, 2)  # Log stderr for subprocess errors
            return None
        except json.JSONDecodeError as e:
            self.log_status(f"  Failed to check branch {branch}: JSON decode error: {e}", Colors.YELLOW, 2)
            self.log_status(f"  Stdout: {result.stdout if 'result' in locals() else 'No stdout because subprocess failed'}", Colors.YELLOW, 2) # Log stdout if available
            return None

    def parse_fetch_block(self, block: str, block_type: str) -> FetchBlock:
        """Parse a fetch block to extract relevant information."""
        fetch_block = FetchBlock(start=0, end=0, type=block_type)

        # Extract hash information
        empty_hash_patterns = [
            r'sha256\s*=\s*"[0-9a-z]{52}"',  # Empty base32
            r'sha256\s*=\s*""',  # Empty string
            r'hash\s*=\s*"sha256-[A-Za-z0-9+/]{44}="',  # Empty SRI
            r'hash\s*=\s*""',  # Empty string
            r'hash\s*=\s*lib\.fakeSha256',  # fakeSha256
            r'hash\s*=\s*pkgs\.lib\.fakeSha256',  # pkgs.lib.fakeSha256
            r'sha256\s*=\s*lib\.fakeSha256',  # lib.fakeSha256 with sha256
        ]

        is_empty_hash = any(re.search(pattern, block) for pattern in empty_hash_patterns)

        for pattern in self.hash_patterns:
            match = re.search(pattern, block)
            if match:
                hash_value = match.group(1)
                fetch_block.current_hash = hash_value if not is_empty_hash else None
                fetch_block.hash_type = 'sha256' if 'sha256' in pattern else 'hash'
                fetch_block.hash_format = self.detect_hash_format(hash_value) if not is_empty_hash else 'sri'
                break

        # If no hash pattern found, look for lib.fakeSha256 variants
        if not fetch_block.hash_type:
            if re.search(r'(lib|pkgs\.lib)\.fakeSha256', block):
                fetch_block.hash_type = 'hash'
                fetch_block.current_hash = None
                fetch_block.hash_format = 'sri'

        if block_type == 'fetchFromGitHub':
            # Parse GitHub-specific information
            for key, pattern in self.github_patterns.items():
                match = re.search(pattern, block)
                if match:
                    setattr(fetch_block, key, match.group(1))
        else:
            # Parse URL for other fetch types
            url_match = re.search(self.url_pattern, block)
            if url_match:
                fetch_block.url = url_match.group(1)

        return fetch_block

    def update_file(self, filepath: str) -> None:
        """Update hashes in a Nix file."""
        print(f"Processing {filepath}")
        updated_file = False

        with open(filepath, 'r') as f:
            content = f.read()

        # Find all fetch blocks
        modified = content
        for fetch_type, pattern in self.patterns.items():
            for match in re.finditer(pattern, content):
                try:
                    block = match.group(1)
                    fetch_info = self.parse_fetch_block(block, fetch_type)

                    if fetch_type == 'fetchFromGitHub':
                        if not all([fetch_info.owner, fetch_info.repo]):
                            continue

                        # Get latest revision from main branch
                        latest_rev = self.get_latest_github_rev(fetch_info.owner, fetch_info.repo, 'main')
                        if not latest_rev:
                            self.log_error(f"Could not fetch latest revision for GitHub repo: {fetch_info.owner}/{fetch_info.repo}", indent=1)
                            continue

                        current_rev = fetch_info.rev
                        if current_rev != latest_rev:
                            self.log_status(f"└─ GitHub repo update needed for {fetch_info.owner}/{fetch_info.repo}", Colors.CYAN, 1)
                            self.log_status(f"  - Current rev: {current_rev if current_rev else 'None'}", Colors.YELLOW, 2)
                            self.log_status(f"  - Latest rev: {latest_rev}", Colors.GREEN, 2)

                            # Get new hash for updated revision
                            url = f"https://github.com/{fetch_info.owner}/{fetch_info.repo}/archive/{latest_rev}.tar.gz"
                            base32_hash, sri_hash = self.get_new_hash(url)
                            new_hash = sri_hash if fetch_info.hash_format == 'sri' else base32_hash

                            block_pattern = re.escape(block)
                            new_block = block

                            # Update rev, add rev if it was missing
                            if current_rev:
                                new_block = re.sub(r'rev\s*=\s*"[^"]*"', f'rev = "{latest_rev}"', new_block)
                            else:
                                # Insert rev after repo = "..."
                                new_block = re.sub(r'(repo\s*=\s*"[^"]*")', rf'\1,\n    rev = "{latest_rev}"', new_block)

                            # Update hash
                            new_block = re.sub(
                                f'{fetch_info.hash_type}\\s*=\\s*"[^"]*"',
                                f'{fetch_info.hash_type} = "{new_hash}"',
                                new_block
                            )
                            if new_block != block:
                                modified = re.sub(block_pattern, new_block, modified)
                                updated_file = True
                                self.log_update(block, new_block, 1)


                    else: # fetchurl and builtins.fetchurl
                        if not fetch_info.url:
                            continue
                        # Allow empty hashes to proceed

                        # Get new hash for URL
                        base32_hash, sri_hash = self.get_new_hash(fetch_info.url)
                        new_hash = sri_hash if fetch_info.hash_format == 'sri' else base32_hash

                        # Update hash
                        block_pattern = re.escape(block)
                        new_block = re.sub(
                            f'{fetch_info.hash_type}\\s*=\\s*"[^"]*"',
                            f'{fetch_info.hash_type} = "{new_hash}"',
                            block
                        )
                        if new_block != block:
                            modified = re.sub(block_pattern, new_block, modified)
                            updated_file = True
                            self.log_update(block, new_block, 1)


                except Exception as e:
                    print(f"Error processing block in {filepath}: {e}")
                    continue

        # Write changes if modified
        if updated_file:
            with open(filepath, 'w') as f:
                f.write(modified)
            print(f"Updated {filepath}")
            self.stats['updated_files'] += 1
        else:
            print(f"No updates for {filepath}")
            self.stats['skipped'] += 1
        self.stats['processed_files'] += 1


def main():
    updater = NixHashUpdater()

    # Process all .nix files in current directory and subdirectories
    for root, _, files in os.walk('.'):
        for file in files:
            if file.endswith('.nix'):
                filepath = os.path.join(root, file)
                try:
                    updater.update_file(filepath)
                except Exception as e:
                    print(f"Error processing {filepath}: {e}")

    print("\n--- Summary ---")
    print(f"Processed files: {updater.stats['processed_files']}")
    print(f"Updated files: {updater.stats['updated_files']}")
    print(f"Skipped files: {updater.stats['skipped']}")
    print(f"Errors: {updater.stats['errors']}")


if __name__ == '__main__':
    main()