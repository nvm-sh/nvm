#!/bin/sh
\. ../../common.sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup () {
  unset -f nvm_alias nvm_version
}

\. ../../../nvm.sh

NVM_ALIAS_DIR='path/to/the alias/dir'

OUTPUT="$(nvm_print_alias_path 2>&1)"
EXPECTED_OUTPUT='An alias dir is required.'
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "'nvm_print_alias_path' produced wrong output; got '$OUTPUT', expected '$EXPECTED_OUTPUT'"

OUTPUT="$(nvm_print_alias_path "$NVM_ALIAS_DIR" 2>&1)"
EXPECTED_OUTPUT='An alias path is required.'
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "'nvm_print_alias_path \"\$NVM_ALIAS_DIR\"' produced wrong output; got '$OUTPUT', expected '$EXPECTED_OUTPUT'"

nvm_alias() {
  echo ''
}

OUTPUT="$(nvm_print_alias_path "$NVM_ALIAS_DIR" foo | strip_colors)"
EXPECTED_OUTPUT=''
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "'nvm_print_alias_path \"\$NVM_ALIAS_DIR\" foo' should produce no output when nvm_alias does not; got '$OUTPUT'"

EXIT_CODE="$(nvm_print_alias_path "$NVM_ALIAS_DIR" foo >/dev/null 2>&1 ; echo $?)"
[ "$EXIT_CODE" = '0' ] || die "'nvm_print_alias_path \"\$NVM_ALIAS_DIR\" foo' should exit zero when nvm_alias produces no output; got $EXIT_CODE"

nvm_alias() {
  echo "\"$1\""
}
nvm_version() {
  echo "v$1"
}

OUTPUT="$(nvm_print_alias_path "$NVM_ALIAS_DIR" "$NVM_ALIAS_DIR/blah" | strip_colors)"
EXPECTED_OUTPUT='blah -> "blah" (-> v"blah")'
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "'nvm_print_alias_path \"\$NVM_ALIAS_DIR\" \"\$NVM_ALIAS_DIR/blah\"' should strip alias dir and print nvm_alias output; got '$OUTPUT', expected '$EXPECTED_OUTPUT'"

cleanup
