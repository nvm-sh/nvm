#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

# Remove the stuff we're clobbering.
[ -e "${NVM_DIR}/versions/io.js/v1.0.0" ] && rm -R "${NVM_DIR}/versions/io.js/v1.0.0"
[ -e "${NVM_DIR}/versions/io.js/v1.0.1" ] && rm -R "${NVM_DIR}/versions/io.js/v1.0.1"

# Install from binary
nvm install iojs-v1.0.0 || die "'nvm install iojs-v1.0.0' failed"
nvm i iojs-v1.0.1 || die "'nvm i iojs-v1.0.1' failed"

# Check
[ -d "${NVM_DIR}/versions/io.js/v1.0.0" ] || die "iojs v1.0.0 didn't exist"
[ -d "${NVM_DIR}/versions/io.js/v1.0.1" ] || die "iojs v1.0.1 didn't exist"

# Use the first one
nvm use iojs-1.0.0 || die "'nvm use iojs-1.0.0' failed"

# Use the latest one
nvm use iojs-1 || die "'nvm use iojs-1' failed"
[ "_$(node --version)" = "_v1.0.1" ] || die "'node --version' was not v1.0.1, got: $(node --version)"
[ "_$(iojs --version)" = "_v1.0.1" ] || die "'iojs --version' was not v1.0.1, got: $(iojs --version)"
