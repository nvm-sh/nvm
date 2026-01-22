#!/bin/sh

cleanup () {
  rm -rf "${NVM_DIR}/versions/io.js/v0.1.2"
}
die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh
\. ../../common.sh

make_fake_iojs v0.1.2

nvm use iojs-v0.1.2

if command -v iojs; then
  nvm_has_system_iojs
else
  ! nvm_has_system_iojs
fi

nvm deactivate /dev/null 2>&1

if command -v iojs; then
  nvm_has_system_iojs
else
  ! nvm_has_system_iojs
fi
