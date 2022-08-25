#!/bin/sh

[ $# = 0 ] && { echo "repeat <num> [char]" >&2; exit 1; }

char=#
[ $# = 2 ] && char="${2}"

i=0
result=
while [ "${i}" -ne "${1}" ]; do
  i=$((i + 1))
  result="${result}${char}"
done

echo "${result}"

exit 0
