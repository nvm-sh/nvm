#!/bin/sh

cleanup () {
  unset -f nvm_compute_checksum
}
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

set -ex

nvm_compute_checksum() {
  echo
}

set +x
OUTPUT="$(nvm_compare_checksum 2>&1 >/dev/null || echo)"
EXIT_CODE="$(nvm_compare_checksum >/dev/null 2>&1 || echo $?)"
set -x
EXPECTED_OUTPUT='Provided file to checksum is empty.'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 4 ] || die "expected to exit with code 4, got ${EXIT_CODE}"

set +x
OUTPUT="$(nvm_compare_checksum foo 2>&1 >/dev/null || echo)"
EXIT_CODE="$(nvm_compare_checksum foo >/dev/null 2>&1 || echo $?)"
set -x
EXPECTED_OUTPUT='Provided file to checksum does not exist.'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 3 ] || die "expected to exit with code 3, got ${EXIT_CODE}"

set +x
OUTPUT="$(nvm_compare_checksum ../../../nvm.sh 2>&1 >/dev/null || echo)"
EXIT_CODE="$(nvm_compare_checksum ../../../nvm.sh >/dev/null 2>&1 || echo $?)"
set -x
EXPECTED_OUTPUT='Provided checksum to compare to is empty.'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 2 ] || die "expected to exit with code 2, got ${EXIT_CODE}"

set +x
OUTPUT="$(nvm_compare_checksum ../../../nvm.sh checksum 2>&1 >/dev/null)"
EXIT_CODE="$(nvm_compare_checksum ../../../nvm.sh checksum >/dev/null 2>&1 ; echo $?)"
set -x
EXPECTED_OUTPUT="Computed checksum of '../../../nvm.sh' is empty.
WARNING: Continuing *without checksum verification*"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 0 ] || die "expected to exit with code 0, got ${EXIT_CODE}"

nvm_compute_checksum() {
  echo "not checksum: ${1}"
}

set +x
OUTPUT="$(nvm_compare_checksum ../../../nvm.sh checksum 2>&1 >/dev/null || echo)"
EXIT_CODE="$(nvm_compare_checksum ../../../nvm.sh checksum >/dev/null 2>&1 || echo $?)"
set -x
EXPECTED_OUTPUT="Checksums do not match: 'not checksum: ../../../nvm.sh' found, 'checksum' expected."
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 1 ] || die "expected to exit with code 1, got ${EXIT_CODE}"

nvm_compute_checksum() {
  echo checksum
}
set +x
OUTPUT="$(nvm_compare_checksum ../../../nvm.sh checksum 2>&1 >/dev/null)"
EXIT_CODE="$(nvm_compare_checksum ../../../nvm.sh checksum >/dev/null 2>&1; echo $?)"
set -x
EXPECTED_OUTPUT='Checksums matched!'
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
[ "${EXIT_CODE}" = 0 ] || die "expected to exit with code 0, got ${EXIT_CODE}"

cleanup
