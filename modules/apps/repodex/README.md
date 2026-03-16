
# repodex

## Features

- Clone repos in url order e.g. https://github.com/frostplexx/opsops gets cloned into $ROOT/github.com/frostplexx/opsops
- Configurable using yaml file in .config
- TUI thats **fast**
- Allows to search for projects using fuzzy search e.g. fzf
- Some preview panes for project content, languages, git status etc.
- Allows to clone new project either from TUI or CLI
- Allows to delete projects from TUI or CLI
    - Warns user if they are about to delete a repo that has uncommited changes
- Allows users to migrate any arbitrary repo by looking at the main upstream for url
