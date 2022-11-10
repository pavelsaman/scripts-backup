#!/usr/bin/env bash

if [[ -z "$1" ]]; then
  echo "No tag specified"
  exit 1
fi

git tag -d "$1" \
  && git push --delete origin "$1" \
  && git tag "$1" \
  && git push --tags

echo "$1 tag moved to HEAD"
