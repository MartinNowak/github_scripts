#!/bin/bash

set -ueo pipefail

gh_token=$1; shift
base=${1:-stable}
echo "Listing Pull Requests with base branch $base"

for proj in dmd druntime phobos dlang.org installer tools dub; do
    curl -fsSL -H "Authorization: token $gh_token" "https://api.github.com/repos/dlang/$proj/pulls?base=$base" \
                 | jq -r '.[].html_url'
done
