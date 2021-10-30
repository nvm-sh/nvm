#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh
\. ../../common.sh

make_fake_node v0.12.34 || die 'fake v0.12.34 could not be made'

# Enable no unset variable
set -u

# Try an alias that does not exist
output=$(nvm ls 99 2>&1 1>/dev/null || true)
test -z "${output}" || die "1: expected empty; got >${output}"

# Try a version that does not exist
output=$(nvm ls 0.12.00 2>&1 1>/dev/null || true)
test -z "${output}" || die "2: expected empty; got >${output}"

# Try a version that does exist
output=$(nvm ls 0.12.34 2>&1 1>/dev/null || true)
test -z "${output}" || die "3: expected empty; got >${output}"
