#!/usr/bin/env bash

set -euo pipefail

readonly backup_folder=~/czech-blacklist
readonly url="https://blacklist.salamek.cz/api/blacklist"

die() {
  echo "Fatal: ${1}" >&2
  exit 1
}

installed_and_executable() {
  cmd=$(command -v "${1}")

  [[ -n "${cmd}" ]] && [[ -f "${cmd}" ]] && [[ -x "${cmd}" ]]
  return $?
}

download_blacklist() {
  curl \
    --silent \
    "${url}"
}

save_blacklist() {
  local blacklist="${1}"
  local today
  local checksum

  today="$(date --iso-8601=date)"
  checksum="$(sha256sum <<< "${blacklist}" | cut -d' ' -f1)"

  if ! find . -type f -name "*${checksum}" | grep . &>/dev/null ; then
    echo "${blacklist}" > "${backup_folder}/${today}_${checksum}"
  fi
}

check_deps() {
  deps=(curl jq)
  for dep in "${deps[@]}"; do
    installed_and_executable "${dep}" || die "Missing '${dep}' dependency or not executable"
  done
}

main() {
  check_deps
  mkdir -p "${backup_folder}"

  local blacklist

  blacklist="$(download_blacklist)"
  save_blacklist "${blacklist}"
}

main "$@"
