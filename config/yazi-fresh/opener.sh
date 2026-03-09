#!/bin/bash
file="$1"

file_abs=$(realpath "$file" 2>/dev/null || echo "$file")

# Get yazi's starting directory from the cwd file
cwd_file="/tmp/yazi-cwd"
if [ -f "$cwd_file" ]; then
    yazi_dir=$(cat "$cwd_file")
else
    # Fallback to file's directory
    yazi_dir=$(dirname "$file_abs")
fi

session_name="dev-$(basename "$yazi_dir")"

echo "Opening: $file_abs in session: $session_name (yazi_dir: $yazi_dir)" >> /tmp/fresh-opener.log

fresh --cmd session open-file "$session_name" "$file_abs" >> /tmp/fresh-opener.log 2>&1
exit 0
