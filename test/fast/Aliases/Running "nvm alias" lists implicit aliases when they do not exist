#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

die () { echo "$@" ; exit 1; }

NVM_ALIAS_OUTPUT=$(nvm alias | strip_colors)

EXPECTED_STABLE="$(nvm_print_implicit_alias local stable)"
STABLE_VERSION="$(nvm_version "$EXPECTED_STABLE")"
echo "$NVM_ALIAS_OUTPUT" | \grep -F "stable -> $EXPECTED_STABLE (-> $STABLE_VERSION) (default)" \
  || die "nvm alias did not contain the default local stable node version; got '$NVM_ALIAS_OUTPUT'"

echo "$NVM_ALIAS_OUTPUT" | \grep -F "node -> stable (-> $STABLE_VERSION) (default)" \
  || die "nvm alias did not contain the default local stable node version under 'node'; got '$NVM_ALIAS_OUTPUT'"

EXPECTED_UNSTABLE="$(nvm_print_implicit_alias local unstable)"
UNSTABLE_VERSION="$(nvm_version "$EXPECTED_UNSTABLE")"
echo "$NVM_ALIAS_OUTPUT" | \grep -F "unstable -> $EXPECTED_UNSTABLE (-> $UNSTABLE_VERSION) (default)" \
  || die "nvm alias did not contain the default local unstable node version; got '$NVM_ALIAS_OUTPUT'"

EXPECTED_IOJS="$(nvm_print_implicit_alias local iojs)"
IOJS_VERSION="$(nvm_version "$EXPECTED_IOJS")"
echo "$NVM_ALIAS_OUTPUT" | \grep -F "iojs -> $EXPECTED_IOJS (-> $IOJS_VERSION) (default)" \
  || die "nvm alias did not contain the default local iojs version; got '$NVM_ALIAS_OUTPUT'"
