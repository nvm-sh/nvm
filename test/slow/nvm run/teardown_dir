#!/bin/sh

\. ../../../nvm.sh

nvm deactivate
nvm uninstall v0.10.7
nvm uninstall --lts=argon
nvm uninstall --lts

rm .nvmrc

if [ -f ".nvmrc.bak" ]; then
  mv .nvmrc.bak .nvmrc
fi
