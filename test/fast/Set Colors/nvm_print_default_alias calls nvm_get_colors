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

# nvm_print_default_alias call nvm_print_formatted_alias which calls nvm_get-colors
# the output of nvm_print_default_alias uses the color code returned by nvm_get_colors (redefined above)
OUTPUT=$(command printf %b $(nvm_print_default_alias node ./alias v14.7.0) | awk '{ print substr($0, 1, 11); }')
EXPECTED_OUTPUT=$(command printf %b "\033[0;95mnode")

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die

set +e
