#!/bin/bash

set -ueo pipefail

gh_token="$1"; shift
label="$1"; shift
color="$1"; shift

msg='{"name": "'$label'", "color": "'$color'"}'
echo "$msg"
echo "Does this look correct?"
select yn in "yes" "no"; do
    case $yn in
        yes ) break;;
        no ) exit 1;;
    esac
done

for proj in dmd druntime phobos tools installer dlang.org; do
    url=$(curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/labels" \
                 | jq -r ".[] | select(.name == \"$label\") | .url")
    if [ ! -z "$url" ]; then
        curl -fsSL -X PATCH -H "Authorization: token $gh_token" $url \
             --data "$msg" | jq --raw-output '.url'
    else
        curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/labels" \
             --data "$msg" | jq --raw-output '.url'
    fi
done
