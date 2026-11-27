#!/usr/bin/env fish

# Render flake.lock as a tree of locked inputs.
# Shows the date, revision and source of each input, its nested inputs,
# and the inputs it follows. Read only: never writes flake.lock.

set -g RED (set_color red)
set -g CYAN (set_color cyan)
set -g BOLD (set_color --bold)
set -g DIM (set_color --dim)
set -g RESET (set_color normal)

set -g MAX_DEPTH 16

function usage
    echo "$BOLD""Usage:$RESET "(status basename)" [DIRECTORY]"
    echo
    echo "Print the flake.lock graph as a tree."
    echo
    echo "$BOLD""Arguments:$RESET"
    echo "  DIRECTORY   Path to the flake $DIM(default: current directory)$RESET"
end

argparse h/help -- $argv
or begin
    usage
    exit 1
end

set -q _flag_help; and begin
    usage
    exit 0
end

set -l DOTFILES (pwd)
if test (count $argv) -gt 0
    set DOTFILES $argv[1]
end

set -l LOCK "$DOTFILES/flake.lock"
if not test -f "$LOCK"
    echo "$RED error $RESET flake.lock not found in $DOTFILES" >&2
    exit 1
end

if not command -q jq
    echo "$RED error $RESET jq is required" >&2
    exit 1
end

