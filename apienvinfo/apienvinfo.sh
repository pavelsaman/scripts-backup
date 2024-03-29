#!/usr/bin/env bash

set -euo pipefail

readonly base_url_prod="https://api.sli.do/"
readonly stream_base_url_prod="https://app.sli.do/"
readonly base_url="https://api.slido-staging.com/"
readonly stream_base_url="https://stream.slido-staging.com/"

die() {
  echo "Fatal: $*" >&2
  exit 1
}

installed_and_executable() {
  local name
  name="$(command -v "${1}")"

  [[ -n "${name}" ]] && [[ -f "${name}" ]] && [[ -x "${name}" ]]
  return $?
}

get_global_api_stage_version() {
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

get_version() {
  local url="${1}"
  local path_params="${2}"
  [[ "$path_params" = development1 ]] && path_params="development"

  curl --silent "${url}${path_params}/ping" 2>/dev/null \
    | jq
}

show_help() {
    cat <<ENDHELP
apienvinfo.sh [OPTIONS...]

Ping APIs.

Options:
  -v <api_environment_num>    Ping specific api environment
  -g <api_environment_num>    Ping specific global api environment
  -a                          Filter envs based on author (based on branch property)
  -p                          Ping production API.
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

  while getopts "v:g:ha:p" opt; do
    case "${opt}" in
      v)
        get_version "${base_url}" "development${OPTARG}"
        get_version "${stream_base_url}" "development${OPTARG}"
        concrete_version_requested=true
        ;;
      g)
        get_global_api_stage_version "${OPTARG}"
        concrete_version_requested=true
        ;;
      h)
        show_help
        exit 0
        ;;
      a) author="${OPTARG}" ;;
      p)
        get_version "${base_url_prod}" "eu1/api/v0.5"
        get_version "${base_url_prod}" "us1/api/v0.5"
        get_version "${stream_base_url_prod}" "eu1/stream/v0.5"
        get_version "${stream_base_url_prod}" "us1/stream/v0.5"
        get_version "${base_url_prod}" "global/api"
        exit 0
        ;;
      *)
        show_help
        exit 1
        ;;
    esac
  done

  [[ "${concrete_version_requested:-false}" = true ]] && exit 0;

  result=""
  for (( en=1; en <= number_of_global_envs; en++ )); do
    global_api_version="$(get_global_api_stage_version "${en}")"
    result="${result}\n${global_api_version}"
  done

  for (( en=1; en <= number_of_envs; en++ )); do
    api_version="$(get_version "${base_url}" "development${en}")"
    result="${result}\n${api_version}"
    
    stream_version="$(get_version "${stream_base_url}" "development${en}")"
    result="${result}\n${stream_version}"
  done

  if [[ -n "${author:-}" ]]; then
    echo -e "${result}" | jq "select(.branch|test(\"${author}\"))" 2>/dev/null
  else
    echo -e "${result}" | jq
  fi
}

main "$@"
