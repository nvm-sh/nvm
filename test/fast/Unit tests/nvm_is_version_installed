#!/bin/sh

cleanup () {
  rm -rf "$NVM_DIR"
  unset -f die cleanup nvm_get_os check_version
  unset NVM_DIR NODE_PATH
}
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

set -ex

NVM_DIR=$(mktemp -d)
NODE_PATH="$NVM_DIR/versions/node"
mkdir -p "$NODE_PATH"
if [ -z "$NODE_PATH" ]; then
  die 'Unable to create temporary folder'
fi

check_version() {
  local VERSION
  local BINARY
  VERSION=$1
  BINARY=$2

  # nvm_is_version_installed fails with non existing version
  ! nvm_is_version_installed "$VERSION" || die "nvm_is_version_installed $VERSION should fail with non existing version"

  # nvm_is_version_installed fails with non executable existing version
  mkdir -p "$NODE_PATH/$VERSION/bin" && cd "$NODE_PATH/$VERSION/bin" && touch "$NODE_PATH/$VERSION/bin/$BINARY"
  ! nvm_is_version_installed "$VERSION" || die "nvm_is_version_installed $VERSION should fail with non executable existing version"

  # nvm_is_version_installed whould work
  chmod +x "$NODE_PATH/$VERSION/bin/$BINARY"
  nvm_is_version_installed "$VERSION" || die "nvm_is_version_installed $VERSION should work"
}

# nvm_is_version_installed is available
type nvm_is_version_installed > /dev/null 2>&1 || die 'nvm_is_version_installed is not available'

# nvm_is_version_installed with no parameter fails
! nvm_is_version_installed || die 'nvm_is_version_installed without parameter should fail'

check_version '12.0.0' 'node'

# Checking for Windows
nvm_get_os() {
  echo "win"
}
check_version '13.0.0' 'node.exe'


cleanup
