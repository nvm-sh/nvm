#!/bin/sh

die () { echo "$@" ; cleanup ; exit 1; }


cleanup() {
  unset -f nvm_download
}

\. ../../../nvm.sh

set -ex

MOCKS_DIR="${PWD}/mocks"

# sample output at the time the test was written
TAB_PATH="${MOCKS_DIR}/nodejs.org-dist-index.tab"
nvm_download() {
  cat "${TAB_PATH}"
}

nvm_ls_remote >/dev/null || die "nvm_ls_remote_failed?!"

LTS_NAMES_PATH="${MOCKS_DIR}/LTS_names.txt"

N=0
while IFS= read -r LTS; do
  if [ $N -gt 0 ]; then
    EXPECTED="$(nvm_alias "lts/${LTS}")"
    ACTUAL="$(nvm_alias "lts/-${N}")"
    [ "${EXPECTED}" = "${ACTUAL}" ] || die "\`nvm_alias lts/-${N}\` was \`${ACTUAL}\`; expected \`${EXPECTED}\`"
  fi
  N=$(($N+1))
done < "${LTS_NAMES_PATH}"

cleanup
