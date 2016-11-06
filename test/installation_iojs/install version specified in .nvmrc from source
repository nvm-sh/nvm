#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

set -ex

NVM_TEST_VERSION='v3.3.0'
NVM_PREFIXED_TEST_VERSION="iojs-${NVM_TEST_VERSION}"

# Remove the stuff we're clobbering.
nvm uninstall "${NVM_TEST_VERSION}" || echo 'not installed'

# Install from binary
echo "${NVM_PREFIXED_TEST_VERSION}" > .nvmrc

nvm install -s || "'nvm install -s' failed"

# Check
nvm_is_version_installed "${NVM_PREFIXED_TEST_VERSION}" || die 'version is not installed'
nvm run "${NVM_PREFIXED_TEST_VERSION}" --version | grep "${NVM_TEST_VERSION}" \
  || die "'nvm run ${NVM_PREFIXED_TEST_VERSION} --version | grep ${NVM_TEST_VERSION}' failed"
