#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate 2>&1 >/dev/null || die 'deactivate failed'

nvm use iojs || die 'nvm use iojs failed'
OUTPUT="$(nvm current)"
EXPECTED_OUTPUT="iojs-v1.0.1"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use iojs' + 'nvm current' did not output '$EXPECTED_OUTPUT'; got '$OUTPUT'"

OUTPUT="$(nvm use --silent iojs)"
EXPECTED_OUTPUT=""

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --silent iojs' output was not silenced '$EXPECTED_OUTPUT'; got '$OUTPUT'"
