#!/usr/bin/env fish


set name $argv[1] 
set root $argv[2]


set dest "$root/$name"

mkdir -p $dest

tag --set "Project" $dest

echo -e "\033[34m\033[0m  Created \033[1m$dest\033[0m"


git init $dest
