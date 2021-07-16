#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

OUTPUT="$(nvm_make_alias 2>&1)"
EXIT_CODE="$(nvm_make_alias >/dev/null 2>&1 ; echo $?)"
EXPECTED_OUTPUT='an alias name is required'

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "\`nvm_make_alias\` did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "$EXIT_CODE" -eq 1 ] || die "\`nvm_make_alias\` did not exit with 1, got '$EXIT_CODE'"

OUTPUT="$(nvm_make_alias foo 2>&1)"
EXIT_CODE="$(nvm_make_alias foo >/dev/null 2>&1 ; echo $?)"
EXPECTED_OUTPUT='an alias target version is required'

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "\`nvm_make_alias foo\` did not error with '$EXPECTED_OUTPUT'; got '$OUTPUT'"
[ "$EXIT_CODE" -eq 2 ] || die "\`nvm_make_alias foo\` did not exit with 2, got '$EXIT_CODE'"
