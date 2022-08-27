#!/usr/bin/env bash

print_help() {
  cat <<END_HELP
lsdate - display last modification time of a file

Usage:
  lsdate.sh <file>...

Options:
  -h  Print help
END_HELP
}

if (( $# < 1 )); then
  print_help
  exit 1
fi

if [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]]; then
  print_help
  exit 0
fi

IFS=" " read -r -a files <<< "$@"

for file in "${files[@]}"; do
  date --reference="${file}" "+%Y-%m-%d %H:%M:%S"
done
