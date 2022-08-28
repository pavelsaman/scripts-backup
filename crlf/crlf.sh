#!/usr/bin/env bash

set -euo pipefail

declare -a deps=(dos2unix)

installed_and_executable() {
  local cmd
  cmd=$(command -v "${1}")

  [[ -n "${cmd}" ]] && [[ -f "${cmd}" ]] && [[ -x "${cmd}" ]]
  return $?
}

check_deps() {
  for dep in "${deps[@]}"; do
    installed_and_executable "${dep}" || { echo "Please install ${dep}"; exit 1; }
  done
}

check_deps
find . -not -type d -exec dos2unix --info=c "{}" ";"
