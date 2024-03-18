#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

make_fake_node v0.1.3
make_fake_node v0.2.3

[ -z "$(nvm ls | \grep 'versions')" ]
# The result should contain only the appropriate version numbers.
