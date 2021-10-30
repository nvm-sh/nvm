#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }

TEST_PATH="$PWD/test_output"
mkdir -p "$TEST_PATH"
CALL_COUNT_PATH="$TEST_PATH/call_count.txt"
: > "$CALL_COUNT_PATH"
ALIAS_ARGS_PATH="$TEST_PATH/nvm_make_alias_args.txt"
: > "$ALIAS_ARGS_PATH"

cleanup() {
  unset -f nvm_download nvm_make_alias
  rm -rf "$TEST_PATH"
}

\. ../../../nvm.sh

set -ex

MOCKS_DIR="$PWD/mocks"

# sample output at the time the test was written
TAB_PATH="$MOCKS_DIR/nodejs.org-dist-index.tab"
nvm_download() {
  cat "$TAB_PATH"
}

nvm_make_alias() {
  CALL_COUNT="$(cat "$CALL_COUNT_PATH")"
  CALL_COUNT="$((CALL_COUNT + 1))"
  echo "$CALL_COUNT" > "$CALL_COUNT_PATH"
  echo "${1}|${2}" >> "$ALIAS_ARGS_PATH"
}

nvm_ls_remote >/dev/null || die "nvm_ls_remote_failed?!"

CALL_COUNT="$(cat "$CALL_COUNT_PATH")"

LTS_LINES="$(cat "${MOCKS_DIR}/LTS_names.txt" | wc -l)"
EXPECTED_COUNT="$((LTS_LINES + 1))"
[ "$CALL_COUNT" = "$EXPECTED_COUNT" ] || die "nvm_make_alias called $CALL_COUNT times; expected $EXPECTED_COUNT"

ARGS="$(cat "$ALIAS_ARGS_PATH")"
EXPECTED_ARGS_PATH="$MOCKS_DIR/nvm_make_alias LTS alias calls.txt"
EXPECTED_ARGS="$(cat "$EXPECTED_ARGS_PATH")"
[ "${ARGS}" = "${EXPECTED_ARGS}" ] || die "nvm_make_alias called with >${ARGS}<; expected >${EXPECTED_ARGS}<"

cleanup
