#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

# Deactivate any active node version
nvm deactivate >/dev/null 2>&1 || die 'deactivate failed'

# Attempt to use 'lts' without '--' and capture the error message
ERROR_OUTPUT=$(nvm use lts 2>&1) || true

EXPECTED_ERROR='`lts` is not an alias - you may need to run `nvm install --lts` to install and `nvm use --lts` to use it.'

# Check if the error message matches the expected output
echo "$ERROR_OUTPUT" | grep -q "$EXPECTED_ERROR" \
  || die "Expected error message not found. Got: $ERROR_OUTPUT"
