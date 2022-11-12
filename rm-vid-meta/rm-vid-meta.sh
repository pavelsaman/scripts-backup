#!/usr/bin/env bash

set -euo pipefail

mkdir original
for file in *.MP4; do 
  cp "$file" original
done

for file in *.MP4; do 
  ffmpeg -i "$file" -vcodec copy -acodec copy "new-$file"
done
