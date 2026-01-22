#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

NVM_VERSION="v1"
NVM_PREFIXED_TEST_VERSION="$(nvm ls-remote "$NVM_VERSION" | tail -1 | sed 's/^[    ]*//;s/[        ]*$//')"
NVM_TEST_VERSION="$(nvm_strip_iojs_prefix "$NVM_PREFIXED_TEST_VERSION")"

# Remove the stuff we're clobbering.
[ -e "../../$NVM_TEST_VERSION" ] && rm -R "../../$NVM_TEST_VERSION"

# Install from binary
nvm install "$NVM_VERSION" || die "nvm install $NVM_VERSION failed"

# Check
[ -d "${NVM_DIR}/versions/io.js/$NVM_TEST_VERSION" ]
nvm run "$NVM_PREFIXED_TEST_VERSION" --version | grep "$NVM_TEST_VERSION" || die "'nvm run $NVM_PREFIXED_TEST_VERSION --version | grep $NVM_TEST_VERSION' failed"
