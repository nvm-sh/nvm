#!/bin/bash

dir=$npm_config_root/.npm/$npm_package_name/$npm_package_version/package

# add lines to the bashrc.
has=$(cat ~/.bashrc | egrep "^# ADDED BY npm FOR NVM$" || true)
if [ "x$has" != "x" ]; then
  exit 0
fi
cat <<NVM_CODE >>~/.bashrc
# ADDED BY npm FOR NVM
NVM_DIR=$dir
. \$NVM_DIR/nvm.sh
nvm use
# END ADDED BY npm FOR NVM
NVM_CODE

cat <<NVM_HOWTO

  To use nvm, source your .bashrc file like this:
    . ~/.bashrc
  or log out and back into your terminal.

NVM_HOWTO
