#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

die () { echo "$@" ; unset -f nvm_ls nvm_list_aliases; exit 1; }

make_fake_node v0.12.87 || die 'fake v0.12.87 could not be made'
make_fake_node v0.12.9 || die 'fake v0.12.9 could not be made'
make_fake_iojs v0.1.2 || die 'fake iojs-v0.1.2 could not be made'
make_fake_iojs v0.10.2 || die 'fake iojs-v0.10.2 could not be made'

set -e

nvm_list_aliases() {
  echo 'sd-6'
}
# sanity check
OUTPUT="$(nvm alias)"
EXPECTED_OUTPUT='sd-6'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "1: expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"

nvm_ls() {
  echo v0.12.87
  echo v0.12.9
  echo iojs-v0.1.2
  echo iojs-v0.10.2
}
OUTPUT="$(nvm ls --no-colors)"
EXPECTED_OUTPUT="       v0.12.87 *
        v0.12.9 *
    iojs-v0.1.2 *
   iojs-v0.10.2 *
sd-6"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "2: expected >${EXPECTED_OUTPUT}<; got >${OUTPUT}<"
