#!/bin/sh

cleanup() { unset -f nvm_ls_current nvm; }
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

nvm_ls_current() { echo foo; }

nvm() {
  echo "nvm: $@"
}

OUTPUT="$(nvm_use_if_needed foo)"
EXPECTED_OUTPUT=''

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"

OUTPUT="$(nvm_use_if_needed bar)"
EXPECTED_OUTPUT='nvm: use bar'

[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"

cleanup
