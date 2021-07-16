#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

[ "_$(nvm_strip_iojs_prefix iojs)" = "_" ] || die '"nvm_strip_iojs_prefix iojs" did not return an empty string'
[ "_$(nvm_strip_iojs_prefix iojs-)" = "_" ] || die '"nvm_strip_iojs_prefix iojs-" did not return an empty string'
[ "_$(nvm_strip_iojs_prefix iojs-foo)" = "_foo" ] || die '"nvm_strip_iojs_prefix iojs-foo" did not return "foo"'
[ "_$(nvm_strip_iojs_prefix iojsfoo)" = "_iojsfoo" ] || die '"nvm_strip_iojs_prefix iojsfoo" did not return "iojsfoo"'
