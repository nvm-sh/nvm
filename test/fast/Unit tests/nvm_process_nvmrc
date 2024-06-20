#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }

cleanup() {
  echo 'cleaned up'
}

\. ../../../nvm.sh

\. ../../common.sh

for f in ../../../test/fixtures/nvmrc/test/fixtures/valid/*; do
  STDOUT="$(nvm_process_nvmrc $f/.nvmrc 2>/dev/null)"
  EXIT_CODE="$(nvm_process_nvmrc $f/.nvmrc >/dev/null 2>/dev/null; echo $?)"

  EXPECTED="$(nvm_json_extract node < "${f}/expected.json" | tr -d '"')"

  [ "${EXIT_CODE}" = "0" ] || die "$(basename "${f}"): expected exit code of 0 but got ${EXIT_CODE}"

  [ "${STDOUT}" = "${EXPECTED}" ] || die "$(basename "${f}"): expected STDOUT of \`${EXPECTED}\` but got \`${STDOUT}\`"
done

for f in ../../../test/fixtures/nvmrc/test/fixtures/invalid/*; do
  STDOUT="$(nvm_process_nvmrc $f/.nvmrc 2>/dev/null)"
  STDERR="$(nvm_process_nvmrc $f/.nvmrc 2>&1 >/dev/null | awk '{if(NR > 8) print $0}' | strip_colors)"
  EXIT_CODE="$(nvm_process_nvmrc $f/.nvmrc >/dev/null 2>/dev/null; echo $?)"

  EXPECTED="$(nvm_json_extract < "${f}/expected.json" | tr -d '"')"

  [ "${EXIT_CODE}" != "0" ] || die "$(basename "${f}"): expected exit code of 'not 0' but got ${EXIT_CODE}"

  [ "${STDERR}" = "${EXPECTED}" ] || die "$(basename "${f}"): expected STDERR of \`${EXPECTED}\` but got \`${STDERR}\`"
done
