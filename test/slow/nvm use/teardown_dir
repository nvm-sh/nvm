#!/bin/sh

\. ../../../nvm.sh

for VERSION in "0.8.7" "0.9.1" "0.10.1" "0.11.1"; do
  nvm uninstall "$VERSION"
done

for VERSION in "1.0.0" "1.0.1"; do
  nvm uninstall "iojs-v$VERSION"
done

if [ -d "${NVM_DIR}/.nvm_use_bak/*" ]; then
  mv "${NVM_DIR}/.nvm_use_bak/*" "${NVM_DIR}"
  rmdir "${NVM_DIR}/.nvm_use_bak"
fi

if [ -d "${NVM_DIR}/.nvm_use_lts_alias_bak" ]; then
  rm -rf "${NVM_DIR}/alias/lts/*"
  mv "${NVM_DIR}/.nvm_use_lts_alias_bak/*" "${NVM_DIR}/alias/lts/"
  rmdir "${NVM_DIR}/.nvm_use_lts_alias_bak"
fi
