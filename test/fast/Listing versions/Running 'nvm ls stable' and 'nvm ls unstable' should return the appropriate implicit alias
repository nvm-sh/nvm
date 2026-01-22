#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

die () { echo "$@" ; exit 1; }

make_fake_node v0.2.3
make_fake_node v0.3.3

EXPECTED_STABLE="$(nvm_print_implicit_alias local stable)"
STABLE_VERSION="$(nvm_version "$EXPECTED_STABLE")"

EXPECTED_UNSTABLE="$(nvm_print_implicit_alias local unstable)"
UNSTABLE_VERSION="$(nvm_version "$EXPECTED_UNSTABLE")"

nvm ls stable | \grep "$STABLE_VERSION" >/dev/null \
  || die "expected 'nvm ls stable' to give $STABLE_VERSION, got $(nvm ls stable)"

nvm ls unstable | \grep "$UNSTABLE_VERSION" >/dev/null \
  || die "expected 'nvm ls unstable' to give $UNSTABLE_VERSION, got $(nvm ls unstable)"

make_fake_node v0.1.4
nvm alias stable 0.1

nvm ls stable | \grep -v "$STABLE_VERSION" >/dev/null \
  || die "'nvm ls stable' contained $STABLE_VERSION instead of v0.1.4"
nvm ls stable | \grep v0.1.4 >/dev/null \
  || die "'nvm ls stable' did not contain v0.1.4"
