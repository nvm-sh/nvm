#!/bin/sh

\. ../../nvm.sh
nvm deactivate
nvm uninstall iojs-v1.0.0
nvm uninstall iojs-v1.0.3
nvm uninstall iojs-v3.3.0
nvm uninstall iojs-v3.3.1

if [ -f ".nvmrc" ]; then
  rm .nvmrc
fi

if [ -f ".nvmrc.bak" ]; then
  mv .nvmrc.bak .nvmrc
fi
