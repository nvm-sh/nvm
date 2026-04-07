#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

set +e # todo: fix
\. ../../nvm.sh
set -e

NVM_DEBUG=1 nvm install --latest-npm 4.2.2 \
  | grep 'Attempting to upgrade to the latest working version of npm...' || die 'did not call through to nvm_install_latest_npm'
