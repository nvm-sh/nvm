#!/bin/sh

\. ../../../nvm.sh

set -e

die () {
  # echo "$@" ;
  echo "Expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"
  exit 1
}
cleanup() {
  if [ -n TEMP_NVM_COLORS ]; then
    export NVM_COLORS=TEMP_NVM_COLORS
  fi
  unset TEMP_NVM_COLORS
}

if [ -n ${NVM_COLORS} ]; then
  export TEMP_NVM_COLORS=NVM_COLORS
  unset NVM_COLORS
fi

# default system color
nvm use system
OUTPUT=$(nvm_print_versions system)
FORMAT="\033[0;32m-> %12s\033[0m"
VERSION='system'
EXPECTED_OUTPUT=$(command printf -- "${FORMAT}\\n" "${VERSION}")

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die

nvm_ls_current() { echo "current";}

# default current color
OUTPUT=$(nvm_print_versions current)
FORMAT="\033[0;32m-> %12s\033[0m"
VERSION="current"
EXPECTED_OUTPUT=$(command printf -- "${FORMAT}\\n" "${VERSION}")

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die

# custom current color
nvm set-colors YCMGR
OUTPUT=$(nvm_print_versions current)
FORMAT="\033[1;35m-> %12s\033[0m"
VERSION="current"
EXPECTED_OUTPUT=$(command printf -- "${FORMAT}\\n" "${VERSION}")

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die

cleanup
