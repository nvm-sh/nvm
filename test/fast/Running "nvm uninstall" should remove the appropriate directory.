#!/bin/sh

set -ex

\. ../../nvm.sh
\. ../common.sh

make_fake_node v0.0.1

nvm uninstall v0.0.1

[ ! -d 'v0.0.1' ]
