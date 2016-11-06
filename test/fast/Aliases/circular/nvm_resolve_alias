#!/bin/sh
\. ../../../common.sh

die () { echo "$@" ; exit 1; }

\. ../../../../nvm.sh

ALIAS="$(nvm_resolve_alias loopback | strip_colors)"
[ "_$ALIAS" = "_∞" ] || die "nvm_resolve_alias loopback was not ∞; got $ALIAS"
OUTPUT="$(nvm alias loopback | strip_colors)"
EXPECTED_OUTPUT="loopback -> loopback (-> ∞)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm alias loopback was not $EXPECTED_OUTPUT; got $OUTPUT"

ALIAS="$(nvm_resolve_alias one | strip_colors)"
[ "_$ALIAS" = "_∞" ] || die "nvm_resolve_alias one was not ∞; got $ALIAS"
OUTPUT="$(nvm alias one | strip_colors)"
EXPECTED_OUTPUT="one -> two (-> ∞)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm alias one was not $EXPECTED_OUTPUT; got $OUTPUT"

ALIAS="$(nvm_resolve_alias two | strip_colors)"
[ "_$ALIAS" = "_∞" ] || die "nvm_resolve_alias two was not ∞; got $ALIAS"
OUTPUT="$(nvm alias two | strip_colors)"
EXPECTED_OUTPUT="two -> three (-> ∞)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm alias two was not $EXPECTED_OUTPUT; got $OUTPUT"

ALIAS="$(nvm_resolve_alias three | strip_colors)"
[ "_$ALIAS" = "_∞" ] || die "nvm_resolve_alias three was not ∞; got $ALIAS"
OUTPUT="$(nvm alias three | strip_colors)"
EXPECTED_OUTPUT="three -> one (-> ∞)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm alias three was not $EXPECTED_OUTPUT; got $OUTPUT"

ALIAS="$(nvm_resolve_alias four | strip_colors)"
[ "_$ALIAS" = "_∞" ] || die "nvm_resolve_alias four was not ∞; got $ALIAS"
OUTPUT="$(nvm alias four | strip_colors)"
EXPECTED_OUTPUT="four -> two (-> ∞)"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm alias four was not $EXPECTED_OUTPUT; got $OUTPUT"
