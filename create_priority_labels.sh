#!/bin/bash

set -ueo pipefail

gh_token="$1"; shift
repo="$1"; shift

# https://coolors.co/edf2f4-8d99ae-2b2d42-ef233c-d90429
labels=(1-do:edf2f4 2-re:8d99ae 3-mi:2b2d42 4-fa:ef233c 5-sol:d90429)

for label in "${labels[@]}"; do
    IFS=: read name color <<< $label
    msg='{"name": "'"$name"'", "color": "'"$color"'"}'
    echo "Adding label '$name' (#$color) to $repo"
    url=$(curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/$repo/labels" \
              | jq -r ".[] | select(.name == \"$name\") | .url")
    if [ ! -z "$url" ]; then
        curl -fsSL -X PATCH -H "Authorization: token $gh_token" $url \
             --data "$msg" | jq --raw-output '.url'
    else
        curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/$repo/labels" \
             --data "$msg" | jq --raw-output '.url'
    fi
done
