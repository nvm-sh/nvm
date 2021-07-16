#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

nvm unalias default || die 'unable to unalias default'

NVM_TEST_VERSION=v0.10.7

# Remove the stuff we're clobbering.
[ -e ../../$NVM_TEST_VERSION ] && rm -R ../../$NVM_TEST_VERSION

# Install from binary
nvm install $NVM_TEST_VERSION || die "install $NVM_TEST_VERSION failed"

# Check
[ -d ../../$NVM_TEST_VERSION ]
nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION || die "'nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION' failed"

# ensure default is set
NVM_CURRENT_DEFAULT="$(nvm_alias default)"
[ "$NVM_CURRENT_DEFAULT" = "$NVM_TEST_VERSION" ] || die "wrong default alias: $(nvm alias)"
