#!/bin/sh

\. ../../../nvm.sh

die () { echo "$@" ; exit 1; }

OUTPUT="$(nvm alias foo/bar baz 2>&1)"
EXPECTED_OUTPUT="Aliases in subdirectories are not supported."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to create an alias with a slash should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

EXIT_CODE="$(nvm alias foo/bar baz >/dev/null 2>&1 ; echo $?)"
[ "$EXIT_CODE" = "1" ] || die "trying to create an alias with a slash should fail with code 1, got '$EXIT_CODE'"

OUTPUT="$(nvm alias foo/ baz 2>&1)"
EXPECTED_OUTPUT="Aliases in subdirectories are not supported."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to create an alias ending with a slash should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

EXIT_CODE="$(nvm alias foo/ baz >/dev/null 2>&1 ; echo $?)"
[ "$EXIT_CODE" = "1" ] || die "trying to create an alias ending with a slash should fail with code 1, got '$EXIT_CODE'"

OUTPUT="$(nvm alias /bar baz 2>&1)"
EXPECTED_OUTPUT="Aliases in subdirectories are not supported."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to create an alias starting with a slash should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

EXIT_CODE="$(nvm alias /bar baz >/dev/null 2>&1 ; echo $?)"
[ "$EXIT_CODE" = "1" ] || die "trying to create an alias starting with a slash should fail with code 1, got '$EXIT_CODE'"
