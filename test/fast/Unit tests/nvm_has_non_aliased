#!/bin/sh

cleanup () { unalias foo; unalias grep; }
die () { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh

alias foo='bar'
! nvm_has_non_aliased foo || die '"nvm_has_non_aliased foo" was not true'

alias grep='grep'
unalias grep || die '"unalias grep" failed'
nvm_has_non_aliased grep || die '"nvm_has_non_aliased grep" with unaliased grep was not false'

alias grep='grep'
! nvm_has_non_aliased grep || die '"nvm_is_alias grep" with aliased grep was not true'

nvm_has_non_aliased cat && type cat > /dev/null || die 'nvm_has_non_aliased locates "cat" properly'

[ "~$(nvm_has_non_aliased foobarbaz 2>&1)" = "~" ] || die "nvm_has_non_aliased does not suppress error output"

! nvm_has_non_aliased foobarbaz && ! type foobarbaz >/dev/null 2>&1 || die "nvm_has_non_aliased does not return a nonzero exit code when not found"

cleanup
