#!/bin/bash
# This script is used to set up the coding environment with tmux and nvim or vscode
# It is meant to be run from the home directory and use fzf to select the project and cd into it and then start tmux and nvim
project_path=$2
editor=$1

if [ -z "$project_path" ]; then
    project_path=$(find ~/Personal ~/Work -maxdepth 2 -type d | fzf --height 100% --layout=reverse --preview 'tree -C {}' --preview-window=right:60%:wrap)
fi

#ask if they want to open in vscode or nvim
if [ -z "$editor" ]; then
editor=$(echo -e "nvim\ncode" | fzf --height 10% --layout=reverse)
fi

# make the project name the last part of the path
project=$(basename "$project_path")
# if the project name is already a session name, just attach to it
if tmux has-session -t "$project" 2>/dev/null; then
    tmux attach -t "$project"
    exit 0
fi

echo "Starting coding session for $project"
echo "Project path: $project_path"

if echo "$editor" | grep -q "code"; then
    code "$project_path"
    exit 0
fi

# Couldn't use another if statement because tmux got a bit confused... for some reason...
tmux new-session -s "$project" -n "main" -d
tmux send-keys -t "$project:main" "cd $project_path" C-m
tmux send-keys -t "$project:main" "clear" C-m
tmux send-keys -t "$project:main" "nvim ." C-m
tmux new-window -t "$project" -n "shell"
tmux send-keys -t "$project:shell" "cd $project_path" C-m
tmux send-keys -t "$project:shell" "clear" C-m
tmux select-window -t "$project:main"
tmux attach -t "$project"

