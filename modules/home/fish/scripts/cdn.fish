function cdn --description "Upload, ls or rm files on tiny-cdn"
    set -gx SSH_AUTH_SOCK ~/"Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    set -l base_url (set -q CDN_URL; and echo $CDN_URL; or echo https://cdn.ext.kuipr.de)
    set -l pubkey (set -q CDN_PUBKEY; and echo $CDN_PUBKEY; or echo ~/.ssh/cdn.pub)

    if test "$argv[1]" = get
        if test (count $argv) -lt 2
            echo "usage: cdn get <id>" >&2
            return 2
        end
        curl -fsS "$base_url/$argv[2]?raw=1"
        return
    end

    set -l method
    set -l path
    set -l body /dev/null
    set -l expire -
    set -l encoded_name

    switch "$argv[1]"
        case ''
            echo "usage: cdn <file> [expire_seconds] | cdn ls | cdn get <id> | cdn rm <id>" >&2
            return 2
        case ls
            set method GET
            set path /list
        case rm
            if test (count $argv) -lt 2
                echo "usage: cdn rm <id>" >&2
                return 2
            end
            set method DELETE
            set path /$argv[2]
        case '*'
            if not test -f "$argv[1]"
                echo "cdn: no such file: $argv[1]" >&2
                return 1
            end
            if set -q argv[2]
                if not string match -qr '^\d+$' -- $argv[2]
                    echo "cdn: expire must be a number of seconds: $argv[2]" >&2
                    return 2
                end
                set expire $argv[2]
            end
            set method PUT
            set encoded_name (path basename -- "$argv[1]" | string escape --style=url)
            set path /upload/$encoded_name
            set body $argv[1]
    end

    if not test -e "$pubkey"
        echo "cdn: public key not found: $pubkey (set CDN_PUBKEY)" >&2
        return 1
    end

    set -l timestamp (date +%s)
    set -l nonce (openssl rand -hex 16)
    set -l hash (openssl dgst -sha256 -r $body | string split ' ' -f1)
    set -l signature (printf '%s\n%s\n%s\n%s\n%s\n%s' $method $path $timestamp $nonce $hash $expire | ssh-keygen -q -Y sign -f $pubkey -n cdn-upload - | openssl base64 -A)

    set -l expire_header
    if test "$expire" != -
        set expire_header -H "X-Expire-Seconds: $expire"
    end

    set -l curl_flags -fsS
    set -l progress
    if test "$method" = PUT; and isatty stderr
        set curl_flags -fS
        set progress --progress-bar
        set -l bytes (wc -c <$body | string trim)
        set -l size "$bytes B"
        if test $bytes -ge 1048576
            set size (math -s 1 "$bytes / 1048576")" MiB"
        else if test $bytes -ge 1024
            set size (math -s 1 "$bytes / 1024")" KiB"
        end
        printf '%sUploading %s (%s)%s\n' (set_color brblack) (path basename -- $body) $size (set_color normal) >&2
    end

    set -l response (curl $curl_flags $progress -X $method "$base_url$path" \
        -H "X-Timestamp: $timestamp" \
        -H "X-Nonce: $nonce" \
        -H "X-Content-SHA256: $hash" \
        -H "X-Signature: $signature" \
        $expire_header \
        --data-binary @$body | string collect)

    switch "$method"
        case PUT
            set -l id (printf '%s' $response | jq -r '.id')
            set -l url "$base_url/$id/$encoded_name"
            echo $url
            if isatty stderr
                printf '\e]52;c;%s\a' (printf '%s' $url | openssl base64 -A)
            end
        case GET
            set -l rows (printf '%s' $response | jq -r '.[] | [.id, .name, ((.expires_at - now) | floor)] | @tsv')
            if test (count $rows) -eq 0
                echo "no files"
                return 0
            end
            set -l dim ""
            set -l reset ""
            set -l c_id ""
            if isatty stdout
                set dim (set_color brblack)
                set reset (set_color normal)
                set c_id (set_color cyan)
            end
            set -l cells
            for row in $rows
                set -l fields (string split \t -- $row)
                set -l seconds $fields[3]
                set -l remaining
                if test $seconds -ge 3600
                    set remaining (math "floor($seconds / 3600)")"h "(math "floor($seconds % 3600 / 60)")"m"
                else if test $seconds -ge 60
                    set remaining (math "floor($seconds / 60)")"m "(math "$seconds % 60")"s"
                else
                    set remaining {$seconds}s
                end
                set -l expires_color green
                if test $seconds -lt 60
                    set expires_color red
                else if test $seconds -lt 300
                    set expires_color yellow
                end
                set -l c_exp ""
                if isatty stdout
                    set c_exp (set_color $expires_color)
                end
                set -a cells (printf '%s\t%s\t%s%s%s' $fields[1] (string unescape --style=url -- $fields[2]) $c_exp $remaining $reset)
            end
            set -l table (printf '%s\n' (string join \t ID NAME "EXPIRES IN") $cells | column -t -s \t)
            set -l index 0
            for line in $table
                set index (math $index + 1)
                if test $index -eq 1
                    printf '%s%s%s\n' $dim $line $reset
                    continue
                end
                set -l id (string split -m1 ' ' -- $line)[1]
                printf '%s%s%s%s\n' $c_id $id $reset (string sub -s (math (string length $id) + 1) -- $line)
            end
        case '*'
            echo "$response"
    end
end
