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

Remove all docker images or containers.

Options:
  -c    Remove containers
  -i    Remove images
  -h    Show this help
ENDHELP
}

function remove_all_images() {
  local -i image_count
  
  image_count="$(docker image ls | wc -l)"
  if (( image_count > 1 )); then
    docker images --all \
      | grep --invert-match REPO \
      | awk '{print $3}' \
      | xargs docker image rm --force
  fi
}

function remove_all_containers() {
  local -i image_count
  
  container_count="$(docker ps --all | wc -l)"
  if (( container_count > 1 )); then
    docker ps --all \
      | grep --invert-match CONTAINER \
      | awk '{print $1}' \
      | xargs docker rm --force
  fi
}

function main() {
  check_deps

  while getopts "cih" opt; do
    case "${opt}" in
      c)
        remove_all_containers
        exit 0
        ;;
      i)
        remove_all_images
        exit 0
        ;;
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

  echo "Use -c, or -i. See --help"
  exit 1
}

main "$@"

