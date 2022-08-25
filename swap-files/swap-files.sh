#!/bin/sh

[ $# -ne 2 ] && { echo "Params not given." >&2; exit 1; }
[ ! -f "${1}" ] && { echo "File ${1} does not exist" >&2; exit 1; }
[ ! -f "${2}" ] && { echo "File ${2} does not exist" >&2; exit 1; }

cp -p "$1" "$1".swap
if ! diff "$1" "$1".swap > /dev/null 2>&1 ; then
  echo "$1 wrongly copied, aborting." 1>&2
  exit 1
fi
cp -p "${2}" "${1}"
cp -p "${1}".swap "${2}"
if [ -f "${1}" ] && [ -f "${2}" ]; then
  rm "${1}".swap
fi

exit 0
