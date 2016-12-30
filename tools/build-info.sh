#! /usr/bin/env bash

# Output file to be included in image as /etc/motd
output="buildinfo.txt"

# Get our build version
version="$( git describe --tags --abbrev=0 2> /dev/null )"

# If we're not on a tag just get commit and ref
if [[ -z $version ]] ; then
  branch="$(git symbolic-ref HEAD 2> /dev/null)"
  branch="${branch#refs/heads/}"

  version="$( git rev-parse --short HEAD ) @ ${branch}"
fi

# Add a note that image was built untracked changes
dirty="$( git status --porcelain 2> /dev/null )"
[[ -n $dirty ]] && dirty="(dirty build)" || dirty=""

# Write our output file
cat << EOF > "$output"

Vamp buildserver
https://github.com/magneticio/vamp-buildserver

Created: $(date --utc +%FT%TZ)
Version: $version $dirty
Tag    : $( git describe --tags )
Commit : $( git rev-parse HEAD )

EOF

cat "$output"
