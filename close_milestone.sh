#!/bin/bash

set -ueo pipefail

gh_token=$1; shift
version=$1; shift

if ! [[ $version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$"-b"[0-9]+$ ]] &&
        ! [[ $version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$"-rc"[0-9]+$ ]] &&
        ! [[ $version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$ ]]; then
    echo "Unexpected version format '$version'" 1>&2
    exit 1
fi

for proj in dmd druntime phobos dlang.org installer tools; do
    url=$(curl -fsSL "https://api.github.com/repos/dlang/$proj/milestones?access_token=$gh_token" \
                 | jq -r '.[] | select(.title == "'$version'") | .url')
    if [ ! -z "$url" ]; then
        curl -fsSL -X PATCH $url?access_token=$gh_token \
             --data '{"state": "closed"}' | jq --raw-output '.html_url'
    fi
done
