#!/bin/bash

# Exit on error
set -o errexit
err=0

mydir="$(dirname "$0")"
args=()

# Check if there are external files in the argument list
isext=false
for arg in "$@"; do
    if [[ -e "$arg" ]]; then
        if [[ "$(git ls-files "$arg" 2>/dev/null)" == "" ]]; then
            isext=true
            args+=( "$arg" )
        elif [[ "$arg" != *"/"* ]]; then
            # Is only file/dir name without path
            args+=( "$PWD/$arg" )
        else
            args+=( "$arg" )
        fi
    else
        args+=( "$arg" )
    fi
done

# Check if there are only staged differences, if so then set autostaged variable
autostaged=""
if [[ "$isext" == false ]]; then
    git diff          --quiet "${args[@]}" && autostaged="--staged" || err=$?
    [[ $err -gt 1 ]] && exit $err || err=0
    git diff --cached --quiet "${args[@]}" && autostaged=""         || err=$?
    [[ $err -gt 1 ]] && exit $err || err=0
    if [[ "$autostaged" != "" ]]; then
        echo "No unstaged modifications, automatically running difftool with '$autostaged' option..."
    fi
fi

# Count number of files witch changes
numchanges=0
if [[ "$isext" == false ]]; then
    numchanges=$(git diff --diff-filter=M $autostaged --name-only "${args[@]}" | wc -l)
fi

# Check if there are merge confligts
conflicts=false
git diff --diff-filter=U --quiet "${args[@]}" || err=$?
[[ $err -gt 1 ]] && exit $err
[[ $err -gt 0 ]] && conflicts=true || err=0

if [[ "$isext" == true ]]; then
    "$mydir/git-difftool-cmd" "${args[@]}"
elif [[ "$conflicts" == true ]]; then
    echo "Merge conflicts detected, running git mergetool..."
    git mergetool "${args[@]}"
elif [[ "$numchanges" != 1 ]]; then
    git difftool --dir-diff $autostaged "${args[@]}"
else
    git difftool $autostaged "${args[@]}"
fi
