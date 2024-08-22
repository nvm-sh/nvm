#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

make_fake_node v0.1.3
make_fake_node v0.2.3
make_fake_node v0.20.3

die () { echo "$@" ; exit 1; }

# The result should contain only the appropriate version numbers.

nvm ls 0.1 | grep 'v0.2.3' > /dev/null
if [ $? -eq 0 ]; then
  echo '"nvm ls 0.1" contained v0.2.3'
fi

nvm ls 0.1 | grep 'v0.20.3' > /dev/null
if [ $? -eq 0 ]; then
  die '"nvm ls 0.1" contained v0.20.3'
fi

nvm ls 0.1 | grep 'v0.1.3' > /dev/null
if [ $? -ne 0  ]; then
  die '"nvm ls 0.1" did not contain v0.1.3'
fi

nvm ls 0.2 | grep 'v0.2.3' > /dev/null
if [ $? -ne 0  ]; then
  die '"nvm ls 0.2" did not contain v0.2.3'
fi

nvm ls 0.2 | grep 'v0.20.3' > /dev/null
if [ $? -eq 0  ]; then
  die '"nvm ls 0.2" contained v0.20.3'
fi

nvm ls 0.2 | grep 'v0.2.3' > /dev/null
if [ $? -ne 0  ]; then
  die '"nvm ls 0.2" did not contain v0.2.3'
fi
