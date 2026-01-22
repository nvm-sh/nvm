#!/bin/sh

set -ex

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset -f nvm_remote_version
}

\. ../../../nvm.sh

\. ../../common.sh

nvm_remote_version() {
  echo "NVM_VERSION_ONLY:${NVM_VERSION_ONLY-},NVM_LTS:${NVM_LTS-},PATTERN:${PATTERN-}"
}

OUTPUT="$(nvm version-remote foo)"
EXPECTED_OUTPUT='NVM_VERSION_ONLY:true,NVM_LTS:,PATTERN:foo'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm version-remote foo\` called nvm_remote_version with >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

OUTPUT="$(nvm version-remote --lts foo)"
EXPECTED_OUTPUT='NVM_VERSION_ONLY:true,NVM_LTS:*,PATTERN:foo'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm version-remote --lts foo\` called nvm_remote_version with >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

OUTPUT="$(nvm version-remote foo --lts)"
EXPECTED_OUTPUT='NVM_VERSION_ONLY:true,NVM_LTS:*,PATTERN:foo'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm version-remote foo --lts\` called nvm_remote_version with >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

OUTPUT="$(nvm version-remote --lts=argon foo)"
EXPECTED_OUTPUT='NVM_VERSION_ONLY:true,NVM_LTS:argon,PATTERN:foo'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm version-remote --lts=argon foo\` called nvm_remote_version with >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

OUTPUT="$(nvm version-remote lts/foo)"
EXPECTED_OUTPUT='NVM_VERSION_ONLY:true,NVM_LTS:foo,PATTERN:'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm version-remote lts/foo\` called nvm_remote_version with >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

OUTPUT="$(nvm version-remote 'lts/*')"
EXPECTED_OUTPUT='NVM_VERSION_ONLY:true,NVM_LTS:*,PATTERN:'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm version-remote lts/*\` called nvm_remote_version with >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

set +ex # needed for stderr
OUTPUT="$(nvm version-remote --foo bar 2>&1)"
set -ex
EXPECTED_OUTPUT='Unsupported option "--foo".'
EXIT_CODE="$(nvm version-remote --foo bar >/dev/null 2>&1 && echo $? || echo $?)"
[ "${EXIT_CODE}" = 55 ] || die "\`nvm version-remote --foo bar\` did not exit with code 55, got >${EXIT_CODE}<"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm version-remote --foo bar\` errored with >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

cleanup
