#!/usr/bin/env bash

set -euo pipefail

if [[ -z "$1" ]]; then
  echo "No tag specified"
  exit 1
fi

main_branch="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
git checkout "$main_branch" \
  && git pull \
  && git tag -d "$1" \
  && git push --delete origin "$1" \
  && git tag "$1" \
  && git push --tags

echo "$1 tag moved to HEAD"
