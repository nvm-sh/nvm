#!/bin/sh

cleanup () { unalias foo; unalias grep; }
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

alias foo='bar'
nvm_is_alias foo || die '"nvm_is_alias foo" was not true'

! nvm_is_alias nvm_is_alias || die '"nvm_is_alias nvm_is_alias was not false'

alias grep='grep'
unalias grep || die '"unalias grep" failed'
! nvm_is_alias grep || die '"nvm_is_alias grep" with unaliased grep was not false'

alias grep='grep'
nvm_is_alias grep || die '"nvm_is_alias grep" with aliased grep was not true'

cleanup
