#!/bin/sh
\. ../../../nvm.sh
\. ../../common.sh

set -e

TEST_VERSION="v0.2.4"

if [ -f .nvmrc ]; then mv .nvmrc .nvmrc.orig; fi
if [ -f ../.nvmrc ]; then mv ../.nvmrc ../.nvmrc.orig; fi

del_nvmrc () {
  rm -f .nvmrc ../.nvmrc
}

cleanup () {
  del_nvmrc
  nvm cache clear
  nvm deactivate
  nvm unalias default
  rm -rf ${NVM_DIR}/v*
  if [ -f .nvmrc.orig ]; then mv .nvmrc.orig .nvmrc; fi
  if [ -f ../.nvmrc.orig ]; then mv ../.nvmrc.orig ../.nvmrc; fi
  unset -f nvm_ls_remote nvm_ls_remote_iojs
}

die () {
  echo "$@"
  cleanup
  exit 1
}

REMOTE="$PWD/mocks/nvm_ls_remote.txt"
nvm_ls_remote() {
  cat "$REMOTE"
}
REMOTE_IOJS="$PWD/mocks/nvm_ls_remote_iojs.txt"
nvm_ls_remote_iojs() {
  cat "$REMOTE_IOJS"
}

del_nvmrc
make_fake_node "$TEST_VERSION"

(cd ..
nvm use --save "$TEST_VERSION" || die "\`nvm use --save $TEST_VERSION\` failed in the parent dir")
nvm use --save || die "\`nvm use --save\` failed"

[ -f ../.nvmrc ] && [ -f .nvmrc ] || die "expected two .nvmrc files to be generated"

OUTPUT=$(cat .nvmrc)
EXPECTED_OUTPUT="$(cat ../.nvmrc)"

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "invalid \`nvm use --save \` output: expected '$EXPECTED_OUTPUT'; got '$OUTPUT'"

cleanup
