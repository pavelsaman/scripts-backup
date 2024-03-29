#!/bin/sh

# cleanconfig
#  deletes commented lines and creates a new .clean file

[ -z "${1}" ] && { echo 'Enter config file.' >&2; exit 1; }

touch "${1}.clean"
sed -f "${SEDSCR}/delcom" "${1}" >> "${1}.clean"

exit 0
