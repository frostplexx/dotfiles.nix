# Remove the greeting message.
set -g fish_greeting

# Manpager
set -x MANPAGER "nvim +Man!"

# Vi mode.
set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore


# Tide config
set -g tide_left_prompt_items "pwd" "git" "newline" "character" 

# Source rex bin dir
if set -q REX_BIN_DIR
    fish_add_path --path --prepend --move $REX_BIN_DIR
end

# GitHub token for tack (and anything else that reads GITHUB_TOKEN). The sops
# secret is decrypted by home-manager, so no token lives in the store.
if status is-interactive
    set -l github_token_file $HOME/.config/sops-nix/secrets/github-token
    if test -r $github_token_file
        set -gx GITHUB_TOKEN (string trim <$github_token_file)
    end
end
