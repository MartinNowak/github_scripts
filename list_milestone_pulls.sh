#!/bin/bash

set -ueo pipefail

gh_token=$1; shift
milestone=$1
echo "Listing Pull Requests for milestone $milestone"

for proj in dmd druntime phobos dlang.org installer tools dub; do
    curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/pulls?milestone=$milestone" \
                 | jq -r '.[].html_url'
done
