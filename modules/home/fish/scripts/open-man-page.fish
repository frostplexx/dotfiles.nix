function open-man-page
    set -l token (commandline -t)
    if test -n "$token"
        man $token &
        commandline -f repaint
    end
end
