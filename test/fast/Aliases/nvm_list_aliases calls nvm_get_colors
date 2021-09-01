#!/bin/sh

\. ../../../nvm.sh

die () { echo "$@" ; exit 1; }

set -e

nvm_get_colors(){
  echo "0;95m"
}

nvm_alias_path() {
  nvm_echo "../../../alias"
}

OUTPUT=$(command printf %b $(nvm_list_aliases test-stable-1) | awk '{ print substr($0, 1, 19); }')

EXPECTED_OUTPUT=$(command printf %b "\033[0;95mtest-stable-1" | awk '{ print substr($0, 1, 19); }')
echo "\033[0m"

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "nvm_list_aliases did not call nvm_get_colors. Expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"
