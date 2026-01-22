#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm_install_source() {
  exit 42
}

VERSION="0.7.0"

EXIT_CODE=$(nvm install -b "${VERSION}" ; echo $?)

[ $EXIT_CODE -eq 3 ] || die "Expected exit code 3, got ${EXIT_CODE}"

ACTUAL="$(nvm install -b "${VERSION}" 2>&1)"
EXPECTED="Binary download is not available for v${VERSION}"

[ "${ACTUAL}" = "${EXPECTED}" ] || die "Expected >${EXPECTED}<, got >${ACTUAL}<"
