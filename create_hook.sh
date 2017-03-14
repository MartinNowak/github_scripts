#!/bin/bash

set -ueo pipefail

gh_token="$1"; shift
hook_url="$1"; shift
events="$1"; shift
secret="$1"; shift

config='{"name": "web", "active": true, "events": '$events', "config": {"url": "'$hook_url'", "secret": "'$secret'", "content_type": "json"}}'
echo "$config"
echo "Does this look correct?"
select yn in "yes" "no"; do
    case $yn in
        yes ) break;;
        no ) exit 1;;
    esac
done

for proj in dmd druntime phobos tools installer dlang.org dub dub-registry; do
    url=$(curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/hooks" \
              | jq -r ".[] | select(.config.url == \"$hook_url\") | .url")
    echo $url
    if [ ! -z "$url" ]; then
        curl -fsSL -X PATCH -H "Authorization: token $gh_token" $url \
             --data "$config"
    else
        curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/hooks" \
             --data "$config"
    fi
done
