#!/usr/bin/env bash

set -euo pipefail

readonly base_url="https://api.slido-staging.com/"

die() {
  echo "Fatal: ${1}" >&2
  exit 1
}

installed_and_executable() {
  local name
  name="$(command -v "${1}")"

  [[ -n "${name}" ]] && [[ -f "${name}" ]] && [[ -x "${name}" ]]
  return $?
}

get_global_api_version() {
  local env_num="${1}"
  local global_api_path="global/api"

  [[ "${env_num}" = 1 ]] && env_num=""
  
  if [[ -z "${env_num}" ]]; then
    curl \
      --silent "${base_url}${global_api_path}/ping" 2>/dev/null \
      | jq
  else
    curl \
      --silent "${base_url}${global_api_path}/development${env_num}/ping" 2>/dev/null \
      | jq
  fi
}

get_api_version() {
  local env_num="${1}"
  [[ "$env_num" = 1 ]] && env_num=""

  curl --silent "${base_url}development${env_num}/ping" 2>/dev/null \
    | jq
}

show_help() {
    cat <<ENDHELP
apienvinfo.sh [OPTIONS...]

Get info about staging api environments.

Options:
  -v <api_environment_num>    Get info about a specific api environment
  -g <api_environment_num>    Get info about a specific global api environment
  -a                          Author
  -h                          Show this help.
ENDHELP
}

check_deps() {
  deps=(jq curl)
  for dep in "${deps[@]}"; do
    installed_and_executable "${dep}" || die "${dep} not installed"
  done
}

main() {
  check_deps

  local -i number_of_envs=14
  local -i number_of_global_envs=4

  while getopts "v:g:ha:" opt; do
    case "${opt}" in
      v)
        get_api_version "${OPTARG}"
        concrete_version_requested=true
        ;;
      g)
        get_global_api_version "${OPTARG}"
        concrete_version_requested=true
        ;;
      h)
        show_help
        exit 0
        ;;
      a) author="${OPTARG}" ;;
      *)
        show_help
        exit 1
        ;;
    esac
  done

  [[ "${concrete_version_requested:-false}" = true ]] && exit 0;

  result=""
  for (( en=1; en <= number_of_global_envs; en++ )); do
    global_api_version="$(get_global_api_version "${en}")"
    result="${result}\n${global_api_version}"
  done

  for (( en=1; en <= number_of_envs; en++ )); do
    api_version="$(get_api_version "${en}")"
    result="${result}\n${api_version}"
  done

  if [[ -n "${author:-}" ]]; then
    echo -e "${result}" | grep -A 8 -B 2 "${author}"
  else
    echo -e "${result}" | jq
  fi
}

main "$@"
