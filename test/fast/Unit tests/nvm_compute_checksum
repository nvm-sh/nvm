#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

set +x
OUTPUT="$(nvm_compute_checksum 2>&1 >/dev/null || echo)"
EXIT_CODE="$(nvm_compute_checksum >/dev/null 2>&1 || echo $?)"
set -x
EXPECTED_OUTPUT='Provided file to checksum is empty.'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 2 ] || die "expected to exit with code 2, got ${EXIT_CODE}"

set +x
OUTPUT="$(nvm_compute_checksum foo 2>&1 >/dev/null || echo)"
EXIT_CODE="$(nvm_compute_checksum foo >/dev/null 2>&1 || echo $?)"
set -x
EXPECTED_OUTPUT='Provided file to checksum does not exist.'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 1 ] || die "expected to exit with code 1, got ${EXIT_CODE}"
