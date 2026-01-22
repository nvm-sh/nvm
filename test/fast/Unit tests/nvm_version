#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }
cleanup () {
  unset -f nvm_ls_current nvm_ls
}

\. ../../../nvm.sh

nvm_ls_current() {
  echo "CURRENT!"
  return 7
}

OUTPUT="$(nvm_version current)"
EXPECTED_OUTPUT="CURRENT!"
EXIT_CODE="$(nvm_version current 2>&1 >/dev/null ; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die '"nvm_version current" did not return nvm_ls_current output'
[ "_$EXIT_CODE" = "_7" ] || die '"nvm_version current" did not return nvm_ls_current exit code'

OUTPUT="$(nvm_version)"
EXPECTED_OUTPUT="CURRENT!"
EXIT_CODE="$(nvm_version 2>&1 >/dev/null ; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die '"nvm_version" did not return nvm_ls_current output'
[ "_$EXIT_CODE" = "_7" ] || die '"nvm_version" did not return nvm_ls_current exit code'

nvm_ls() {
  echo "line 1"
  echo "line 2"
  echo "pattern: $1"
}
[ "_$(nvm_version foo)" = "_pattern: foo" ] || die '"nvm_version foo" did not pass the pattern to "nvm_ls", or return the last line'
[ "_$(nvm_version node)" = "_pattern: stable" ] || die '"nvm_version node" did not pass "stable" to "nvm_ls"'
[ "_$(nvm_version node-)" = "_pattern: stable" ] || die '"nvm_version node-" did not pass "stable" to "nvm_ls"'

nvm_ls() { echo "N/A"; }
OUTPUT="$(nvm_version foo)"
EXPECTED_OUTPUT="N/A"
EXIT_CODE="$(nvm_version foo 2>&1 >/dev/null ; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die '"nvm_version" did not return N/A when nvm_ls returns N/A'
[ "_$EXIT_CODE" = "_3" ] || die '"nvm_version" returning N/A did not exit code with code 3'

nvm_ls() { echo; }
OUTPUT="$(nvm_version foo)"
EXPECTED_OUTPUT="N/A"
EXIT_CODE="$(nvm_version foo 2>&1 >/dev/null ; echo $?)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die '"nvm_version" did not return N/A when nvm_ls returns nothing'
[ "_$EXIT_CODE" = "_3" ] || die '"nvm_version" returning N/A did not exit code with code 3'
