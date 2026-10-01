function wake --description "Keep the machine awake until interrupted"
    printf '  Keeping PC awake...'
    if test (uname) = Darwin
        caffeinate -d -i -m -s
    else
        systemd-inhibit --what=idle:sleep --who=wake --why="wake function" sleep infinity
    end
end
