#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

[ "$(nvm_extract_tarball 2>&1)" = "nvm_extract_tarball requires exactly 4 arguments" ] || die 'incorrect error message with no args'
[ "$(nvm_extract_tarball > /dev/null 2>&1 ; echo $?)" = "5" ] || die 'incorrect error code with no args'
[ "$(nvm_extract_tarball one two three 2>&1)" = "nvm_extract_tarball requires exactly 4 arguments" ] || die 'incorrect error message with three args'
[ "$(nvm_extract_tarball one two three > /dev/null 2>&1 ; echo $?)" = "5" ] || die 'incorrect error code with three args'
[ "$(nvm_extract_tarball one two three four five 2>&1)" = "nvm_extract_tarball requires exactly 4 arguments" ] || die 'incorrect error message with five args'
[ "$(nvm_extract_tarball one two three four five > /dev/null 2>&1 ; echo $?)" = "5" ] || die 'incorrect error code with five args'
