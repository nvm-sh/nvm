#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

[ "$(nvm_version_dir)" = "$NVM_DIR/versions/node" ] || die '"nvm_version_dir" did not return new dir path'
[ "$(nvm_version_dir iojs)" = "$NVM_DIR/versions/io.js" ] || die '"nvm_version_dir iojs" did not return iojs dir path'
[ "$(nvm_version_dir new)" = "$(nvm_version_dir)" ] || die '"nvm_version_dir new" did not return new dir path'
[ "$(nvm_version_dir old)" = "$NVM_DIR" ] || die '"nvm_version_dir old" did not return old dir path'
[ "$(nvm_version_dir foo 2>&1)" = "unknown version dir" ] || die '"nvm_version_dir foo" did not error out'
