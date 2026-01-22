#!/bin/sh

set -ex

\. ../common.sh

die () { echo "$@" ; cleanup ; exit 1; }

VERSION="v3.99.0"

cleanup() {
  unset -f make_echo cleanup
  rm -rf "$(nvm_version_path "iojs-${VERSION}")"
}

\. ../../nvm.sh

nvm deactivate || die "unable to deactivate; current: >$(nvm current)<"

make_fake_iojs "${VERSION}" || die "unable to make_fake_iojs ${VERSION}"

IOJS_VERSION="$(nvm_version iojs)"
[ -n "${IOJS_VERSION}" ] || die 'expected an io.js version; got none'

EXPECTED_OUTPUT="$(nvm_add_iojs_prefix ${VERSION})"
[ "${IOJS_VERSION}" = "${EXPECTED_OUTPUT}" ] || die "iojs version was not >${EXPECTED_OUTPUT}; got >${IOJS_VERSION}<"

nvm use --delete-prefix iojs || die '`nvm use iojs` failed'

# Remove node_modules/.bin from the path so that the system version `which` is
# used in nvm_ls_current
PATH=$(echo "$PATH" | tr ":" "\n" | grep -v "node_modules/.bin" | tr "\n" ":") CURRENT="$(nvm current)"
echo "current: ${CURRENT}"

[ "${CURRENT}" = "${IOJS_VERSION}" ] || die "expected >${IOJS_VERSION}<; got >${CURRENT}<"

cleanup
