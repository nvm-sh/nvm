#!/bin/sh

set -ex

export NVM_SYMLINK_CURRENT=true
\. ../../nvm.sh
\. ../common.sh

rm -rf "${NVM_DIR}/v0.10.29"
make_fake_node v0.10.29
nvm use --delete-prefix 0.10.29
rm -rf "${NVM_DIR}/v0.10.29"

if [ ! -L "${NVM_DIR}/current" ];then
  echo "Expected 'current' symlink to be created!"
  exit 1
fi

oldLink="$(readlink "${NVM_DIR}/current")"

if [ "$(basename "${oldLink}")" != 'v0.10.29' ];then
  echo "Expected 'current' to point to v0.10.29 but was ${oldLink}"
  exit 1
fi

rm -rf "${NVM_DIR}/v0.11.13"
make_fake_node v0.11.13
nvm use --delete-prefix 0.11.13
rm -rf "${NVM_DIR}/v0.11.13"

newLink="$(readlink "${NVM_DIR}/current")"

if [ "$(basename "${newLink}")" != 'v0.11.13' ];then
  echo "Expected 'current' to point to v0.11.13 but was $newLink"
  exit 1
fi
