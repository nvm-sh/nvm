#!/bin/sh

\. ../../common.sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

EXPECTED_OUTPUT="nvm_ensure_default_set: a version is required"
OUTPUT="$(nvm_ensure_default_set 2>&1 >/dev/null)"
EXIT_CODE="$?"
[ "_$(echo "$OUTPUT" | strip_colors)" = "_$EXPECTED_OUTPUT" ] || die "'nvm_ensure_default_set' did not output "$EXPECTED_OUTPUT", got "$OUTPUT""
[ "_$EXIT_CODE" = "_1" ] || die "'nvm_ensure_default_set' did not exit with 1, got "$EXIT_CODE""

# see test/fast/Aliases for remaining nvm_ensure_default_set tests
