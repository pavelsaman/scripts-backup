#!/usr/bin/env bash

declare -a char_set=()
declare -i length=16

print_usage() {
  cat <<END_USAGE
Usage: gen [-c] [-d] [-s] [-l <lengh>] [-p] [-o] [-1] [-3] [-u] [-h]
END_USAGE
}

print_help() {
  print_usage
  cat <<END_HELP

Options:
  -c             Include [a-zA-Z] characters
  -d             Include numbers [0-9]
  -s             Include special characters [+-?:@&#!*=()[]{}%]
  -p             Create a passphrase of -l <length> words
  -l <length>    Choose a length of the result string
  -o             Print to stdout
  -1             Copy the result string into p selection using xclip
  -3             Copy the result string into c selection using xclip
  -u|-usage      Print usage line
  -h|-help       Print this help
END_HELP
}

# xclip has to be installed so we can talk to clipboards
# $DISPLAY has to be non-zero
check_requirements() {
	local -i proceed=0
	
  xclip -version >/dev/null 2>&1 || proceed=1
	[[ -n "${DISPLAY}" ]] || proceed=1
	
  return "${proceed}"
}

add_chars() {
	char_set+=({a..z})
	char_set+=({A..Z})
}

add_digits() {
	char_set+=({0..9})
}

add_schars() {
	char_set+=('+' '-' '?' ':' '@' '&' '#' '!' '*' '=' '(' ')' '[' ']' '{' '}' '%')
}

gen_random() {
	local n
	local pass
	while (( length > ${#pass} )); do
		n=$((RANDOM % ${#char_set[@]}))
		pass="${pass}${char_set[n]}"
	done
	echo "${pass}"
}

# create a passphrase out of an English dictionary of words
# it looks for a dictionary in this directory
create_passphrase() {
  local dict="/usr/share/gen-dictionary/dictionary"
  local last_line
  last_line=$(/bin/wc -l "${dict}" | /bin/cut -d' ' -f1)
  local bucket_size=32767
  local num_of_buckets=$((last_line / bucket_size))
  local last_bucket_size=$(((num_of_buckets * bucket_size - last_line) * -1))
  local num_of_words=0
  local passphrase

	while (( length > num_of_words )); do
    selected_bucket=$((RANDOM % (num_of_buckets + 1)))
random_in_bucket=$((RANDOM % bucket_size))
    (( selected_bucket = num_of_buckets )) && random_in_bucket=$((RANDOM % last_bucket_size))
    offset=$((selected_bucket * bucket_size))
    selected_line=$((offset + 1 + random_in_bucket))
    word=$(/bin/head -${selected_line} ${dict} | /bin/tail -1 | /bin/tr -d '\n' | /bin/tr '[:upper:]' '[:lower:]')
    word="${word} "
    passphrase="${passphrase}${word}"
    ((num_of_words++))
  done
  echo "${passphrase}"
}

main() {
  if ! check_requirements ; then
    echo "xclip not present or there is no DISPLAY variable" 1>&2
    exit 1
  fi
  
  local print=false
  local primary=false
  local clipboard=false
  local only_passphrase=false

  while getopts "l:pcdso13uh" opt; do
    case "${opt}" in
      l) length="${OPTARG}"   ;;
      p) only_passphrase=true ;;
      c) add_chars            ;;
      d) add_digits           ;;
      s) add_schars           ;;
      o) print=true           ;;
      1) primary=true         ;;
      3) clipboard=true       ;;
      u)
        print_usage
        exit 0
        ;;
      h)
        print_help
        exit 0
        ;;
      *)
        print_help
        exit 1
        ;;
    esac
  done

  # some options are required
  if (( ${#char_set[@]} == 0 )) && [[ "${only_passphrase}" = false ]]; then
    print_usage >&2
    exit 1
  fi

  # get string
  [[ "${only_passphrase}" = false ]] && result_string="$(gen_random)" || result_string="$(create_passphrase)"

  # print to the tty
  [[ "${print}" = true ]] && echo "${result_string}"
  # put into selections
  [[ "${primary}" = true ]] && echo -n "${result_string}" | xclip -selection p
  [[ "${clipboard}" = true ]] && echo -n "${result_string}" | xclip -selection c
  # if neither -1 nor -3 are specified, place only into clipboard
  if [[ "${primary}" = false ]] && [[ "${clipboard}" = false ]]; then
    echo -n "${result_string}" | xclip -selection c
  fi
}

main "$@"
