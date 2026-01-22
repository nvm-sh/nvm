#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate 2>&1 >/dev/null || die 'deactivate failed'

OUTPUT=$(nvm use node --silent || die 'nvm use node failed')
EXPECTED_OUTPUT=""

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use node --silent' output was not silenced to '$EXPECTED_OUTPUT'; got '$OUTPUT'"
