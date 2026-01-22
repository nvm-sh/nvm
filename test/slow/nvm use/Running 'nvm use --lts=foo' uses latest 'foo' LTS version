#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate 2>&1 >/dev/null || die 'deactivate failed'

nvm use --lts=testing || die 'nvm use --lts=testing failed'
OUTPUT="$(nvm current)"
EXPECTED_OUTPUT="$(nvm_resolve_alias 'lts/testing')"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --lts=testing' + 'nvm current' did not output '$EXPECTED_OUTPUT'; got '$OUTPUT'"

OUTPUT="$(nvm use --silent --lts=testing)"
EXPECTED_OUTPUT=""

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --silent --lts=testing' output was not silenced '$EXPECTED_OUTPUT'; got '$OUTPUT'"
