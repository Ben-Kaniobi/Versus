#!/bin/bash

# Exit on error
set -o errexit

MYDIR="$(dirname "$0")"

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
    git difftool --dir-diff $@
else
    git difftool $@
fi