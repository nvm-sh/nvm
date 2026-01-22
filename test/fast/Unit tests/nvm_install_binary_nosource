#!/bin/sh

cleanup () {
  nvm cache clear
  nvm deactivate
  rm -rf ${NVM_DIR}/v*
  nvm unalias default
}

die () { echo "$@" ; cleanup; exit 1;}

\. ../../../nvm.sh

nvm_binary_available() {
    return 1
}

# Unit test to check if the function errors out when the flag is set
OUTPUT="$(nvm_install_binary node std 8.0.0 1 2>&1)"
EXPECTED_OUTPUT='Binary download failed. Download from source aborted.'
if [ "${OUTPUT#*$EXPECTED_OUTPUT}" = "${OUTPUT}" ]; then
  die "No source binary flag is active and should have returned >${EXPECTED_OUTPUT}<. Instead it returned >${OUTPUT}<"
fi

# Unit test to check if the function errors out when the flag is set
OUTPUT="$(nvm_install_binary node std 8.0.0 0 2>&1)"
EXPECTED_OUTPUT='Binary download failed. Download from source aborted.'
if [ "${OUTPUT#*$EXPECTED_OUTPUT}" != "${OUTPUT}" ]; then
  die "No source binary flag is not active and should have downloaded from source. Instead it returned >${OUTPUT}<"
fi
