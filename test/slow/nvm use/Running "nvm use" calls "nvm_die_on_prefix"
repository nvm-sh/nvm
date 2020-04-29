#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate >/dev/null 2>&1 || die 'deactivate failed'

nvm_die_on_prefix() {
  echo >&2 "| $1 | $2 |"
  return 3
}

OUTPUT="$(nvm use --silent node)"
EXPECTED_OUTPUT=""
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --silent node' did not call through to 'nvm_die_on_prefix' and give output '$EXPECTED_OUTPUT'; got '$OUTPUT'"

EXIT_CODE="$(nvm use --silent node >/dev/null 2>&1; echo $?)"
EXPECTED_CODE="11"
[ "_$EXIT_CODE" = "_$EXPECTED_CODE" ] \
  || die "'nvm use --silent node' when 'nvm_die_on_prefix' fails did not return '$EXPECTED_CODE'; got '$EXIT_CODE'"
