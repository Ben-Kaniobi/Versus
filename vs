#!/bin/bash

# Exit on error
set -o errexit

MYDIR="$(dirname "$0")"

# Check if there are only staged differences, if so then set AUTOCACHED variable
AUTOCACHED=""
git diff --quiet && AUTOCACHED="--cached" && echo "No unstaged modifications, automatically running difftool with '$AUTOCACHED' option..."

# Check if there are external files in the argument list
ISEXT=false
for arg in "$@"; do
    if [ -e "$arg" ]; then
        if [ "$(git ls-files "$arg" 2>/dev/null)" == "" ]; then
            ISEXT=true
        fi
    fi
done

# Count number of files witch changes
NUMCHANGES=0
if [ "$ISEXT" == false ]; then
    NUMCHANGES=$(git diff --diff-filter=M --name-only "$@" | wc -l)
fi

if [ "$ISEXT" = true ]; then
    "$MYDIR/git-difftool-cmd" $@
elif [ "$NUMCHANGES" != 1 ]; then
    git difftool --dir-diff $AUTOCACHED $@
else
    git difftool $AUTOCACHED $@
fi