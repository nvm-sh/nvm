#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm_is_iojs_version 'iojs-' || die '"nvm_is_iojs_version iojs- was not true'
nvm_is_iojs_version 'iojs-foo' || die '"nvm_is_iojs_version iojs- was not true'
! nvm_is_iojs_version 'iojs' || die '"nvm_is_iojs_version iojs was not false'
! nvm_is_iojs_version 'v1.0.0' || die '"nvm_is_iojs_version v1.0.0" was not false'
