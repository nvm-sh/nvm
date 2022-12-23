#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

set +e # TODO: fix
\. ../../nvm.sh
set -e

nvm deactivate || die 'deactivate failed'

nvm unalias default || die 'unable to unalias default'

NVM_TEST_VERSION=v0.10.7

# Remove the stuff we're clobbering.
nvm uninstall "${NVM_TEST_VERSION}" || die 'nvm uninstall failed'

# Install from source
nvm install -s "${NVM_TEST_VERSION}" || die "'nvm install -s ${NVM_TEST_VERSION}' failed"

# Check
[ -d ../../$NVM_TEST_VERSION ] || die "../../${NVM_TEST_VERSION} is not a directory"
nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION || "'nvm run ${NVM_TEST_VERSION} --version | grep ${NVM_TEST_VERSION}' failed"

# ensure default is set
NVM_CURRENT_DEFAULT="$(nvm_alias default)"
[ "${NVM_CURRENT_DEFAULT}" = "${NVM_TEST_VERSION}" ] || die "wrong default alias: $(nvm alias)"
