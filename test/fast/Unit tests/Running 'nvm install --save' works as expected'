#!/bin/sh
\. ../../../nvm.sh
\. ../../common.sh

set -e

TEST_VERSION='v0.2.4'

if [ -f .nvmrc ]; then mv .nvmrc .nvmrc.orig; fi

cleanup() {
  nvm cache clear
  nvm deactivate
  nvm unalias default
  rm -rf "${NVM_DIR}/v0.2.4" .nvmrc
  if [ -f .nvmrc.orig ]; then mv .nvmrc.orig .nvmrc; fi
  unset -f nvm_ls_remote nvm_ls_remote_iojs
}

die() {
  echo "$@"
  cleanup
  exit 1
}

REMOTE="${PWD}/mocks/nvm_ls_remote.txt"
nvm_ls_remote() {
  if [ -n "${PATTERN}" ]; then
    cat "${REMOTE}" | \grep "${PATTERN}"
  else
    cat "${REMOTE}"
  fi
}
REMOTE_IOJS="$PWD/mocks/nvm_ls_remote_iojs.txt"
nvm_ls_remote_iojs() {
  local PATTERN
  PATTERN="${1-}"
  if [ -n "${PATTERN}" ]; then
    cat "${REMOTE_IOJS}" | \grep "${PATTERN}"
  else
    cat "${REMOTE_IOJS}"
  fi
}

make_fake_node "${TEST_VERSION}"

nvm install -w "${TEST_VERSION}" || die "\`nvm install -w ${TEST_VERSION}\` failed"
OUTPUT="$(cat .nvmrc)"

nvm_is_valid_version "${OUTPUT}" \
  || die "\`nvm install -w ${TEST_VERSION}\`+ \`cat .nvmrc\` outputted invalid version: got '${OUTPUT}'"

rm .nvmrc || die 'removing of .nvmrc failed'

nvm install --save "${TEST_VERSION}" || die "\`nvm install --save ${TEST_VERSION}\` failed"
OUTPUT="$(cat .nvmrc)"

nvm_is_valid_version "${OUTPUT}" \
  || die "\`nvm install --save ${TEST_VERSION}\`+ \`cat .nvmrc\` outputted invalid version: got '${OUTPUT}'"

cleanup
