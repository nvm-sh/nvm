#!/bin/sh

\. ../../../nvm.sh

nvm install 0.10.7
nvm install --lts=argon
nvm install --lts

if [ -f ".nvmrc" ]; then
  mv .nvmrc .nvmrc.bak
fi
