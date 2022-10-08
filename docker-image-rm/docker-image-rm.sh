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
  deps=(awk grep xargs docker)
  for dep in "${deps[@]}"; do
    installed_and_executable "${dep}" || die "${dep} not installed"
  done
}

function show_help() {
    cat <<ENDHELP
docker-image-rm.sh [OPTIONS...]

Remove all docker images.

Options:
  -h    Show this help
ENDHELP
}

function remove_all() {
  local -i image_count
  
  image_count="$(docker image ls | wc -l)"
  if (( image_count > 1 )); then
    docker images --all \
      | grep --invert-match REPO \
      | awk '{print $3}' \
      | xargs docker image rm --force
  fi
}

function main() {
  check_deps

  while getopts "h" opt; do
    case "${opt}" in
      h)
        show_help
        exit 0
        ;;
      *)
        show_help
        exit 1
        ;;
    esac
  done

  remove_all
}

main "$@"

