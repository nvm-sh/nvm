#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

[ "$(nvm install invalid.invalid 2>&1)" = "Version 'invalid.invalid' not found - try \`nvm ls-remote\` to browse available versions." ] || die "nvm installing an invalid version did not print a nice error message"

# Remove the stuff we're clobbering.
[ -e "${NVM_DIR}/v0.9.7" ] && rm -R "${NVM_DIR}/v0.9.7"
[ -e "${NVM_DIR}/v0.9.12" ] && rm -R "${NVM_DIR}/v0.9.12"

# Install from binary
nvm install 0.9.7
nvm install 0.9.12

nvm use 0.9.7

node --version | grep v0.9.7 || die "precondition failed: node doesn't start at 0.9.7"

nvm install 0.9.12

node --version | grep v0.9.12 || die "nvm install on already installed version doesn't use it"
