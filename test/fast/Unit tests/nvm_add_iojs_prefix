#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

[ "_$(nvm_add_iojs_prefix 1)" = "_iojs-v1" ] || die '"nvm_add_iojs_prefix 1" did not return "iojs-v1"'
[ "_$(nvm_add_iojs_prefix iojs-1)" = "_iojs-v1" ] || die '"nvm_add_iojs_prefix iojs-1" did not return "iojs-v1"'
[ "_$(nvm_add_iojs_prefix iojs-1.2.3)" = "_iojs-v1.2.3" ] || die '"nvm_add_iojs_prefix iojs-1.2.3" did not return "iojs-v1.2.3"'
