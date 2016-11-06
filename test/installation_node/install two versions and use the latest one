#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

# Remove the stuff we're clobbering.
[ -e "${NVM_DIR}/v0.9.7" ] && rm -R "${NVM_DIR}/v0.9.7"
[ -e "${NVM_DIR}/v0.9.12" ] && rm -R "${NVM_DIR}/v0.9.12"

# Install from binary
nvm install 0.9.7 || die "'nvm install 0.9.7' failed"
nvm i 0.9.12 || die "'nvm i 0.9.12' failed"

# Check
[ -d "${NVM_DIR}/v0.9.7" ] || die "v0.9.7 didn't exist"
[ -d "${NVM_DIR}/v0.9.12" ] || die "v0.9.12 didn't exist"

# Use the first one
nvm use 0.9.7 || die "'nvm use 0.9.7' failed"

# Use the latest one
nvm use 0.9 || die "'nvm use 0.9' failed"
node --version | grep v0.9.12 || die "'node --version' was not v0.9.12, got: $(node --version)"
