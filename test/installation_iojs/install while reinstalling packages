#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

# Remove the stuff we're clobbering.
[ -e "${NVM_DIR}/versions/io.js/v1.0.0" ] && rm -R "${NVM_DIR}/versions/io.js/v1.0.0"
[ -e "${NVM_DIR}/versions/io.js/v1.0.1" ] && rm -R "${NVM_DIR}/versions/io.js/v1.0.1"

# Install from binary
nvm install iojs-v1.0.0

# Check
[ -d "${NVM_DIR}/versions/io.js/v1.0.0" ] || die "nvm install iojs-v1.0.0 didn't install"

node --version | grep v1.0.0 > /dev/null || die "nvm install didn't use iojs-v1.0.0"

npm install -g object-is@0.0.0 || die "npm install -g object-is failed"
npm list --global | grep object-is > /dev/null || die "object-is isn't installed"

nvm ls iojs-1 | grep iojs-v1.0.0 > /dev/null || die "nvm ls iojs-1 didn't show iojs-v1.0.0"

nvm install iojs-v1.0.1 --reinstall-packages-from=iojs-1.0.0 || die "nvm install iojs-v1.0.1 --reinstall-packages-from=iojs-1.0.0 failed"

[ -d "${NVM_DIR}/versions/io.js/v1.0.1" ] || die "nvm install iojs-v1.0.1 didn't install"

nvm use iojs-1
node --version | grep v1.0.1 > /dev/null || die "nvm use iojs-1 didn't use v1.0.1"

npm list --global | grep object-is > /dev/null || die "object-is isn't installed"
