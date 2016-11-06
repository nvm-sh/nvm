#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

expect () {
  INPUT="$1"
  EXPECTED_OUTPUT="$2"

  OUTPUT="$(nvm_get_minor_version "$INPUT")"
  [ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_minor_version $INPUT did not return $EXPECTED_OUTPUT; got $OUTPUT"

  V_OUTPUT="$(nvm_get_minor_version "v$INPUT")"
  [ "_$V_OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "nvm_get_minor_version v$INPUT did not return $EXPECTED_OUTPUT; got $V_OUTPUT"
}

fail_with () {
  INPUT="$1"
  EXPECTED_CODE="$2"

  EXIT_CODE="$(nvm_get_minor_version "$INPUT" >/dev/null 2>&1; echo $?)"
  [ "_$EXIT_CODE" = "_$EXPECTED_CODE" ] || die "nvm_get_minor_version "$INPUT" did not fail with code "$EXPECTED_CODE"; got $EXIT_CODE"
}

expect 1 1.0
expect 1. 1.0
expect 1.2 1.2
expect 1.2. 1.2
expect 1.2.3 1.2
expect 1.2.3. 1.2
expect 1.2.3.4 1.2

fail_with '' 1
fail_with '.' 2
fail_with '..' 2
fail_with v 2
fail_with .a 2
fail_with .1 2
fail_with v.1 2
fail_with a.b 2
fail_with 1.a 2
fail_with a.1 2
fail_with v1.a 2
fail_with va.1 2
