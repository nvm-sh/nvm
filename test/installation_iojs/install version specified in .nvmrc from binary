#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

NVM_TEST_VERSION=v1.0.0
NVM_PREFIXED_TEST_VERSION="iojs-${NVM_TEST_VERSION}"
VERSION_PATH="${NVM_DIR}/versions/io.js/${NVM_TEST_VERSION}"

# Remove the stuff we're clobbering.
[ -e "${VERSION_PATH}" ] && rm -R "${VERSION_PATH}"

# Install from binary
echo "${NVM_PREFIXED_TEST_VERSION}" > .nvmrc

nvm install || die "'nvm install' failed"

# Check
[ -d "${VERSION_PATH}" ] || die "./${VERSION_PATH} did not exist"
nvm run "${NVM_PREFIXED_TEST_VERSION}" --version | grep "${NVM_TEST_VERSION}" \
  || "'nvm run \'${NVM_PREFIXED_TEST_VERSION}\' --version | grep \'${NVM_TEST_VERSION}\'' failed"
