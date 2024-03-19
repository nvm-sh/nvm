#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

make_fake_node v0.1.2

nvm ls v0.1 | grep v0.1.2 &&
nvm ls v0.1.2 | grep v0.1.2 &&
nvm ls v0.1. | grep v0.1.2 &&
nvm ls v0.1.1 | grep N/A
