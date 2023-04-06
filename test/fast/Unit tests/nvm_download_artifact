#!/bin/sh

cleanup () {
  unset -f nvm_get_mirror
}
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

# bad flavor
ACTUAL="$(nvm_download_artifact 2>&1)"
CODE="$(nvm_download_artifact >/dev/null 2>&1 ; echo $?)"
EXPECTED='supported flavors: node, iojs'
EXPECTED_CODE=1

[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
[ "${CODE}" = $EXPECTED_CODE ] || die "expected exit code ${EXPECTED_CODE}, got ${CODE}"

# bad kind
ACTUAL="$(nvm_download_artifact node 2>&1)"
CODE="$(nvm_download_artifact node >/dev/null 2>&1 ; echo $?)"
EXPECTED='supported kinds: binary, source'
EXPECTED_CODE=1

[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
[ "${CODE}" = $EXPECTED_CODE ] || die "expected exit code ${EXPECTED_CODE}, got ${CODE}"

# bad type
ACTUAL="$(nvm_download_artifact node binary nonexistentType 2>&1)"
CODE="$(nvm_download_artifact node binary nonexistentType >/dev/null 2>&1 ; echo $?)"
EXPECTED='unknown type of node.js or io.js release'
EXPECTED_CODE=2

[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
[ "${CODE}" = $EXPECTED_CODE ] || die "expected exit code ${EXPECTED_CODE}, got ${CODE}"

# no version
ACTUAL="$(nvm_download_artifact node binary std 2>&1)"
CODE="$(nvm_download_artifact node binary std >/dev/null 2>&1 ; echo $?)"
EXPECTED='A version number is required.'
EXPECTED_CODE=3

[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
[ "${CODE}" = $EXPECTED_CODE ] || die "expected exit code ${EXPECTED_CODE}, got ${CODE}"

# binary type, version without binary available
VERSION=0.8.5
ACTUAL="$(nvm_download_artifact node binary std ${VERSION} 2>&1)"
CODE="$(nvm_download_artifact node binary std ${VERSION} >/dev/null 2>&1 ; echo $?)"
EXPECTED="No precompiled binary available for ${VERSION}."
EXPECTED_CODE=0

[ "${ACTUAL}" = "${EXPECTED}" ] || die "expected >${EXPECTED}<, got >${ACTUAL}<"
[ "${CODE}" = $EXPECTED_CODE ] || die "expected exit code ${EXPECTED_CODE}, got ${CODE}"

