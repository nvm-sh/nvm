#!/bin/sh
\. ../../../nvm.sh
\. ../../common.sh

set -e

TEST_VERSION="v0.2.4"

if [ -f .nvmrc ]; then mv .nvmrc .nvmrc.orig; fi

cleanup () {
  nvm cache clear
  nvm deactivate
  nvm unalias default
  rm -rf "${NVM_DIR}/${TEST_VERSION:?}" .nvmrc
  if [ -f .nvmrc.orig ]; then mv .nvmrc.orig .nvmrc; fi
  unset -f nvm_ls_remote nvm_ls_remote_iojs
}

die () {
  echo "$@"
  cleanup
  exit 1
}

REMOTE="${PWD}/mocks/nvm_ls_remote.txt"
nvm_ls_remote() {
  cat "${REMOTE}"
}
REMOTE_IOJS="${PWD}/mocks/nvm_ls_remote_iojs.txt"
nvm_ls_remote_iojs() {
  cat "${REMOTE_IOJS}"
}

make_fake_node "${TEST_VERSION}"

OUTPUT=$(nvm use --save --silent "${TEST_VERSION}" || die "\`nvm use --save --silent ${TEST_VERSION}\` failed")
EXPECTED_OUTPUT=''

[ "_${OUTPUT}" = "_${EXPECTED_OUTPUT}" ] \
  || die "\`nvm use --save --silent ${TEST_VERSION}\` output was not silenced to '${EXPECTED_OUTPUT}'; got '${OUTPUT}'"

rm .nvmrc || die 'removing of .nvmrc failed'

OUTPUT=$(nvm use -w --silent "${TEST_VERSION}" || die "\`nvm use -w --silent ${TEST_VERSION}\` failed")
EXPECTED_OUTPUT=''

[ "_${OUTPUT}" = "_${EXPECTED_OUTPUT}" ] \
  || die "\`nvm use -w --silent ${TEST_VERSION}\` output was not silenced to '${EXPECTED_OUTPUT}'; got '${OUTPUT}'"

cleanup
