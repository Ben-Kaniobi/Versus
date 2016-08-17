#!/bin/bash

# Exit on error
set -o errexit

MYDIR="$(dirname "$0")"

# Check if there are only staged differences, if so then set AUTOCACHED variable
AUTOCACHED=""
git diff --quiet && AUTOCACHED="--cached" && echo "No unstaged modifications, automatically running difftool with '$AUTOCACHED' option..."

# Check type of each argument
ISDIR=false
ISEXT=false
NOPATH=true
for arg in "$@"; do
    if [ -d "$arg" ]; then
        ISDIR=true
    fi
    
    if [ -e "$arg" ]; then
        NOPATH=false
        if [ "$(git ls-files "$arg" 2>/dev/null)" == "" ]; then
            ISEXT=true
        fi
    fi
done

if [ "$ISEXT" = true ]; then
    "$MYDIR/git-difftool-cmd" $@
elif [ "$NOPATH" = true ] || [ "$ISDIR" = true ]; then
    git difftool --dir-diff $AUTOCACHED $@
else
    git difftool $AUTOCACHED $@
fi