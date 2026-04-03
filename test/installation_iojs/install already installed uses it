#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

[ "$(nvm install invalid.invalid 2>&1)" = "Version 'invalid.invalid' not found - try \`nvm ls-remote\` to browse available versions." ] || die "nvm installing an invalid version did not print a nice error message"

# Remove the stuff we're clobbering.
[ -e "${NVM_DIR}/versions/io.js/v1.0.0" ] && rm -R "${NVM_DIR}/versions/io.js/v1.0.0"
[ -e "${NVM_DIR}/versions/io.js/v1.0.1" ] && rm -R "${NVM_DIR}/versions/io.js/v1.0.1"

# Install from binary
nvm install iojs-v1.0.0
nvm install iojs-v1.0.1

nvm use iojs-v1.0.0

node --version | grep v1.0.0 || die "precondition failed: iojs node doesn't start at v1.0.0"
iojs --version | grep v1.0.0 || die "precondition failed: iojs binary doesn't start at v1.0.0"

nvm install iojs-v1.0.1

node --version | grep v1.0.1 || die "nvm install on already installed version doesn't use it (node binary)"
iojs --version | grep v1.0.1 || die "nvm install on already installed version doesn't use it (iojs binary)"
