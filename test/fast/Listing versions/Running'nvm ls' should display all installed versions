#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

die () { echo "$@" ; exit 1; }

make_fake_node v0.0.1
make_fake_node v0.0.3
make_fake_node v0.0.9
make_fake_node v0.3.1
make_fake_node v0.3.3
make_fake_node v0.3.9
make_fake_node v0.12.87
make_fake_node v0.12.9
make_fake_iojs v0.1.2
make_fake_iojs v0.10.2

# The result should contain the version numbers.
nvm ls | grep v0.0.1 >/dev/null || die "v0.0.1 not found in: $(nvm ls)"
nvm ls | grep v0.0.3 >/dev/null || die "v0.0.3 not found in: $(nvm ls)"
nvm ls | grep v0.0.9 >/dev/null || die "v0.0.9 not found in: $(nvm ls)"
nvm ls | grep v0.3.1 >/dev/null || die "v0.3.1 not found in: $(nvm ls)"
nvm ls | grep v0.3.3 >/dev/null || die "v0.3.3 not found in: $(nvm ls)"
nvm ls | grep v0.3.9 >/dev/null || die "v0.3.9 not found in: $(nvm ls)"
nvm ls | grep v0.12.87 >/dev/null || die "v0.12.87 not found in: $(nvm ls)"
nvm ls | grep iojs-v0.1.2 >/dev/null || die "iojs-v0.1.2 not found in: $(nvm ls)"

OUTPUT="$(nvm_ls)"
EXPECTED_OUTPUT="v0.0.1
v0.0.3
v0.0.9
iojs-v0.1.2
v0.3.1
v0.3.3
v0.3.9
iojs-v0.10.2
v0.12.9
v0.12.87"
if nvm_has_system_node || nvm_has_system_iojs; then
  EXPECTED_OUTPUT="${EXPECTED_OUTPUT}
system"
fi
[ "${OUTPUT-}" = "${EXPECTED_OUTPUT-}" ] || die "expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"
