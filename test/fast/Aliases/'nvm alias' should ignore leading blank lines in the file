#!/bin/sh

die() { echo "$@" ; exit 1; }

export NVM_DIR="$(cd ../../.. && pwd)"

\. "${NVM_DIR}/nvm.sh"
\. ../../common.sh

echo "

v0.0.1
" > ../../../alias/test-blank-lines

EXPECTED='v0.0.1'
ACTUAL="$(nvm_alias test-blank-lines)"
EXIT_CODE="$(nvm_alias test-blank-lines 2>&1 >/dev/null; echo $?)"

[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
[ "${EXIT_CODE}" = '0' ] || die "expected exit code 0, got ${EXIT_CODE}"
