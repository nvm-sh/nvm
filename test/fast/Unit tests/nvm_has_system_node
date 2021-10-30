#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

cleanup () {
  rm -rf "${NVM_DIR}/v0.1.2"
}
die () { echo "$@" ; exit 1; }

make_fake_node v0.1.2

nvm use 0.1.2

if command -v node; then
  nvm_has_system_node
else
  ! nvm_has_system_node
fi

nvm deactivate /dev/null 2>&1

if command -v node; then
  nvm_has_system_node
else
  ! nvm_has_system_node
fi
