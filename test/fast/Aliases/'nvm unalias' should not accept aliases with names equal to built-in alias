#!/bin/sh

\. ../../../nvm.sh

die () { echo "$@" ; exit 1; }

OUTPUT="$(nvm unalias node 2>&1)"
EXPECTED_OUTPUT="node is a default (built-in) alias and cannot be deleted."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to remove a built-in alias should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

OUTPUT="$(nvm unalias stable 2>&1)"
EXPECTED_OUTPUT="stable is a default (built-in) alias and cannot be deleted."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to remove a built-in alias should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

OUTPUT="$(nvm unalias unstable 2>&1)"
EXPECTED_OUTPUT="unstable is a default (built-in) alias and cannot be deleted."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to remove a built-in alias should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

OUTPUT="$(nvm unalias iojs 2>&1)"
EXPECTED_OUTPUT="iojs is a default (built-in) alias and cannot be deleted."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to remove a built-in alias should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

OUTPUT="$(nvm unalias system 2>&1)"
EXPECTED_OUTPUT="system is a default (built-in) alias and cannot be deleted."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to remove a built-in alias should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"