# ── Load the lock graph ─────────────────────────────────────────────
# Rows are plain strings, looked up by prefix. Fish has no string keys.
set -g NODES (jq -r '
    .nodes | to_entries[]
    | select(.key != "root")
    | .key as $id | .value as $v
    | [$id,
       (($v.locked.lastModified // 0) | if . > 0 then strftime("%Y-%m-%d") else "" end),
       ((($v.locked.rev // "") | tostring)[0:7]),
       (if $v.locked.type == "file" then "file"
        elif $v.original.type == "github" then "github:\($v.original.owner)/\($v.original.repo)"
        else ($v.locked.url // $v.original.url // "")
        end)]
    | join("|")
' $LOCK)

set -g EDGES (jq -r '
    .nodes | to_entries[]
    | .key as $parent
    | (.value.inputs // {}) | to_entries[]
    | if (.value | type) == "array"
      then [$parent, "follow", .key, (.value | join("/"))]
      else [$parent, "child", .key, .value]
      end
    | join("|")
' $LOCK)

set -g ROOT_NAMES
set -g ROOT_IDS
for row in (jq -r '.nodes.root.inputs | to_entries[] | [.key, .value] | join("|")' $LOCK)
    set -l f (string split '|' -- $row)
    set -a ROOT_NAMES $f[1]
    set -a ROOT_IDS $f[2]
end

function node_field --argument-names id index
    for row in $NODES
        if string match -q -- "$id|*" $row
            set -l parts (string split '|' -- $row)
            echo $parts[$index]
            return
        end
    end
end

function kids_of --argument-names id
    for row in $EDGES
        if string match -q -- "$id|child|*" $row
            set -l parts (string split '|' -- $row)
            echo (string join '|' $parts[3..4])
        end
    end
end

function fols_of --argument-names id
    for row in $EDGES
        if string match -q -- "$id|follow|*" $row
            set -l parts (string split '|' -- $row)
            echo (string join '|' $parts[3..4])
        end
    end
end

# ── Root pins that reach each node ──────────────────────────────────
set -g ROOT_HITS
for i in (seq (count $ROOT_NAMES))
    set -l root $ROOT_NAMES[$i]
    set -l frontier $ROOT_IDS[$i]
    set -l seen
    while test (count $frontier) -gt 0
        set -l next
        for id in $frontier
            contains -- $id $seen; and continue
            set -a seen $id
            contains -- "$id|$root" $ROOT_HITS; or set -a ROOT_HITS "$id|$root"
            for kid in (kids_of $id)
                set -a next (string split '|' -- $kid)[2]
            end
        end
        set frontier $next
    end
end

function roots_of --argument-names id
    for row in $ROOT_HITS
        if string match -q -- "$id|*" $row
            echo (string split '|' -- $row)[2]
        end
    end
end

# ── Build the tree ──────────────────────────────────────────────────
# One tab-separated record per line, so empty fields keep their column.
set -g TAB (printf '\t')
set -g ROWS

function add_line --argument-names display date rev url extra kind
    set -a ROWS (string join $TAB "$display" "$date" "$rev" "$url" "$extra" "$kind")
end

function also_in --argument-names id root
    for other in (roots_of $id)
        test "$other" = "$root"; and continue
        echo $other
        return
    end
end

function walk --argument-names id prefix root depth
    test -n "$depth"; or return
    test $depth -gt $MAX_DEPTH; and return

    set -l entries
    for kid in (kids_of $id)
        set -a entries "child|$kid"
    end
    # Follows are printed inline on the pin line, not as a child line.
    if test $depth -gt 1
        for fol in (fols_of $id)
            set -a entries "follow|$fol"
        end
    end
    set -q entries[1]; or return

    set -l total (count $entries)
    for i in (seq $total)
        set -l entry (string split '|' -- $entries[$i])
        set -l name $entry[2]
        set -l last 0
        test $i -eq $total; and set last 1

        set -l connector "├─"
        set -l next_prefix "$prefix│  "
        if test $last -eq 1
            set connector "└─"
            set next_prefix "$prefix   "
        end
        set -l display "$prefix$connector $name"

        if test "$entry[1]" = follow
            set -l path $entry[3]
            string match -q -- "$root/*" $path; and set path (string replace -- "$root/" "" $path)
            if string match -q -- "*/*" $path
                add_line $display "" "" "" "$DIM""follows input '$path'""$RESET" follow
            else
                add_line $display "" "" "" "$DIM""follows $path""$RESET" follow
            end
            continue
        end

        set -l child $entry[3]
        if test "$(node_field $child 4)" = file
            add_line $display "" "" "" "$DIM""locked as 'file', which this tree cannot read""$RESET" file
            continue
        end

        set -l note ""
        set -l other (also_in $child $root)
        test -n "$other"; and set note "$DIM(also in $other)$RESET"

        add_line $display "$DIM"(node_field $child 2)"$RESET" \
            "$CYAN"(node_field $child 3)"$RESET" \
            (node_field $child 4) "$note" node

        walk $child $next_prefix $root (math $depth + 1)
    end
end

for i in (seq (count $ROOT_NAMES))
    set -l name $ROOT_NAMES[$i]
    set -l id $ROOT_IDS[$i]

    set -l note ""
    set -l other (also_in $id $name)
    test -n "$other"; and set note "$DIM(also in $other)$RESET"

    set -l fol_names
    for fol in (fols_of $id)
        set -a fol_names (string split '|' -- $fol)[1]
    end
    set -l follows ""
    if set -q fol_names[1]
        set follows "$DIM""follows "(string join ", " $fol_names)"$RESET"
    end

    if test "$(node_field $id 4)" = file
        add_line "$BOLD$name$RESET" "" "" "" \
            "$DIM""locked as 'file', which this tree cannot read""$RESET" file
        continue
    end

    add_line "$BOLD$name$RESET" "$DIM"(node_field $id 2)"$RESET" \
        "$CYAN"(node_field $id 3)"$RESET" (node_field $id 4) \
        "$note  $follows" node

    walk $id "" $name 1
end

# ── Print ───────────────────────────────────────────────────────────
function strip_color
    string replace --all --regex '\x1b\[[0-9;]*m' '' $argv
end

set -l width 0
for row in $ROWS
    set -l display (string split $TAB -- $row)[1]
    set width (math "max($width, "(string length -- (strip_color $display))")")
end
set width (math "$width + 2")

echo
for row in $ROWS
    set -l parts (string split $TAB -- $row)
    set -l display $parts[1]
    set -l date $parts[2]
    set -l rev $parts[3]
    set -l url $parts[4]
    set -l extra $parts[5]
    set -l kind $parts[6]

    set -l pad (math "$width - "(string length -- (strip_color $display)))
    set -l line "  $display"(string repeat --count $pad -- " ")

    if test "$kind" = node
        set line "$line  "(string pad --right --width 10 -- "$date")"  \
"(string pad --right --width 7 -- "$rev")"  $url"
    end
    test -n "$extra"; and set line "$line  $extra"

    printf "%s\n" (string trim --right -- $line)
end
echo
