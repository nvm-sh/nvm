#!/bin/sh

\. ../../../nvm.sh
nvm uninstall v0.10.28
nvm uninstall v0.10.29
nvm uninstall v4.7.1
nvm uninstall v4.7.2

rm -f .nvmrc

if [ -f ".nvmrc.bak" ]; then
  mv .nvmrc.bak .nvmrc
fi
