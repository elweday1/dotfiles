#!/bin/bash
file="$1"

# Get full path
if [[ ! "$file" = /* ]]; then
    file="$(pwd)/$file"
fi

# Open in fresh session (exit 2 = session started, which is success)
fresh --cmd session open-file . "$file"
[ $? -eq 2 ] && exit 0 || exit $?
