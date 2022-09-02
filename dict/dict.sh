#!/usr/bin/env bash

set -euo pipefail

readonly url="https://www.macmillandictionary.com/search/british/direct/?q="

print_help() {
  cat <<ENDHELP
dict.sh [OPTIONS] <-w word>

Options:
  -w    word to look up
  -h    show this help  
ENDHELP
}

die() {
  echo "Fatal: $*" >&2
  exit 1
}

installed_and_executable() {
  local cmd
  cmd=$(command -v "${1}")

  [[ -n "${cmd}" ]] && [[ -f "${cmd}" ]] && [[ -x "${cmd}" ]]
  return $?
}

check_deps() {
  local deps=(curl pup)
  for dep in "${deps[@]}"; do
    installed_and_executable "${dep}" || die "Missing '${dep}' dependency or not executable"
  done
}

main() {
  check_deps

  local word=
  while getopts ":w:h" opt; do
    case "${opt}" in
      w ) word="${OPTARG}" ;;
      h )
        print_help
        exit 0
        ;;
      \?)
        echo "Unknown option: -${OPTARG}" >&2
        exit 1
        ;;
      : )
        echo "Missing option argument for -${OPTARG}" >&2
        exit 1
        ;;
      * )
        echo "Unimplemented option: -${opt}. See help (-h option)" >&2
        exit 1
        ;;
    esac
  done

  if [[ -z "${word}" ]]; then
    echo "No word, see help (-h option)" >&2
    exit 1
  fi

  result="$(curl -s -L "${url}${word}" | pup '.DEFINITION text{}' | tr -d '\n')"
  printf "%s\n" "${result}"
}

main "$@"
