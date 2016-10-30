#!/bin/bash

# Exit on error
set -o errexit

mydir="$(dirname "$0")"

# Check if there are external files in the argument list
isext=false
for arg in "$@"; do
    if [[ -e "$arg" ]]; then
        if [[ "$(git ls-files "$arg" 2>/dev/null)" == "" ]]; then
            isext=true
        fi
    fi
done

# Check if there are only staged differences, if so then set autostaged variable
autostaged=""
if [[ "$isext" == false ]]; then
    git diff          --quiet "$@" && autostaged="--staged"
    git diff --cached --quiet "$@" && autostaged=""
    if [[ "$autostaged" != "" ]]; then
        echo "No unstaged modifications, automatically running difftool with '$autostaged' option..."
    fi
fi

# Count number of files witch changes
numchanges=0
if [[ "$isext" == false ]]; then
    numchanges=$(git diff --diff-filter=M $autostaged --name-only "$@" | wc -l)
fi

# Check if there are merge confligts
conflicts=false
git diff --diff-filter=U --quiet $@ || conflicts=true

if [[ "$isext" == true ]]; then
    "$mydir/git-difftool-cmd" $@
elif [[ "$conflicts" == true ]]; then
    echo "Merge conflicts detected, running git mergetool..."
    git mergetool $@
elif [[ "$numchanges" != 1 ]]; then
    git difftool --dir-diff $autostaged $@
else
    git difftool $autostaged $@
fi
