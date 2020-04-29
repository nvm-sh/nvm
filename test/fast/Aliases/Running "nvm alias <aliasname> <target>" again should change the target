#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

die () { echo "$@" ; exit 1; }

if [ -n "$ZSH_VERSION" ]; then
  # set clobber option in order to test that this does not produce any
  # incompatibilities
  setopt noclobber
fi

nvm alias test-stable-1 0.0.2 || die '`nvm alias test-stable-1 0.0.2` failed'

OUTPUT="$(nvm alias test-stable-1 | strip_colors)"
EXPECTED_OUTPUT='test-stable-1 -> 0.0.2 (-> v0.0.2)'
echo "$OUTPUT" | \grep -F "$EXPECTED_OUTPUT" || die "nvm alias test-stable-1 0.0.2 did not set test-stable-1 to 0.0.2: got '$OUTPUT'"

nvm alias test-stable-1 0.0.1 || die '`nvm alias test-stable-1 0.0.1` failed'

OUTPUT="$(nvm alias test-stable-1 | strip_colors)"
EXPECTED_OUTPUT='test-stable-1 -> 0.0.1 (-> v0.0.1)'
echo "$OUTPUT" | \grep -F "$EXPECTED_OUTPUT" || die "nvm alias test-stable-1 0.0.1 did not set test-stable-1 to 0.0.1: got '$OUTPUT'"
