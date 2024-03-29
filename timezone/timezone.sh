#!/usr/bin/env bash

set -euo pipefail

readonly localtime_path=/etc/localtime
readonly zoneinfo_path=/usr/share/zoneinfo

get_timezone() {
  realpath "${localtime_path}" \
    | rev \
    | cut -d'/' -f1,2 \
    | rev
}

get_timezones() {
  local region="${1}"
  find "${zoneinfo_path}"/"${region}"/* \
    | rev \
    | cut -d'/' -f1,2 \
    | rev
}

get_regions() {
  find "${zoneinfo_path}/" -maxdepth 1 -type d \
    | rev \
    | cut -d'/' -f1,2 \
    | rev \
    | sed 's/zoneinfo\///;/^[[:space:]]*$/d'
}

set_timezone() {
  local new_timezone_path="${1}"
  ln -sf "${zoneinfo_path}/${new_timezone_path}" "${localtime_path}"
}

print_help() {
  cat <<END
Timezone

Usage:
  timezone.sh (-a <region>|-c|-s <timezone>|r)
  timezone.sh -h

Options:
  -a <region>     Get all timezone in a region, e.g. "Europe"
  -c              Get current timezone
  -s <timezone>   New timezone, e.g. Europe/Tallinn
  -r              Get all regions
  -h              Print this help
END
}

while getopts "cs:ha:r" opt; do
  case "${opt}" in
    a) get_timezones "${OPTARG}" ;;
    c) get_timezone              ;;
    h) print_help                ;;
    s) set_timezone "${OPTARG}"  ;;
    r) get_regions               ;;
    *)
      print_help
      exit 1
      ;;
  esac
done

if [[ -z "${1:-}" ]]; then
  print_help
  exit 1
fi
