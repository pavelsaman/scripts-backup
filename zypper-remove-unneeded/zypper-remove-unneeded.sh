#!/usr/bin/env bash

set -euo pipefail

packages_to_remove="$(zypper packages --unneeded | awk -F'|' 'NR <= 4 {next} {print $3}')"

if [[ -n "$packages_to_remove" ]]; then
  echo "Removing packages..."
  echo "$packages_to_remove" | tr -d ' ' | xargs zypper remove --clean-deps  
else
  echo "No unneeded packages to remove."
fi
