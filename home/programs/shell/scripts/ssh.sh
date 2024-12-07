#!/usr/bin/env bash
if [[ $# -eq 0 ]]; then
  # Get all items with ssh tag and format them for fzf
  selected_entry=$(op item list --tags ssh --format json | \
    jq -r '.[] | [.title, .id] | @tsv' | \
    fzf --height 40% --reverse --with-nth=1 --delimiter=$'\t')

  if [[ -n $selected_entry ]]; then
    # Extract the item ID using tab as delimiter
    item_id=$(echo "$selected_entry" | cut -f2)

    # Get full item details
    item_details=$(op item get "$item_id" --format json)

    # Extract hostname, username, and password
    hostname=$(echo "$item_details" | jq -r '.fields[] | select(.label == "hostname") .value | select(. != null) | values' | head -n1)
    username=$(echo "$item_details" | jq -r '.fields[] | select(.label == "username") .value | select(. != null) | values' | head -n1)
    password=$(echo "$item_details" | jq -r '.fields[] | select(.label == "password") .value | select(. != null) | values' | head -n1)

    if [[ -z $hostname ]]; then
      # If no hostname field, use the title as hostname
      hostname=$(echo "$item_details" | jq -r '.title')
    fi

    if [[ -n $password ]]; then
      clear
      echo "Connecting to $hostname as $username..."
      sshpass -p "$password" ssh -l "$username" "$hostname"
    else
      ssh -l "$username" "$hostname"
    fi
  fi
else
  # If arguments provided, use traditional SSH
  ssh "$@"
fi
