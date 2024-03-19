#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

die () { echo "$@" ; unset -f nvm_ls nvm_list_aliases; exit 1; }

set -e

OUTPUT="$(nvm ls --no-colors --no-alias pattern 2>&1 ||:)"
EXPECTED_OUTPUT='`--no-alias` is not supported when a pattern is provided.'
EXIT_CODE="$(nvm ls --no-colors --no-alias pattern >/dev/null 2>&1 || echo $?)"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"

[ "${EXIT_CODE}" = 55 ] || die "expected 55; got >${EXIT_CODE}<"
