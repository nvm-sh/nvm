#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

! nvm_is_natural_num || die 'no args is not false'
! nvm_is_natural_num '' || die 'empty string is not false'
! nvm_is_natural_num a || die 'a is not false'
! nvm_is_natural_num -1 || 'negative number is not false'
! nvm_is_natural_num --1 || 'double negative number is not false'
! nvm_is_natural_num 1.2 || 'decimal number is not false'
! nvm_is_natural_num 0 || die 'zero is not false'

nvm_is_natural_num 1 || die '1 is not true'
nvm_is_natural_num 2 || die '2 is not true'
nvm_is_natural_num 1234 || die '1234 is not true'
