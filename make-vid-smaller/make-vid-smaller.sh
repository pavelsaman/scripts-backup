#!/usr/bin/env bash

set -euo pipefail

function die() {
  echo "Fatal: $*" >&2
  exit 1
}

function installed_and_executable() {
  local name
  name="$(command -v "${1}")"

  [[ -n "${name}" ]] && [[ -f "${name}" ]] && [[ -x "${name}" ]]
  return $?
}

function check_deps() {
  deps=(ffmpeg curl)
  for dep in "${deps[@]}"; do
    installed_and_executable "${dep}" || die "${dep} not installed"
  done
}

function main() {
  check_deps

  local vidFile="$1"

  [[ -z "$vidFile" ]] && die "No vid file specified"

  ffmpeg -i "$1" -c:v libx264 -vf scale=1920x1080 -crf 27 "out-$(date +%Y-%m-%d-%H%M%S).mp4"
}

main "$@"
