function wtfis
    # Find the path to nix-base for the sops.yaml file
    set nix_base_path "$HOME/dotfiles.nix"

    if test $status -ne 0
        echo "Error: Could not find nix-base repository: $nix_base_path" >&2
        return 1
    end

    # Decrypt the file temporarily
    opsops read "/Users/daniel/dotfiles.nix/home/shell/wtfis.env" --sops-file $nix_base_path/.sops.yaml >$HOME/.env.wtfis 2>/dev/null
    set decrypt_status $status

    # Set up cleanup to happen in any case
    function cleanup
        rm -f $HOME/.env.wtfis
    end

    # Only run wtfis if decryption succeeded
    if test $decrypt_status -eq 0
        # Run wtfis with all original arguments
        command wtfis $argv
        set wtfis_status $status
    else
        echo "Error: Failed to decrypt .wtfis.env file" >&2
        set wtfis_status 1
    end

    # Clean up regardless of outcome
    cleanup

    # Return the original status code
    return $wtfis_status
end
