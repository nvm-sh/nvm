#!/bin/sh

\. ../../../../nvm.sh

LTS_ALIAS_PATH="$(nvm_alias_path)/lts"

if [ -d "${LTS_ALIAS_PATH}" ]; then
  mv "${LTS_ALIAS_PATH}" "${LTS_ALIAS_PATH}.bak"
  rm -rf "${LTS_ALIAS_PATH}"
fi
