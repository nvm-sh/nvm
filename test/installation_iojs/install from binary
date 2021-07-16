#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

NVM_TEST_VERSION="v1.0.0"
NVM_PREFIXED_TEST_VERSION="iojs-$NVM_TEST_VERSION"

# Remove the stuff we're clobbering.
[ -e "${NVM_DIR}/versions/io.js/${NVM_TEST_VERSION}" ] && rm -R "${NVM_DIR}/versions/io.js/${NVM_TEST_VERSION}"
[ -e "${NVM_DIR}/.cache/bin/${NVM_TEST_VERSION}-linux-x64/" ] && rm -R "${NVM_DIR}/.cache/bin/${NVM_TEST_VERSION}-linux-x64/"

# Install from binary
OUTPUT_HEAD="$(2>&1 nvm install --no-progress $NVM_PREFIXED_TEST_VERSION | tac | tail -n 1)" || die "install $NVM_PREFIXED_TEST_VERSION failed"
EXPECTED_OUTPUT_HEAD="Downloading and installing io.js v1.0.0..."

[ "${OUTPUT_HEAD}" = "${EXPECTED_OUTPUT_HEAD}" ] || die "expected >${EXPECTED_OUTPUT_HEAD}<; got >${OUTPUT_HEAD}<"

# Check
[ -d "${NVM_DIR}/versions/io.js/${NVM_TEST_VERSION}" ]
nvm run "${NVM_PREFIXED_TEST_VERSION}" --version | grep "${NVM_TEST_VERSION}" || die "'nvm run ${NVM_PREFIXED_TEST_VERSION} --version | grep ${NVM_TEST_VERSION}' failed"
