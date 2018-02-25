#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset -f nvm_download
}

\. ../../../nvm.sh

# sample output at the time the test was written
TAB_PATH="$PWD/mocks/iojs.org-dist-index.tab"
nvm_download() {
  cat "$TAB_PATH"
}

EXPECTED_OUTPUT_PATH="$PWD/mocks/nvm_ls_remote_iojs.txt"

OUTPUT="$(nvm_ls_remote_iojs foo)"
EXIT_CODE="$(nvm_ls_remote_iojs foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_N/A" ] || die "nonexistent version did not report N/A"
[ "_$EXIT_CODE" = "_3" ] || die "nonexistent version did not exit with code 3, got $EXIT_CODE"

OUTPUT="$(nvm_ls_remote_iojs)"
EXPECTED_OUTPUT="$(cat "$EXPECTED_OUTPUT_PATH")"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "bare nvm_ls_remote_iojs did not output expected sorted versions; got $(echo ">$OUTPUT<") expected $(echo ">$EXPECTED_OUTPUT<")"

OUTPUT="$(nvm_ls_remote_iojs 1.0)"
EXPECTED_OUTPUT="iojs-v1.0.0
iojs-v1.0.1
iojs-v1.0.2
iojs-v1.0.3
iojs-v1.0.4"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_ls_remote_iojs 1.0 did not output 1.0.x versions; got $OUTPUT"

cleanup
