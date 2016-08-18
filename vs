#!/bin/bash

# Exit on error
set -o errexit

MYDIR="$(dirname "$0")"

# Check if there are only staged differences, if so then set AUTOCACHED variable
AUTOCACHED=""
git diff --quiet && AUTOCACHED="--cached"
git diff --cached --quiet && AUTOCACHED=""
if [ "$AUTOCACHED" != "" ]; then
    echo "No unstaged modifications, automatically running difftool with '$AUTOCACHED' option..."
fi

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

# Check if there are merge confligts
CONFLICTS=false
git diff --diff-filter=U --quiet $@ || CONFLICTS=true

if [ "$ISEXT" == true ]; then
    "$MYDIR/git-difftool-cmd" $@
elif [ "$CONFLICTS" == true ]; then
    echo "Merge conflicts detected, running git mergetool..."
    git mergetool $@
elif [ "$NUMCHANGES" != 1 ]; then
    git difftool --dir-diff $AUTOCACHED $@
else
    git difftool $AUTOCACHED $@
fi