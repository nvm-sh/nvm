#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm_is_valid_version 0.1.2 || die "nvm_is_valid_version 0.1.2 did not return 0"
nvm_is_valid_version foo && die "nvm_is_valid_version foo did not return 1"
nvm_is_valid_version iojs-1 || die "nvm_is_valid_version iojs-1 did not return 0"
nvm_is_valid_version iojs || die "nvm_is_valid_version iojs did not return 0"
nvm_is_valid_version node || die "nvm_is_valid_version node did not return 0"
nvm_is_valid_version stable || die "nvm_is_valid_version stable did not return 0"
nvm_is_valid_version unstable || die "nvm_is_valid_version unstable did not return 0"
