#!/usr/bin/env bash

set -euo pipefail

function help() {
  cat <<END
cutstr <str> [a] [b]

Keep substring of str from a to b.
Argument a is optional, if not provided, 0 will be assigned to a.
Argument b is optional, if not provided, str length will be assigned to b.
END
}

function check_inputs() {
  local str="${1-}"
  local a="${2-}"
  local b="${3-}"

  [[ -z "$a" ]] && { printf '%s\n' "No a provided."; exit 1; }
  [[ ! "$a" =~ [0-9]+ ]] && { printf '%s\n' "a is not a number."; exit 1; }
  (( a < 0 )) && { printf '%s\n' "Negative indices of a are not supported."; exit 1; }

  [[ -z "$b" ]] && { printf '%s\n' "No b provided."; exit 1; }
  [[ ! "$b" =~ [0-9]+ ]] && { printf '%s\n' "b is not a number."; exit 1; }
  (( b < 0 )) && { printf '%s\n' "Negative indices of b are not supported."; exit 1; }

  [[ -z "$str" ]] && { printf '%s\n' "No str provided."; exit 1; }

  return 0
}

function main() {
  local str="${1-}"
  local a="${2-0}"
  local b="${3-${#str}}"

  [[ "$str" == "-h" || "$str" == "--help" || "$str" == "-help" ]] && { help; exit 0; }
  check_inputs "$str" "$a" "$b"

  printf '%s\n' "${str:$a:$b}"
}

main "$@"
