#!/usr/bin/env bash

set -e

echo 'Updating test mocks...'

MOCKS_DIR="$PWD/test/fast/Unit tests/mocks"

echo "creating $MOCKS_DIR"
mkdir -p MOCKS_DIR

. "$NVM_DIR/nvm.sh"

nvm_ls_remote > "$MOCKS_DIR/nvm_ls_remote.txt"
nvm_ls_remote_iojs > "$MOCKS_DIR/nvm_ls_remote_iojs.txt"
nvm_download -L -s "$NVM_NODEJS_ORG_MIRROR/index.tab" -o - > "$MOCKS_DIR/nodejs.org-dist-index.tab"
nvm_download -L -s "$NVM_IOJS_ORG_MIRROR/index.tab" -o - > "$MOCKS_DIR/iojs.org-dist-index.tab"

echo "done! Don't forget to git commit them."
