# Work topic management -----------------------------------------------------
# Set a topic/reminder for what you're working on in this window.
if not set -q WORK_TOPIC
    set -gx WORK_TOPIC ""
end

function topic -d "Set or view work topic for this terminal"
    if test (count $argv) -eq 0
        if test -z "$WORK_TOPIC"
            echo "No topic set. Use: topic 'your work description'"
        else
            echo "Current topic: $WORK_TOPIC"
        end
    else if test "$argv[1]" = "clear" -o "$argv[1]" = "reset"
        set -gx WORK_TOPIC ""
        echo "Topic cleared"
        __update_terminal_title
    else
        set -gx WORK_TOPIC (string join ' ' $argv)
        echo "Topic set to: $WORK_TOPIC"
        __update_terminal_title
    end
end

function __update_terminal_title -d "Update terminal title with cwd, git branch, and work topic"
    set -l title ""
    set -l cwd (basename "$PWD")

    # Get git branch if in a repo
    if git rev-parse --is-inside-work-tree &>/dev/null
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git describe --tags --exact-match 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        set title "$cwd [$branch]"
    else
        set title "$cwd"
    end

    # Add work topic if set
    if test -n "$WORK_TOPIC"
        set title "🎯 $WORK_TOPIC | $title"
    end

    # Set terminal title
    printf '\033]0;%s\007' "$title"
end

function __check_local_topic -d "Read .topic file when entering a directory"
    if test -f .topic
        set -gx WORK_TOPIC (string trim < .topic)
    end
end

# Update title + check .topic on directory change
function __topic_on_chdir --on-variable PWD -d "Update title and check .topic on chdir"
    __update_terminal_title
    __check_local_topic
end

# Update title before each prompt
function __topic_on_prompt --on-event fish_prompt -d "Update terminal title before prompt"
    __update_terminal_title
end

# Update title before each command (overrides external changes)
function __topic_on_preexec --on-event fish_preexec -d "Update terminal title before command"
    __update_terminal_title
end

# Run on initial load
__update_terminal_title
__check_local_topic
