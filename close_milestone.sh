#!/bin/bash

set -ueo pipefail

gh_token=$1; shift
d_version=$1; shift
dub_version=$1; shift

if ! [[ $d_version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$"-b"[0-9]+$ ]] &&
        ! [[ $d_version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$"-rc"[0-9]+$ ]] &&
        ! [[ $d_version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$ ]]; then
    echo "Unexpected version format '$d_version'" 1>&2
    exit 1
fi
if ! [[ $dub_version =~ ^[0-9]+'.'[0-9]+'.'[0-9]+$"-beta."[0-9]+$ ]] &&
        ! [[ $dub_version =~ ^[0-9]+'.'[0-9]+'.'[0-9]+$"-rc."[0-9]+$ ]] &&
        ! [[ $dub_version =~ ^[0-9]+'.'[0-9]+'.'[0-9]+$ ]]; then
    echo "Unexpected version format '$dub_version'" 1>&2
    exit 1
fi

for proj in dmd druntime phobos dlang.org installer tools dub; do
    if [ $proj == dub ]; then
        ver=$dub_version
    else
        ver=$d_version
    fi
    url=$(curl -fsSL "https://api.github.com/repos/dlang/$proj/milestones?access_token=$gh_token" \
              | jq -r '.[] | select(.title == "'$ver'").url')
    if [ ! -z "$url" ]; then
        curl -fsSL -X PATCH $url?access_token=$gh_token \
             --data '{"state": "closed"}' | jq --raw-output '.html_url'
    fi
done
