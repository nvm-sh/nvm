#!/bin/sh

die () {
  unset -f nvm_install_binary nvm_install_source
  echo "$@"
  exit 1
}

\. ../../nvm.sh

nvm unalias default || die 'unable to unalias default'

NVM_TEST_VERSION=v0.10.7

# Remove the stuff we're clobbering.
[ -e ../../$NVM_TEST_VERSION ] && rm -R ../../$NVM_TEST_VERSION

# Install from binary
nvm install -b $NVM_TEST_VERSION || die "install $NVM_TEST_VERSION failed"

# Check
[ -d ../../$NVM_TEST_VERSION ]
nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION || die "'nvm run $NVM_TEST_VERSION --version | grep $NVM_TEST_VERSION' failed"

# ensure default is set
NVM_CURRENT_DEFAULT="$(nvm_alias default)"
[ "$NVM_CURRENT_DEFAULT" = "$NVM_TEST_VERSION" ] || die "wrong default alias: $(nvm alias)"

nvm_install_binary() {
  >&2 echo 'binary failed'
  return 1
}

# binary fails, falls back to source, but if -b is set, fails
OUTPUT="$(nvm install -b 9.0.0 2>&1)"
EXPECTED_OUTPUT='binary failed'
if [ "${OUTPUT#*"${EXPECTED_OUTPUT}"}" = "${OUTPUT}" ]; then
  die "No source binary flag is active and should have returned >${EXPECTED_OUTPUT}<. Instead it returned >${OUTPUT}<"
fi

nvm_install_source() {
  >&2 echo 'source intentionally failed'
  return 1
}

# binary fails, falls back to source if -b is not set
OUTPUT="$(nvm install 9.0.0 2>&1)"
EXPECTED_OUTPUT="binary failed
Detected that you have 2 CPU core(s)
Number of CPU core(s) less than or equal to 2, running in single-threaded mode
source intentionally failed"

[ "${EXPECTED_OUTPUT}" = "${OUTPUT}" ] || die "expected >${EXPECTED_OUTPUT}<, got >${OUTPUT}<"
