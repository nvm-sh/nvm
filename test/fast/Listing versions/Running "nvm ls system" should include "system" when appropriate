#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh
\. ../../common.sh

make_fake_node v0.0.1
make_fake_node v0.0.3
make_fake_node v0.0.9
make_fake_node v0.3.1
make_fake_node v0.3.3
make_fake_node v0.3.9

nvm_has_system_node() { return 0; }
nvm ls system | grep system 2>&1 > /dev/null
[ $? -eq 0 ] || die '"nvm ls system" did not contain "system" when system node is present'

nvm_has_system_node() { return 1; }
nvm ls system | grep system 2>&1 > /dev/null
[ $? -ne 0 ] || die '"nvm ls system" contained "system" when system node is not present'
