#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset -f nvm_has
}

\. ../../../nvm.sh

nvm_has() { return 1 ; }

OUTPUT="$(nvm_get_latest 2>&1)"
EXIT_CODE="$(nvm_get_latest >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_nvm needs curl or wget to proceed." ] \
  || die "no curl/wget did not report correct error message, got '$OUTPUT'"
[ "_$EXIT_CODE" = "_1" ] \
  || die "no curl/wget did not exit with code 1, got $EXIT_CODE"

cleanup
