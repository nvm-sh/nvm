#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate >/dev/null 2>&1 || die 'deactivate failed'

nvm use --lts || die 'nvm use --lts failed'
OUTPUT="$(nvm current)"
EXPECTED_OUTPUT="$(nvm_resolve_alias 'lts/*')"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --lts' + 'nvm current' did not output '$EXPECTED_OUTPUT'; got '$OUTPUT'"

OUTPUT="$(nvm use --silent --lts)"
EXPECTED_OUTPUT=""

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --silent --lts' output was not silenced '$EXPECTED_OUTPUT'; got '$OUTPUT'"
