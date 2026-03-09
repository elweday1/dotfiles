#!/bin/bash
# Open file in fresh session (same directory = same session)

file="$1"

echo "PWD: $(pwd)" >> ~/yazi_debug.log
echo "File: $file" >> ~/yazi_debug.log

# Fresh session name format: home_deck for /home/deck
session_name=$(echo "$PWD" | sed 's/\//_/g' | sed 's/^_//')

echo "Session: $session_name" >> ~/yazi_debug.log

# Open in fresh session
fresh --cmd session open-file "$session_name" "$file"

echo "Done" >> ~/yazi_debug.log
