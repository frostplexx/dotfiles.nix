#!/usr/bin/env fish
set -g ssh_hosts_file ~/.ssh/hosts
set -g hosts (op item list --tags ssh --format json | op item get - --format json | jq -s '.')

# Delete the old ssh hosts file 
if test -f $ssh_hosts_file
    rm $ssh_hosts_file
end

for host in (echo $hosts | jq -c '.[]')
    set -l name (echo $host | jq -r '.title')
    set -l ssh_url (echo $host | jq -r '.fields[] | select(.label == "url") | .value')
    set -l ssh_port (echo $host | jq -r '.fields[] | select(.label == "port") | .value')
    set -l public_key (echo $host | jq -r '.fields[] | select(.id == "public_key") | .value')

    set -l extra_settings (echo $host | jq -r '.fields[] | select(.section.label == "extra settings") | "\(.label) \(.value)"')

    if test -z "$ssh_port"
        set ssh_port 22
    end

    set -l url_stripped (string replace 'ssh://' '' $ssh_url)
    set -l user (string split '@' $url_stripped)[1]
    set -l host (string split '@' $url_stripped)[2]

    echo -e (set_color --bold cyan)"━━━ "(set_color yellow)"$name"(set_color normal)
    echo (set_color blue)"  url  "(set_color normal)"$user"(set_color brblack)"@"(set_color normal)"$host"(set_color brblack)":$ssh_port"(set_color normal)

    # Check if the .pub key file exists, if not create it
    set -l public_key_file ~/.ssh/$name.pub
    if test -n "$public_key"
        if not test -f $public_key_file
            echo (set_color green)"  ✓ creating "(set_color normal)"$public_key_file"
            echo $public_key >$public_key_file
        else
            echo (set_color blue)"  key  "(set_color normal)"$public_key_file"
        end
    end

    # Add the host to the ssh config file
    echo "Host $name" >>$ssh_hosts_file
    echo "    HostName $host" >>$ssh_hosts_file
    echo "    User $user" >>$ssh_hosts_file
    echo "    Port $ssh_port" >>$ssh_hosts_file
    echo "    SetEnv TERM=xterm-256color" >>$ssh_hosts_file
    echo "    SendEnv COLORTERM TERM_PROGRAM TERM_PROGRAM_VERSION" >>$ssh_hosts_file
    if test -f $public_key_file
        echo "    IdentityFile $public_key_file" >>$ssh_hosts_file
    end
    echo "    IdentitiesOnly yes" >>$ssh_hosts_file
    for setting in $extra_settings
        echo "    $setting" >>$ssh_hosts_file
    end
    echo "" >>$ssh_hosts_file
end
