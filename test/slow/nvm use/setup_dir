#!/bin/sh

\. ../../../nvm.sh

mkdir -p "${NVM_DIR}/.nvm_use_bak"
if [ -d "${NVM_DIR}/v*" ]; then
  mv "${NVM_DIR}/v*" "${NVM_DIR}/.nvm_use_bak/"
fi
mkdir -p "${NVM_DIR}/.nvm_use_lts_alias_bak"
if [ -d "${NVM_DIR}/alias/lts" ]; then
  mv "${NVM_DIR}/alias/lts/*" "${NVM_DIR}/.nvm_use_lts_alias_bak/"
fi

for VERSION in "0.8.7" "0.9.1" "0.10.1" "0.11.1"; do
  nvm install "v$VERSION"
done

for VERSION in "1.0.0" "1.0.1"; do
  nvm install "iojs-v$VERSION"
done

nvm_make_alias lts/testing 0.10.1
nvm_make_alias 'lts/*' lts/testing
