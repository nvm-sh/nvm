#!/bin/sh

tempfile=$(mktemp)

die () { echo "$@" ; cleanup; exit 1; }
cleanup() { rm -f "$tempfile"; }

\. ../../../nvm.sh

if [ -t 1 ] ; then
  # test is running in a terminal, e.g. locally
  nvm_stdout_is_terminal || die 'nvm_stdout_is_terminal should be true'
  nvm_stdout_is_terminal 2>/dev/null || die 'nvm_stdout_is_terminal should be true when stderr is redirected'
  nvm_stdout_is_terminal </dev/null || die 'nvm_stdout_is_terminal should be true when stdin is redirected'
else
  # test is not running in a terminal, e.g. on travis-ci
  ! nvm_stdout_is_terminal || die 'nvm_stdout_is_terminal should be false'
  ! nvm_stdout_is_terminal 2>/dev/null || die 'nvm_stdout_is_terminal should be false when stderr is redirected'
  ! nvm_stdout_is_terminal </dev/null || die 'nvm_stdout_is_terminal should be false when stdin is redirected'
fi

(! nvm_stdout_is_terminal || echo "boo!") | read && die 'nvm_stdout_is_terminal should be false when stdout goes to a pipe'
! nvm_stdout_is_terminal >/dev/null || die 'nvm_stdout_is_terminal should be false when stdout goes to /dev/null'
! nvm_stdout_is_terminal >"$tempfile" || die 'nvm_stdout_is_terminal should be false when stdout goes to a file'
[ "$(nvm_stdout_is_terminal; echo $?)" = "1" ] || die 'nvm_stdout_is_terminal should be false in command substitution'

# also test the 'true' case while running on travis-ci or similar environments
nvm_stdout_is_terminal >/dev/tty || die 'nvm_stdout_is_terminal should be true when stdout goes to /dev/tty'
nvm_stdout_is_terminal >/dev/tty 2>/dev/null || die 'nvm_stdout_is_terminal should be true when stdout goes to /dev/tty and stderr is redirected'
nvm_stdout_is_terminal >/dev/tty </dev/null || die 'nvm_stdout_is_terminal should be true when stdout goes to /dev/tty and stdin is redirected'

cleanup
