#!/usr/bin/env bash

set -euo pipefail

localtime_path=/etc/localtime
zoneinfo_path=/usr/share/zoneinfo

get_timezone() {
  realpath "${localtime_path}" | rev | cut -d'/' -f1,2 | rev
}

get_timezones() {
  local region="${1}"
  find "${zoneinfo_path}"/"${region}"/* | rev | cut -d'/' -f1,2 | rev
}

get_regions() {
  find "${zoneinfo_path}/" -maxdepth 1 -type d | rev | cut -d'/' -f1,2 | rev | sed 's/zoneinfo\///;/^[[:space:]]*$/d'
}

set_timezone() {
  local new_timezone_path="${1}"
  ln -sf "${zoneinfo_path}/${new_timezone_path}" "${localtime_path}"
}

print_help() {
  cat <<END
timezone [OPTIONS...]

OPTIONS:
  -a <region>     get all timezone in a region, e.g. Europe
  -c              get current timezone
  -s <timezone>   new timezone, e.g. Europe/Tallinn
  -r              get all regions
  -h              print this help
END
}

while getopts "cs:ha:r" opt; do
  case "${opt}" in
    a) get_timezones "${OPTARG}" ;;
    c) get_timezone              ;;
    h) print_help                ;;
    s) set_timezone "${OPTARG}"  ;;
    r) get_regions               ;;
    *) print_help; exit 1        ;;
  esac
done

[[ -z "${1:-}" ]] && print_help

exit 0
