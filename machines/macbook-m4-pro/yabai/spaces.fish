#!/usr/bin/env fish

set -l MAX_SPACES 6


# get number of spaces (jq returns an array; count returns number of items)
set -l SPACES_CNT (yabai -m query --spaces | jq '.[].index' | wc -l | tr -d ' ')

# compute how many to add using fish math
set -l NR_SPACES_TO_ADD (math "$MAX_SPACES - $SPACES_CNT")

# numeric comparison in fish
if test $NR_SPACES_TO_ADD -le 0
    echo "No spaces to add"
    exit 0
else 
    sudo yabai --load-sa
end

for i in (seq $NR_SPACES_TO_ADD)
    echo "Adding space $i of $NR_SPACES_TO_ADD"
    yabai -m space --create
end

