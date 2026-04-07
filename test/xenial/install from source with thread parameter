#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

NVM_TEST_VERSION=v0.10.7

# STAGE 1 #

# Remove the stuff we're clobbering.
[ -e ../../$NVM_TEST_VERSION ] && rm -R ../../$NVM_TEST_VERSION

# Install from source with 1 make job
nvm install -s -j 1 $NVM_TEST_VERSION || die "'nvm install -s $NVM_TEST_VERSION' failed"

# Check
[ -d ../../$NVM_TEST_VERSION ]
nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION || "'nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION' failed"



# STAGE 2 #

# Remove the stuff we're clobbering.
[ -e ../../$NVM_TEST_VERSION ] && rm -R ../../$NVM_TEST_VERSION

# Install from source with 2 make jobs (and swapped arg order)
nvm install -j 2 -s $NVM_TEST_VERSION || die "'nvm install -s $NVM_TEST_VERSION' failed"

# Check
[ -d ../../$NVM_TEST_VERSION ]
nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION || "'nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION' failed"
