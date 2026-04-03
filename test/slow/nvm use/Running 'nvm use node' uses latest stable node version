#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate 2>&1 >/dev/null || die 'deactivate failed'

nvm use node || die 'nvm use node failed'
OUTPUT="$(nvm current)"
EXPECTED_OUTPUT="$(nvm_version stable)"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use node' + 'nvm current' did not output '$EXPECTED_OUTPUT'; got '$OUTPUT'"

OUTPUT="$(nvm use --silent node)"
EXPECTED_OUTPUT=""

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --silent node' output was not silenced '$EXPECTED_OUTPUT'; got '$OUTPUT'"
