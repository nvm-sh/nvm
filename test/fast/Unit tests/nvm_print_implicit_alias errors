#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

EXPECTED_FIRST_MSG="nvm_print_implicit_alias must be specified with local or remote as the first argument."
[ "_$(nvm_print_implicit_alias 2>&1)" = "_$EXPECTED_FIRST_MSG" ] \
  || die "nvm_print_implicit_alias did not require local|remote as first argument"
[ "_$(nvm_print_implicit_alias foo 2>&1)" = "_$EXPECTED_FIRST_MSG" ] \
  || die "nvm_print_implicit_alias did not require local|remote as first argument"

FIRST_EXIT_CODE="$(nvm_print_implicit_alias > /dev/null 2>&1 ; echo $?)"
[ "_$FIRST_EXIT_CODE" = "_1" ] \
  || die "nvm_print_implicit_alias without local|remote had wrong exit code: expected 1, got $FIRST_EXIT_CODE"

EXPECTED_SECOND_MSG="Only implicit aliases 'stable', 'unstable', 'iojs', and 'node' are supported."
[ "_$(nvm_print_implicit_alias local 2>&1)" = "_$EXPECTED_SECOND_MSG" ] \
  || die "nvm_print_implicit_alias did not require stable|unstable|iojs|node as second argument"
[ "_$(nvm_print_implicit_alias local foo 2>&1)" = "_$EXPECTED_SECOND_MSG" ] \
  || die "nvm_print_implicit_alias did not require stable|unstable|iojs|node as second argument"

SECOND_EXIT_CODE="$(nvm_print_implicit_alias local > /dev/null 2>&1 ; echo $?)"
[ "_$SECOND_EXIT_CODE" = "_2" ] \
  || die "nvm_print_implicit_alias without stable|unstable|iojs|node had wrong exit code: expected 2, got $SECOND_EXIT_CODE"
