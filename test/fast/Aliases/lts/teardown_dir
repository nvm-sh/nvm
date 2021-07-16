#!/bin/sh

\. ../../../../nvm.sh

LTS_ALIAS_PATH="$(nvm_alias_path)/lts"

if [ -d "${LTS_ALIAS_PATH}.bak" ]; then
  rm -rf "${LTS_ALIAS_PATH}"
  mv "${LTS_ALIAS_PATH}.bak" "${LTS_ALIAS_PATH}"
fi
