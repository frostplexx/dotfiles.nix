#!/usr/bin/env bash

# Function to get 1Password item details by ID
get_item_details() {
  local item_id="$1"
  op item get "$item_id" --format json
}

# Function to extract item field value
get_field_value() {
  local item_details="$1"
  local field_label="$2"
  echo "$item_details" | jq -r --arg label "$field_label" '.fields[] | select(.label == $label) .value | select(. != null) | values' | head -n1
}

# Function to perform SSH connection
perform_ssh_connection() {
  local item_id="$1"
  
  local item_details=$(get_item_details "$item_id")
  if [[ -z "$item_details" ]]; then
    echo -e "\033[1;31m✘ Error: Could not retrieve item details\033[0m"
    return 1
  fi
  
  # Extract connection details
  local hostname=$(get_field_value "$item_details" "hostname")
  local username=$(get_field_value "$item_details" "username")
  local password=$(get_field_value "$item_details" "password")
  
  # Fallback to title if hostname is missing
  if [[ -z "$hostname" ]]; then
    hostname=$(echo "$item_details" | jq -r '.title')
  fi
  
  # Validate required fields
  if [[ -z "$hostname" ]]; then
    echo -e "\033[1;31m✘ Error: Hostname not found\033[0m"
    return 1
  fi
  
  if [[ -z "$username" ]]; then
    echo -e "\033[1;31m✘ Error: Username not found\033[0m"
    return 1
  fi
  
  clear
  printf "Connecting to \033[1;33m$username\033[0m@\033[1;34m$hostname\033[0m"
  
  
  if [[ -n "$password" ]]; then
    # Use sshpass for password-based auth
    sshpass -p "$password" ssh -l "$username" "$hostname" -t
  else
    # No password, regular SSH with forced tty allocation
    echo "Running test"
    ssh -t -l "$username" "$hostname"
  fi
  
  ssh_status=$?
  
  if [[ $ssh_status -ne 0 ]]; then
    echo -e "\033[1;31m✘ Connection failed (exit code: $ssh_status)\033[0m"
    return 1
  fi
}

# Main execution
main() {
  if [[ $# -eq 0 ]]; then
    # Create a temporary file for the preview script
    preview_script=$(mktemp)
    
    # Write the preview function to the temp file
    cat > "$preview_script" << 'EOF'
#!/usr/bin/env bash
input="$1"
item_id=$(echo "$input" | cut -f2)
item_details=$(op item get "$item_id" --format json)
if [[ -z "$item_details" ]]; then
  echo -e "\033[1;31mError retrieving item details\033[0m"
  exit 1
fi
hostname=$(echo "$item_details" | jq -r '.fields[] | select(.label == "hostname") .value | select(. != null) | values' | head -n1)
username=$(echo "$item_details" | jq -r '.fields[] | select(.label == "username") .value | select(. != null) | values' | head -n1)
if [[ -z "$hostname" ]]; then
  hostname=$(echo "$item_details" | jq -r '.title')
fi
echo -e "\n\033[1;36m 󰣀 User:\033[0m \033[1;33m${username:-N/A}\033[0m"
echo -e "\033[1;36m 󰖟 Host:\033[0m \033[1;32m${hostname:-N/A}\033[0m\n"
EOF
    
    # Make the script executable
    chmod +x "$preview_script"
    
    # Get all items with ssh tag and use fzf for selection
    selected_entry=$(op item list --tags ssh --format json | \
      jq -r '.[] | [.title, .id] | @tsv' | \
      fzf --height 40% \
        --layout reverse \
        --with-nth=1 \
        --border-label=" 󰒋 SSH " \
        --color=label:bold:blue \
        --prompt="Fetching from 1Password..." \
        --bind 'load:change-prompt: ' \
        --border \
        --preview="$preview_script {}" \
        --delimiter=$'\t')
    
    # Clean up the temp file
    rm -f "$preview_script"
    
    # Process selection
    if [[ -n "$selected_entry" ]]; then
      item_id=$(echo "$selected_entry" | cut -f2)
      perform_ssh_connection "$item_id"
    fi
  else
    # If arguments provided, use traditional SSH
    ssh "$@"
  fi
}

# Trap to clean up on exit
trap 'rm -f "$preview_script" 2>/dev/null || true' EXIT

# Execute main function
main "$@"
