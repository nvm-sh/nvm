#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

OUTPUT="$(nvm run --silent --lts --version)"
EXPECTED_OUTPUT="$(nvm_match_version 'lts/*')"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm run --lts\` failed to run with the correct version; expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"

OUTPUT="$(nvm run --silent --lts=argon --version)"
EXPECTED_OUTPUT="$(nvm_match_version 'lts/argon')"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm run --lts=argon\` failed to run with the correct version; expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
