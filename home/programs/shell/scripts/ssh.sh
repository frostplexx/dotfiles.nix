#!/usr/bin/env bash
# Helper function to get 1Password SSH password
get_ssh_password() {
  local host=$1
  # Remove both 'setenv' and 'ONEPASSWORD_ITEM=' prefixes
  local op_item=$(ssh -G "$host" | grep "^setenv ONEPASSWORD_ITEM" | sed 's/^setenv ONEPASSWORD_ITEM=//')
  local password=$(op item get "$op_item" --format json 2>/dev/null | jq -r '.fields[] | select(.label == "password") .value | select(. != null) | values' | head -n1)
  # if password is empty, run notify kitten and return empty string
  if [[ -z $password ]]; then
    kitten notify "No password found for $host"
  fi
  echo "$password"
}

if [[ $# -eq 0 ]]; then
  local selected_host=$(cat ~/.ssh/config ~/.orbstack/ssh/config 2>/dev/null | grep "^Host " | cut -d ' ' -f 2- | tr ' ' '\n' | grep -v '^*$' | sort -u | fzf --height 40% --reverse)
  if [[ -n $selected_host ]]; then
    local password=$(get_ssh_password "$selected_host")
    if [[ -n $password ]]; then
      echo "Connecting to $selected_host..."
      sshpass -p "$password" kitten ssh "$selected_host"
    else
      kitten ssh "$selected_host"
    fi
  fi
else
  password=$(get_ssh_password "$1")
  if [[ -n $password ]]; then
    echo "Connecting to $1..."
    sshpass -p "$password" kitten ssh "$@"
  else
    kitten ssh "$@"
  fi
fi
