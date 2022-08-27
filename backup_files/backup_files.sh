#!/bin/sh

suffix=BACKUP--"$(date +%Y-%m-%d-%H%M)"

show_help() {
  cat <<END_HELP
backup-files <file>...
END_HELP
}

[ $# = 0 ] && { show_help; exit 1; };

for file; do
  echo "Copying ${file} to ${file}.${suffix}"
  cp -p "${file}" "${file}.${suffix}"
done

exit 0
