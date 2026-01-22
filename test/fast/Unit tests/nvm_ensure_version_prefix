#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

[ "_$(nvm_ensure_version_prefix 1)" = "_v1" ] || die '"nvm_ensure_version_prefix 1" did not return "v1"'
[ "_$(nvm_ensure_version_prefix v1)" = "_v1" ] || die '"nvm_ensure_version_prefix v1" did not return "v1"'
[ "_$(nvm_ensure_version_prefix foo)" = "_foo" ] || die '"nvm_ensure_version_prefix foo" did not return "foo"'

[ "_$(nvm_ensure_version_prefix iojs-1)" = "_iojs-v1" ] || die '"nvm_ensure_version_prefix iojs-1" did not return "iojs-v1"'
[ "_$(nvm_ensure_version_prefix iojs-v1)" = "_iojs-v1" ] || die '"nvm_ensure_version_prefix iojs-v1" did not return "iojs-v1"'
