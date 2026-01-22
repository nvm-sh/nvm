#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  unset -f nvm_download
}

\. ../../../nvm.sh

MOCKS_DIR="$PWD/mocks"

# sample output at the time the test was written
TAB_PATH="$MOCKS_DIR/nodejs.org-download-nightly-index.tab"
nvm_download() {
  cat "$TAB_PATH"
}

EXPECTED_OUTPUT_PATH="$MOCKS_DIR/nvm_ls_remote nightly.txt"

OUTPUT="$(nvm_ls_remote foo)"
EXIT_CODE="$(nvm_ls_remote foo >/dev/null 2>&1 ; echo $?)"
[ "_$OUTPUT" = "_N/A" ] || die "nonexistent version did not report N/A"
[ "_$EXIT_CODE" = "_3" ] || die "nonexistent version did not exit with code 3, got $EXIT_CODE"

OUTPUT="$(nvm_ls_remote)"
EXPECTED_OUTPUT="$(cat "$EXPECTED_OUTPUT_PATH")"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "bare nvm_ls_remote did not output expected sorted versions; got $(echo ">$OUTPUT<") expected $(echo ">$EXPECTED_OUTPUT<")"

OUTPUT="$(nvm_ls_remote 11)"
EXPECTED_OUTPUT="v11.0.0-nightly201810011be804d625
v11.1.0-nightly20181101af6d26281f"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_ls_remote 11 did not output v11 nightly versions; got $OUTPUT"

# Sanity checks
OUTPUT="$(nvm_print_implicit_alias remote stable)"
EXPECTED_OUTPUT_PATH="${MOCKS_DIR}/nvm_print_implicit_alias remote stable nightly.txt"
EXPECTED_OUTPUT="$(cat "${EXPECTED_OUTPUT_PATH}")"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_print_implicit_alias remote stable did not output $EXPECTED_OUTPUT; got $OUTPUT"

OUTPUT="$(nvm_print_implicit_alias remote unstable)"
EXPECTED_OUTPUT="N/A"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_print_implicit_alias remote unstable did not output |$EXPECTED_OUTPUT|; got |$OUTPUT|"

OUTPUT="$(nvm_ls_remote stable)"
EXPECTED_OUTPUT_PATH="${MOCKS_DIR}/nvm_ls_remote stable nightly.txt"
EXPECTED_OUTPUT="$(cat "${EXPECTED_OUTPUT_PATH}")"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_ls_remote stable did not output $EXPECTED_OUTPUT; got $OUTPUT"

OUTPUT="$(nvm_ls_remote unstable)"
EXPECTED_OUTPUT="N/A"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_ls_remote unstable did not output |$EXPECTED_OUTPUT|; got |$OUTPUT|"

EXPECTED_OUTPUT_PATH="$MOCKS_DIR/nvm_ls_remote LTS nightly.txt"
EXPECTED_OUTPUT="$(cat "$EXPECTED_OUTPUT_PATH")"
OUTPUT="$(NVM_LTS='*' nvm_ls_remote)"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "\`NVM_LTS='*' nvm_ls_remote\` did not output >$EXPECTED_OUTPUT<; got >$OUTPUT<"

EXPECTED_OUTPUT_PATH="$MOCKS_DIR/nvm_ls_remote LTS nightly argon.txt"
EXPECTED_OUTPUT="$(cat "$EXPECTED_OUTPUT_PATH")"
OUTPUT="$(NVM_LTS=argon nvm_ls_remote)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "\`NVM_LTS=argon nvm_ls_remote\` did not output >$EXPECTED_OUTPUT<; got >$OUTPUT<"

cleanup
