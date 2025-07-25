#!/usr/bin/env bash
set -euo pipefail

old_catalog="$1"
new_catalog="$2"

if [ -f "$old_catalog" ]; then
  result=$(jq --slurpfile b "$new_catalog" \
    'sort_by(.identifier + "-" + .operating_system + "-" + .architecture + "-" + .java_version) ==
     ($b[0] | sort_by(.identifier + "-" + .operating_system + "-" + .architecture + "-" + .java_version))' \
    "$old_catalog")
else
  result="false"
fi

echo "$result"
