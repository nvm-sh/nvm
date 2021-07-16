#!/bin/sh
\. ../../common.sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup () {
  unset -f nvm_print_implicit_alias nvm_version
}

\. ../../../nvm.sh

nvm_print_implicit_alias() {
  echo ''
}

OUTPUT="$(nvm_print_default_alias 2>&1)"
EXPECTED_OUTPUT='A default alias is required.'
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "'nvm_print_default_alias' produced wrong output; got '$OUTPUT', expected '$EXPECTED_OUTPUT'"

OUTPUT="$(nvm_print_default_alias foo | strip_colors)"
EXPECTED_OUTPUT=''
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_print_default_alias foo' should produce no output when nvm_print_implicit_alias does not; got '$OUTPUT'"

EXIT_CODE="$(nvm_print_default_alias foo >/dev/null 2>&1 ; echo $?)"
[ "$EXIT_CODE" = '0' ] || die "'nvm_print_default_alias foo' should exit zero when nvm_print_implicit_alias produces no output; got $EXIT_CODE"

nvm_print_implicit_alias() {
  echo "\"$1-$2\""
}
nvm_version() {
  echo "v$1"
}

OUTPUT="$(nvm_print_default_alias blah | strip_colors)"
EXPECTED_OUTPUT='blah -> "local-blah" (-> v"local-blah") (default)'
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "'nvm_print_default_alias blah' should strip alias dir and print nvm_print_implicit_alias output; got '$OUTPUT', expected '$EXPECTED_OUTPUT'"

cleanup
