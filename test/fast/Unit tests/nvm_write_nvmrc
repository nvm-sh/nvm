#!/bin/sh
\. ../../../nvm.sh
\. ../../common.sh

set -e

TEST_VERSION="v0.2.4"

if [ -f .nvmrc ]; then mv .nvmrc .nvmrc.orig; fi

del_nvmrc () {
  rm -f .nvmrc
}

del_alias () {
  nvm unalias test >/dev/null 2>&1
}

cleanup () {
  del_nvmrc
  del_alias
  nvm cache clear
  nvm deactivate
  nvm unalias default
  rm -rf ${NVM_DIR}/v*
  if [ -f .nvmrc.orig ]; then mv .nvmrc.orig .nvmrc; fi
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

make_fake_node "$TEST_VERSION"

test_version () {
  del_nvmrc
  VERSION_STRING=${1-}
  make_fake_node "$VERSION_STRING"

  nvm_write_nvmrc $VERSION_STRING || die "\`nvm_write_nvmrc ${VERSION_STRING}\` failed"
  OUTPUT="$(cat .nvmrc)"

  nvm_is_valid_version "$(cat .nvmrc)" \
    || die "\`nvm install --save ${VERSION_STRING}\`+ \`cat .nvmrc\` outputted invalid version: got '${OUTPUT}'"
}

# 1.

test_version "$TEST_VERSION" || die

# 2. with an alias
del_alias
nvm alias test "$TEST_VERSION"
test_version test || die

# 3. fails with invalid permissions
del_nvmrc
touch .nvmrc
chmod 0 .nvmrc
nvm_write_nvmrc $TEST_VERSION 2>/dev/null && die "\`nvm_write_nvmrc $TEST_VERSION\` did not fail with invalid permissions"
del_nvmrc

# 4. respects NVM_SILENT=1
export NVM_SILENT=1
[ "$(nvm_write_nvmrc $TEST_VERSION)" = "" ] || die "\`nvm_write_nvmrc $TEST_VERSION\` was not silenced by NVM_SILENT=1"
unset NVM_SILENT

# 5. fails with an invalid version number
TEST_VERSION="not_a_node_version"
nvm_write_nvmrc $TEST_VERSION 2>/dev/null && die "\`nvm_write_nvmrc $TEST_VERSION\` did not fail"

#

cleanup
