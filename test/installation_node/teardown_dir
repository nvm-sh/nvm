#!/bin/sh

\. ../../nvm.sh
nvm deactivate
nvm uninstall v0.10.7
nvm uninstall v4.2.2
nvm uninstall v0.9.7
nvm uninstall v9.7.0
nvm uninstall v0.9.12
nvm uninstall v9.10.0

if [ -f ".nvmrc" ]; then
  rm .nvmrc
fi

if [ -f ".nvmrc.bak" ]; then
  mv .nvmrc.bak .nvmrc
fi
