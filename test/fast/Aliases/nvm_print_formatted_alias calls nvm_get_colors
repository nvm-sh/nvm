#!/bin/sh

\. ../../../nvm.sh

die () {
  echo "Expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"
  exit 1
}

set -e
# # # expecting in red and two grays:
OUTPUT=$(echo $(nvm_print_formatted_alias fakealias fakedest) | awk '{ print substr($0, 1, 21); }')
EXPECTED_OUTPUT="$(command printf %b "\033[0;31mfakealias\033[0m ")"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die

# expecting in bold yellow and two grays:
nvm set-colors bbbYb
OUTPUT=$(echo $(nvm_print_formatted_alias fakealias fakedest) | awk '{ print substr($0, 1, 21); }')
EXPECTED_OUTPUT="$(command printf %b "\033[1;33mfakealias\033[0m ")"

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die
