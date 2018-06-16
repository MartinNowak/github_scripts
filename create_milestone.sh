#!/bin/bash

set -ueo pipefail

gh_token=$1; shift
d_version=$1; shift
dub_version=$1; shift
date=$1; shift

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
if ! date -ud "$date"; then
    echo "Failed to parse date '$date'" 1>&2
    exit 1
fi

date=$(date -ud "$date" --iso-8601=seconds | sed 's|+0000$|Z|')
d_msg='{"title": "'$d_version'", "due_on": "'$date'"}'
echo "D: $d_msg"
dub_msg='{"title": "'$dub_version'", "due_on": "'$date'"}'
echo "dub: $dub_msg"
echo "Do these look correct?"
select yn in "yes" "no"; do
    case $yn in
        yes ) break;;
        no ) exit 1;;
    esac
done

for proj in dmd druntime phobos dlang.org installer tools dub; do
    if [ $proj == dub ]; then
        ver=$dub_version
        msg=$dub_msg
    else
        ver=$d_version
        msg=$d_msg
    fi
    url=$(curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/milestones" \
              | jq -r '.[] | select(.title == "'$ver'") | .url')
    if [ ! -z "$url" ]; then
        curl -fsSL -X PATCH -H "Authorization: token $gh_token" $url \
             --data "$msg" | jq --raw-output '.html_url'
    else
        curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/milestones" \
             --data "$msg" | jq --raw-output '.html_url'
    fi
done
