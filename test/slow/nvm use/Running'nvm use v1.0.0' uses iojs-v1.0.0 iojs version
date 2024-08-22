#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate 2>&1 >/dev/null || die 'deactivate failed'

nvm use 'v1.0.0' || die 'nvm use v1.0.0 failed'
OUTPUT="$(nvm current)"
EXPECTED_OUTPUT="$(nvm_version v1.0.0)"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use v1.0.0' + 'nvm current' did not output '$EXPECTED_OUTPUT'; got '$OUTPUT'"

OUTPUT="$(nvm use --silent 'v1.0.0')"
EXPECTED_OUTPUT=""

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --silent v1.0.0' output was not silenced '$EXPECTED_OUTPUT'; got '$OUTPUT'"
