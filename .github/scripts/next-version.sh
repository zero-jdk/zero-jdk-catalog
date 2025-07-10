#!/usr/bin/env bash
set -euo pipefail

today=$(date +'%Y.%m.%d')

# List all tags for today, sorted by revision
tags=$(git tag -l | grep -E "$today.*" | sort -t. -k4,4n)

# The chronver requires the format to be YYYY.MM.DD[.revision]
if [ -z "$tags" ]; then
  version="$today"
else
  last_tag=$(echo "$tags" | tail -1)
  rev=$(echo "$last_tag" | awk -F. '{print $4}')
  rev=$((rev + 1))
  version="$today.$rev"
fi

echo $version
