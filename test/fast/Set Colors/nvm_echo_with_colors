#!/bin/sh

set -ex

die () {
  echo "Expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"
  exit 1
}

cleanup() {
  echo "Tested nvm_echo_with_colors"
}

\. ../../../nvm.sh

OUTPUT="$(nvm_echo_with_colors "\033[0;36mCyan-colored text")"
EXPECTED_OUTPUT=$(printf "\033[0;36mCyan-colored text")

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die

cleanup
