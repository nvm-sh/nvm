#!/bin/sh

OLDPATH=$PATH
TEST_PATH=../../xz-test

cleanup() {
  rm -rf $TEST_PATH/{xz,which,awk,rm,command}
  export PATH=$OLDPATH
}
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

OLDPATH=$PATH

mkdir -p $TEST_PATH
touch ../../xz-test/xz
chmod +x ../../xz-test/xz

export PATH=$TEST_PATH:$PATH

$(nvm_supports_xz "v2.3.2") || \
  die "expected 'nvm_supports_xz v2.3.2' to exit with 0"

$(nvm_supports_xz "v0.12.7") && \
  die "expected 'nvm_supports_xz v0.12.7' to exit with 1"


# set up for a failure by having a minimal toolset available
# but remove xz
ln -s /usr/bin/which $TEST_PATH/which
ln -s /usr/bin/command $TEST_PATH/command
ln -s /usr/bin/awk $TEST_PATH/awk
ln -s $(which rm) $TEST_PATH/rm

export PATH=$TEST_PATH
rm $TEST_PATH/xz

$(nvm_supports_xz "v2.3.2") && \
  die "expected 'nvm_supports_xz v2.3.2' with a missing xz binary to exit with 1"

cleanup
