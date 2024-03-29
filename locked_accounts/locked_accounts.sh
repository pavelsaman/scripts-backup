#!/bin/sh

[ ! -r /etc/shadow ] && { echo "No read permission on /etc/passwd" >&2; exit 1; }

locked_accounts="$(grep '^.*:!' /etc/shadow | cut -d: -f1 | tr '\n' ' ')"
echo "${locked_accounts}"

exit 0
