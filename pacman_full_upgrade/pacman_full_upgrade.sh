#!/usr/bin/env bash

set -euo pipefail

pacman_update() {
  pacman \
    --sync \
    --refresh \
    --refresh
}

pacman_upgradable() {
  local -i upgradable
  upgradable="$(pacman --query --upgrades | wc -l)"
  (( upgradable > 0 )) && return 0 || return 1
}

pacman_upgrade() {
  pacman \
    --sync \
    --sysupgrade \
    --noconfirm
}

main() {
  pacman_update
  pacman_upgradable && pacman_upgrade || return 0
}

main "$@"
