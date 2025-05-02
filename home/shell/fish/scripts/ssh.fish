#!/usr/bin/env fish


set -g ssh_hosts_file ~/.ssh/hosts

function _create_hosts_file -a name url
    # Remove ssh:// prefix
    set -l cleaned (string replace -r '^ssh://' '' $url)

    # Split into user and hostname
    set -l user_host (string split '@' $cleaned)
    set -l user $user_host[1]
    set -l host $user_host[2]

    echo "Host $name" >> $ssh_hosts_file
    echo "    HostName \"$host\"" >> $ssh_hosts_file
    echo "    User $user" >> $ssh_hosts_file
    echo "" >> $ssh_hosts_file
end

function generate_ssh_hosts
    set -l items (op item list --tags ssh --format json | jq -r '.[] | @base64')

    # Clear previous content
    echo -n "" > $ssh_hosts_file
    
    for item in $items
        set -l _item (echo $item | base64 --decode | jq -r '.id, .title')
        set -l id $_item[1]
        set -l name $_item[2]
        set -l url (op item get $id --fields label=url)
        _create_hosts_file $name $url
    end
end
