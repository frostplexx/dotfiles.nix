#!/usr/bin/env fish

set url $argv[1]
set root $argv[2]

# Normalise all URL formats to host/path form:
#   https://github.com/user/repo.git   -> github.com/user/repo
#   http://github.com/user/repo        -> github.com/user/repo
#   ssh://git@github.com/user/repo.git -> github.com/user/repo
#   git://github.com/user/repo.git     -> github.com/user/repo
#   git@github.com:user/repo.git       -> github.com/user/repo  (SCP style)

set path $url

# Strip protocol schemes (https://, http://, ssh://, git://)
set path (string replace -r '^[a-zA-Z]+://' '' $path)

# Strip user info (e.g. git@)
set path (string replace -r '^[^@]+@' '' $path)

# Replace SCP-style colon separator with a slash (github.com:user/repo)
set path (string replace -r '^([^/:]+):' '$1/' $path)

# Strip trailing .git
set path (string replace -r '\.git$' '' $path)

set dest "$root/$path"

echo -e "\033[34m\033[0m  Cloning \033[1m$url\033[0m"
echo -e "\033[2m  into $dest\033[0m"
echo ""

mkdir -p $dest
and git clone $url $dest
and echo ""
and echo -e "\033[32m\033[0m  Done"
or begin
    echo ""
    echo -e "\033[31m\033[0m  Clone failed"
    exit 1
end
