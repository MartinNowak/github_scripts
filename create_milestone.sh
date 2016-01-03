#!/bin/bash

set -ueo pipefail

gh_token=$1; shift
version=$1; shift
date=$1; shift

if ! [[ $version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$"-b"[0-9]+$ ]] &&
        ! [[ $version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$"-rc"[0-9]+$ ]] &&
        ! [[ $version =~ ^[0-9]'.'[0-9][0-9][0-9]'.'[0-9]$ ]]; then
    echo "Unexpected version format '$version'" 1>&2
    exit 1
fi
if ! date -ud "$date"; then
    echo "Failed to parse date '$date'" 1>&2
    exit 1
fi

date=$(date -ud "$date" --iso-8601=seconds | sed 's|+0000$|Z|')
msg='{"title": "'$version'", "due_on": "'$date'"}'
echo "$msg"
echo "Does this look correct?"
select yn in "yes" "no"; do
    case $yn in
        yes ) break;;
        no ) exit 1;;
    esac
done

for proj in dmd druntime phobos dlang.org installer tools; do
    url=$(curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/milestones" \
                 | jq -r '.[] | select(.title == "'$version'") | .url')
    if [ ! -z "$url" ]; then
        curl -fsSL -X PATCH -H "Authorization: token $gh_token" $url \
             --data "$msg" | jq --raw-output '.html_url'
    else
        curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/milestones" \
             --data "$msg" | jq --raw-output '.html_url'
    fi
done
