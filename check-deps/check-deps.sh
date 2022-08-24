#!/usr/bin/env bash

die() {
  echo "Fatal: ${1}" >&2
  exit 1
}

installedAndExecutable() {
  cmd=$(command -v "${1}")

  [[ -n "${cmd}" ]] && [[ -f "${cmd}" ]] && [[ -x "${cmd}" ]]
  return ${?}
}

deps=(curl jq httprobe)
for dep in "${deps[@]}"; do
  installedAndExecutable "${dep}" || die "Missing '${dep}' dependency or not executable"
done
