#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

make_fake_node v0.0.2
make_fake_node v0.0.20

die () { echo "$@" ; exit 1; }

# The result should contain only the appropriate version numbers.

nvm ls 0.0.2 | grep 'v0.0.2' > /dev/null
if [ $? -eq 0 ]; then
  echo '"nvm ls 0.0.2" contained v0.0.2'
fi

nvm ls 0.0.2 | grep 'v0.0.20' > /dev/null
if [ $? -eq 0 ]; then
  die '"nvm ls 0.0.2" contained v0.0.20'
fi
