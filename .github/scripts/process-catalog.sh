#!/usr/bin/env bash
set -euo pipefail

out="$1"

# Prefilter JDK packages that meet all of the following criteria: 
#   - directly downloadable 
#   - provided as an archive in one of the these formats: tar.gz, tgz or zip
#   - compiled for one of these operating systems: linux, macos
PACKAGE_RESOURCE="https://api.foojay.io/disco/v3.0/packages?package_type=jdk&directly_downloadable=true&archive_type=tar.gz&archive_type=zip&archive_type=tgz&operating_system=linux&operating_system=macos"
DISTRIBUTION_RESOURCE="https://api.foojay.io/disco/v3.0/distributions"

curl --connect-timeout 30 --max-time 60 -fsSL "$PACKAGE_RESOURCE" -o packages.json 2>/dev/null
curl --connect-timeout 30 --max-time 60 -fsSL "$DISTRIBUTION_RESOURCE" -o distributions.json 2>/dev/null

jq --slurpfile dist distributions.json '
  def rank: { "tar.gz":0, "tgz":1, "zip":2 }[.] ;
  [ .result[] as $pkg
    | ($dist[0].result[] | select(.api_parameter == $pkg.distribution)) as $d
    | {
        distribution: $d.name,
        distribution_version: $pkg.distribution_version,
        java_version: $pkg.java_version,
        major_version: $pkg.major_version,
        javafx_bundled : $pkg.javafx_bundled,
        identifier: ($pkg.distribution + "-" + $pkg.distribution_version + (if $pkg.javafx_bundled then "-fx" else "" end)),
        support: (if ($pkg.term_of_support|ascii_downcase) == "sts" then "Non-LTS" else "LTS" end),
        link: $d.official_uri,
        operating_system: $pkg.operating_system,
        architecture: $pkg.architecture,
        indirect_download_uri: $pkg.links.pkg_download_redirect,
        archive_type: $pkg.archive_type
      }
  ]
  | sort_by([ .identifier, (.archive_type | rank) ])
  | unique_by(.identifier, .operating_system, .architecture)
' packages.json > "$out"
