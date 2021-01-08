#!/bin/sh

die () { echo "$@" ; exit 1; }

# Needed to avoid to checkout the repo to the latest nvm version, losing the commits of the current PR
unset NVM_DIR
NODE_VERSION=8 \. ../../install.sh

. "${NVM_DIR}/nvm.sh"

# nvm installed node 8
nvm ls 8 > /dev/null 2>&1 || die "nvm didn't install node 8"
