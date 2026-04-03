#!/bin/sh

\. ../common.sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

set -ex

NVM_TEST_VERSION='v3.3.1'
NVM_PREFIXED_TEST_VERSION="iojs-${NVM_TEST_VERSION}"

# Remove the stuff we're clobbering.
nvm uninstall "${NVM_TEST_VERSION}" || echo 'not installed'

# Install from source
(watch nvm install -s "${NVM_PREFIXED_TEST_VERSION}") || die "'nvm install -s ${NVM_PREFIXED_TEST_VERSION}' failed"

# Check
nvm_is_version_installed "${NVM_PREFIXED_TEST_VERSION}" || die 'version not installed'
nvm run "${NVM_PREFIXED_TEST_VERSION}" --version | grep "${NVM_TEST_VERSION}" || "'nvm run ${NVM_PREFIXED_TEST_VERSION} --version | grep ${NVM_TEST_VERSION}' failed"
