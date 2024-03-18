#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh
\. ../../common.sh

make_fake_node v0.12.1
make_fake_node v0.1.3

nvm ls 0.12 | grep v0.12.1 || die '"nvm ls" did not list a version in the versions/ directory'
nvm ls 0.1 | grep v0.1.3 || die '"nvm ls" did not list a version not in the versions/ directory'
