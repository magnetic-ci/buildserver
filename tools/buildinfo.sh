#! /usr/bin/env bash
# This script collects information about version and build date

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

# Output files
output_buildinfo="${dir}/buildinfo"
output_version="${dir}/version"
output_tag="${dir}/tag"


# Get our version and tag
version="$( git describe --tags )"
tag="katana"

# If our version matches the tag we're on and we have no unstaged changes we're
# on the latest releast
[[ $version = $( git describe --tags --abbrev=0 ) ]] \
&& [[ -z $( git status --porcelain 2> /dev/null ) ]] \
    && tag="latest"


# Write our output files
echo "$version" > "$output_version"

echo "$tag" > "$output_tag"

cat << EOF > "$output_buildinfo"

┌───────────────────╴Vamp Buildserver╶───────────────────┄
│
│ Source code: https://github.com/magneticio/buildserver
│ Version    : $version ($tag)
│ Commit     : $( git rev-parse HEAD )
│ Build date : $(date --utc +%FT%TZ)
│
└────────────────────────────────────────────────────────┄

EOF

exit 0
