#!/bin/sh

\. ../../../nvm.sh

die () {
  # echo "$@" ;
  echo "Expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"
  exit 1
}

set -e

nvm_get_colors(){
  echo "0;95m"
}

# nvm_print_alias_path call nvm_print_formatted_alias which calls nvm_get-colors
# the output of nvm_print_alias_path uses the color code returned by nvm_get_colors (redefined above)
NVM_ALIAS_DIR='../../../alias'

OUTPUT=$(command printf %b $(nvm_print_alias_path "$NVM_ALIAS_DIR" "$NVM_ALIAS_DIR"/test-stable-1) | awk '{ print substr($0, 1, 24); }')

EXPECTED_OUTPUT=$(command printf %b "\033[0;95mtest-stable-1\033[0m")

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die


set +e
