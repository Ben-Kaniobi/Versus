#!/bin/bash

# Exit on error
set -o errexit

# Check if any argument is a directory
ISDIR=false
for arg in "$@"; do
    if [ -d "$arg" ]; then
        ISDIR=true
    fi
done

if [ "$#" -le 0 ] || [ "$ISDIR" = true ]; then
    git difftool --dir-diff $@
else
    git difftool $@
fi