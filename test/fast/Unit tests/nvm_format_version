#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

INPUT="0.1.2"
OUTPUT="$(nvm_format_version "$INPUT")"
EXPECTED_OUTPUT="v0.1.2"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_format_version $INPUT did not return $EXPECTED_OUTPUT; got $OUTPUT"

INPUT="0.1"
OUTPUT="$(nvm_format_version "$INPUT")"
EXPECTED_OUTPUT="v0.1.0"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_format_version $INPUT did not return $EXPECTED_OUTPUT; got $OUTPUT"

INPUT="1.2.3.4.5"
OUTPUT="$(nvm_format_version "$INPUT")"
EXPECTED_OUTPUT="v1.2.3"
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_format_version $INPUT did not return $EXPECTED_OUTPUT; got $OUTPUT"
