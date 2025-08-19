#!/usr/bin/env fish

set -g ssh_hosts_file ~/.ssh/hosts

function _create_hosts_file -a name url port
    set_color cyan
    echo -n "  Processing: "
    set_color yellow
    echo -n "$name"
    set_color normal

    # Remove ssh:// prefix
    set -l cleaned (string replace -r '^ssh://' '' $url)

    # Split into user and hostname
    set -l user_host (string split '@' $cleaned)
    set -l user $user_host[1]
    set -l host_port $user_host[2]

    # Check if port is embedded in hostname (host:port format)
    set -l host_parts (string split ':' $host_port)
    set -l host $host_parts[1]

    # Use embedded port if present, otherwise use provided port parameter
    if test (count $host_parts) -gt 1
        set port $host_parts[2]
        set_color blue
        echo -n " (port from URL: $port)"
        set_color normal
    else if test -n "$port"
        set_color blue
        echo -n " (port from field: $port)"
        set_color normal
    end

    echo "Host $name" >>$ssh_hosts_file
    echo "    HostName \"$host\"" >>$ssh_hosts_file
    echo "    User $user" >>$ssh_hosts_file

    # Add port configuration if it's not the default SSH port (22)
    if test -n "$port" -a "$port" != 22
        echo "    Port $port" >>$ssh_hosts_file
        set_color normal
    end

    echo ""

    echo "" >>$ssh_hosts_file
end

function generate_ssh_hosts
    set_color magenta
    echo " Searching for SSH hosts in 1Password..."
    set_color normal

    set -l items (op item list --tags ssh --format json | jq -r '.[] | @base64')
    set -l item_count (count $items)

    set_color cyan
    echo "󰈞 Found $item_count SSH items"
    set_color normal

    # Clear previous content
    echo -n "" >$ssh_hosts_file
    set_color yellow
    echo "  Clearing previous SSH hosts file: $ssh_hosts_file"
    set_color normal

    set_color green
    echo " Generating SSH host configurations..."
    set_color normal

    for item in $items
        set -l _item (echo $item | base64 --decode | jq -r '.id, .title')
        set -l id $_item[1]
        set -l name $_item[2]

        # Try to get URL field (check "url", "Url", and "URL" labels)
        set -l url (op item get $id --fields label=url 2>/dev/null)
        if test -z "$url"
            set url (op item get $id --fields label=Url 2>/dev/null)
        end
        if test -z "$url"
            set url (op item get $id --fields label=URL 2>/dev/null)
        end

        # Try to get port field with more variations and debug output
        set -l port ""
        set -l port_variants port Port PORT ssh_port SSH_Port SSH_PORT

        for variant in $port_variants
            set port (op item get $id --fields label=$variant 2>/dev/null)
            if test -n "$port"
                break
            end
        end

        # If still no port found, try getting all fields and grep for port-related ones
        if test -z "$port"
            set -l all_fields (op item get $id --format json 2>/dev/null | jq -r '.fields[]? | select(.label | test("(?i)port")) | .value' 2>/dev/null)
            if test -n "$all_fields"
                set port $all_fields[1]
            end
        end

        _create_hosts_file $name $url $port
    end

    set_color green
    echo " Done! SSH hosts file generated at: $ssh_hosts_file"
    set_color normal
end

generate_ssh_hosts
