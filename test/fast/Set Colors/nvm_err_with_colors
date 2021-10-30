#!/bin/sh

set -ex

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  echo "Tested nvm_err_with_colors"
}

\. ../../../nvm.sh

set +ex
OUTPUT="$(nvm_err_with_colors "\033[0;35mMagenta-colored text" 2>&1)"
set -ex
EXPECTED_OUTPUT=$(printf "\033[0;35mMagenta-colored text")
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die

cleanup
