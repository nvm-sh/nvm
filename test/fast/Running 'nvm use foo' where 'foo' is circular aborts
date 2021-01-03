#!/bin/sh

set -ex

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  rm -rf "$(nvm_alias_path)/foo"
}

\. ../../nvm.sh

nvm_make_alias foo foo

set +ex # needed for stderr
OUTPUT="$(nvm use foo 2>&1)"
set -ex
EXPECTED_OUTPUT='The alias "foo" leads to an infinite loop. Aborting.'
[ "_${OUTPUT}" = "_${EXPECTED_OUTPUT}" ] \
  || die "'nvm use foo' did not output >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"

set +ex # needed for stderr
EXIT_CODE="$(nvm use foo 2>/dev/null ; echo $?)"
set -ex
[ "_$EXIT_CODE" = "_8" ] || die "Expected exit code 8; got ${EXIT_CODE}"

set +ex # needed for stderr
OUTPUT="$(nvm use --silent foo 2>&1)"
set -ex
EXPECTED_OUTPUT=''
[ "_${OUTPUT}" = "_${EXPECTED_OUTPUT}" ] \
  || die "'nvm use --silent foo' did not output >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"

set +ex # needed for stderr
EXIT_CODE="$(nvm use --silent foo 2>/dev/null ; echo $?)"
set -ex
[ $EXIT_CODE -eq 8 ] || die "Expected exit code 8 from 'nvm use --silent foo'; got ${EXIT_CODE}"

cleanup
