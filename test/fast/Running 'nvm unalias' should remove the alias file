#!/bin/sh

set -ex

ALIAS_PATH="../../alias"

echo v0.1.2 > "${ALIAS_PATH}/test"

\. ../../nvm.sh

nvm unalias test

! [ -e "${ALIAS_PATH}/test" ]
