source ~/dotfiles.nix/home/shell/p10k.zsh
# Edit line in vim with ctrl-e:
export KEYTIMEOUT=1

# Set nvim as manpager
export MANPAGER='nvim +Man!'
export MANPATH="/opt/local/man:/usr/local/man:$MANPATH"

export PATH="/Users/daniel/.local/bin:$PATH"

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Set nvim as manpager
export MANPAGER='nvim +Man!'

# Change cursor shape for different vi modes.
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] ||
        [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
elif [[ ${KEYMAP} == main ]] ||
    [[ ${KEYMAP} == viins ]] ||
    [[ ${KEYMAP} = '' ]] ||
    [[ $1 = 'beam' ]]; then
echo -ne '\e[5 q'
    fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Prompt for spelling correction of commands.
setopt CORRECT
setopt CORRECT_ALL
# Customize spelling correction prompt.
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [Nyae]? '

bindkey -M menuselect '^M' .accept-line # run code when selected completion
