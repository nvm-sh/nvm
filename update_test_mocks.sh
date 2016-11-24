#!/usr/bin/env bash

set -e

echo 'Updating test mocks...'

MOCKS_DIR="$PWD/test/fast/Unit tests/mocks"

echo "creating $MOCKS_DIR"
mkdir -p "$MOCKS_DIR"

\. "$NVM_DIR/nvm.sh" --no-use
nvm deactivate 2> /dev/null
nvm_is_version_installed() {
  return 1
}

nvm_make_alias() {
  # prevent local alias creation
  return 0
}

nvm_ls_remote > "$MOCKS_DIR/nvm_ls_remote.txt"
nvm_ls_remote_iojs > "$MOCKS_DIR/nvm_ls_remote_iojs.txt"
NVM_LTS=* nvm_ls_remote > "$MOCKS_DIR/nvm_ls_remote LTS.txt"
NVM_LTS=argon nvm_ls_remote > "$MOCKS_DIR/nvm_ls_remote LTS argon.txt"
nvm_download -L -s "$NVM_NODEJS_ORG_MIRROR/index.tab" -o - > "$MOCKS_DIR/nodejs.org-dist-index.tab"
nvm_download -L -s "$NVM_IOJS_ORG_MIRROR/index.tab" -o - > "$MOCKS_DIR/iojs.org-dist-index.tab"
nvm ls-remote > "$MOCKS_DIR/nvm ls-remote.txt"
nvm ls-remote --lts > "$MOCKS_DIR/nvm ls-remote lts.txt"
nvm ls-remote node > "$MOCKS_DIR/nvm ls-remote node.txt"
nvm ls-remote iojs > "$MOCKS_DIR/nvm ls-remote iojs.txt"
nvm_print_implicit_alias remote stable > "$MOCKS_DIR/nvm_print_implicit_alias remote stable.txt"
nvm_ls_remote stable > "$MOCKS_DIR/nvm_ls_remote stable.txt"

ALIAS_PATH="$MOCKS_DIR/nvm_make_alias LTS alias calls.txt"
: > "$ALIAS_PATH"
nvm_make_alias() {
  # prevent local alias creation, and store arguments
  echo "${1}|${2}" >> "$ALIAS_PATH"
}
nvm ls-remote --lts > /dev/null

echo "done! Don't forget to git commit them."
