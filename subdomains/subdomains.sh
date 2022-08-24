#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

die() {
  echo "Fatal: ${1}" >&2
  exit 1
}

installedAndExecutable() {
  cmd=$(command -v "${1}")

  [[ -n "${cmd}" ]] && [[ -f "${cmd}" ]] && [[ -x "${cmd}" ]]
  return ${?}
}

print_help() {
  cat<<ENDHELP
subdomains.sh [OPTIONS] <-d domain>

OPTIONS:
  -d    domain to search for, e.g. "example.com"
  -j    print to stdout in JSON format
  -s    silent, no reinfo sult output to stdout
  -h    show this help  
ENDHELP
}

deps=(curl jq httprobe)
for dep in "${deps[@]}"; do
  installedAndExecutable "${dep}" || die "Missing '${dep}' dependency or not executable"
done

domain=
tojson=false
silent=false

while getopts ":d:jsh" opt; do
  case "$opt" in
    d  ) domain="${OPTARG}"                                                     ;;
    j  ) tojson=true                                                            ;;
    s  ) silent=true                                                            ;;
    h  ) print_help; exit 0                                                     ;;
    \? ) echo "Unknown option: -${OPTARG}" >&2; exit 1                          ;;
    :  ) echo "Missing option argument for -${OPTARG}" >&2; exit 1              ;;
    *  ) echo "Unimplemented option: -${opt}. See help (-h option)" >&2; exit 1 ;;
  esac
done

if [[ -z "${domain}" ]]; then
  echo "No domain, see help (-h option)" >&2
  exit 1
fi

result_dir=~/.cache/subdomains/$(date "+%s")-"${domain}"
mkdir --parents "${result_dir}"

[[ ${silent} == false ]] && echo " [+] Getting subdomains from crt.sh..."
curl --silent "https://crt.sh/?q=${domain}&output=json" \
  | jq '.[].name_value' \
  | sed --regexp-extended 's/\\n/",\n"/g;s/"$/",/;s/[",]//g' > "${result_dir}/crt-all.txt"

[[ ${silent} == false ]] && echo " [+] Getting a unique list of domains..."
sort --unique "${result_dir}/crt-all.txt" \
  | grep --invert-match '[*]' > "${result_dir}/crt-uniq.txt"

[[ ${silent} == false ]] && echo " [+] Getting a list of alive domains..."
httprobe < "${result_dir}/crt-uniq.txt" \
  | sed --regexp-extended 's/^http(s)?:\/\///' \
  | sort --unique > "${result_dir}/alive.txt"

[[ ${silent} == false ]] && echo " [+] Results are in ${result_dir}: crt-all.txt, crt-uniq.txt, and alive.txt"

if [[ ${tojson} == true ]]; then
  [[ ${silent} == false ]] && echo " [+] alive.txt in JSON:"
  sed --regexp-extended 's/^/"/;s/$/",/;1s/^/[/;$s/,$/]/' "${result_dir}/alive.txt" | jq
else
  [[ ${silent} == false ]] && echo " [+] alive.txt in plain text:"
  cat "${result_dir}/alive.txt"
fi

exit 0