#!/usr/bin/env bash

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

deps=(curl jq httprobe)
for dep in "${deps[@]}"; do
  installed_and_executable "${dep}" || die "Missing '${dep}' dependency or not executable"
done
