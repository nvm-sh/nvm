#!/bin/sh

\. ../../../nvm.sh

die () { echo "$@" ; exit 1; }

OUTPUT="$(nvm unalias node 2>&1)"
EXPECTED_OUTPUT="node is a default (built-in) alias and cannot be deleted."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to remove a built-in alias should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"

nvm alias node stable || die '`nvm alias node stable` failed'

nvm unalias node || die '`nvm unalias node` failed'

OUTPUT="$(nvm unalias node 2>&1)"
EXPECTED_OUTPUT="node is a default (built-in) alias and cannot be deleted."
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "trying to remove a built-in alias should fail with '$EXPECTED_OUTPUT', got '$OUTPUT'"
