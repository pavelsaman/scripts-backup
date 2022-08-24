#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${1:-}" ]]; then
  cat <<HELP
hashes <file>

Calculates sha1, sha224, sha256, sha384, sha512, md5 hashes.
HELP
  exit 1
fi

sha1=$(sha1sum "${1}" | cut -d' ' -f1)
sha224=$(sha224sum "${1}" | cut -d' ' -f1)
sha384=$(sha384sum "${1}" | cut -d' ' -f1)
sha256=$(sha256sum "${1}" | cut -d' ' -f1)
sha512=$(sha512sum "${1}" | cut -d' ' -f1)
md5=$(md5sum "${1}" | cut -d' ' -f1)

printf "%s\n\nsha1: %s\nsha224: %s\nsha256: %s\nsha384: %s\nsha512: %s\nmd5: %s\n" \
  "${1}" "${sha1}" "${sha224}" "${sha256}" "${sha384}" "${sha512}" "${md5}"

exit 0
