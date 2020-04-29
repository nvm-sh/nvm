#!/bin/sh

cleanup () {
  alias nvm_has='\nvm_has'
  alias npm='\npm'
  unset -f nvm_has npm
}
die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm_has() { return 1; }
OUTPUT="$(nvm_print_npm_version)"
[ -z "$OUTPUT" ] || die "nvm_print_npm_version did not return empty when nvm_has returns 1, got '$OUTPUT'"

nvm_has() { return 0; }
npm() {
  if [ "_$@" = "_--version" ]; then
    echo "1.2.3"
  else
    echo "error"
  fi
}
OUTPUT="$(nvm_print_npm_version)"
EXPECTED_OUTPUT=" (npm v1.2.3)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_print_npm_version did not provided '$EXPECTED_OUTPUT', got '$OUTPUT'"

cleanup
