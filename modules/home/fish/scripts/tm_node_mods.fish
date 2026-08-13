
function tm_exclude_node_modules
    set -l EXCLUDED_DIRECTORIES env node_modules vendor venv
    
    set -l WORK_DIR (dirname (status --current-filename))
    set -l WORK_DIR (realpath $WORK_DIR)
    
    for EXCLUDED_DIRECTORY in $EXCLUDED_DIRECTORIES
        fd -t d -H -I "^$EXCLUDED_DIRECTORY\$" $WORK_DIR -x tmutil addexclusion {}
    end
end
