#!/bin/sh

\. ../../../nvm.sh
\. ../../common.sh

die () { echo "$@" ; exit 1; }

NVM_ALIAS_OUTPUT="$(nvm alias | strip_colors)"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-1 -> 0.0.1 (-> v0.0.1)' \
  || die "did not find test-stable-1 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-2 -> 0.0.2 (-> v0.0.2)' \
  || die "did not find test-stable-2 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-3 -> 0.0.3 (-> v0.0.3)' \
  || die "did not find test-stable-3 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-4 -> 0.0.4 (-> v0.0.4)' \
  || die "did not find test-stable-4 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-5 -> 0.0.5 (-> v0.0.5)' \
  || die "did not find test-stable-5 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-6 -> 0.0.6 (-> v0.0.6)' \
  || die "did not find test-stable-6 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-7 -> 0.0.7 (-> v0.0.7)' \
  || die "did not find test-stable-7 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-8 -> 0.0.8 (-> v0.0.8)' \
  || die "did not find test-stable-8 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-9 -> 0.0.9 (-> v0.0.9)' \
  || die "did not find test-stable-9 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-stable-10 -> 0.0.10 (-> v0.0.10)' \
  || die "did not find test-stable-10 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-1 -> 0.1.1 (-> v0.1.1)' \
  || die "did not find test-unstable-1 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-2 -> 0.1.2 (-> v0.1.2)' \
  || die "did not find test-unstable-2 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-3 -> 0.1.3 (-> v0.1.3)' \
  || die "did not find test-unstable-3 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-4 -> 0.1.4 (-> v0.1.4)' \
  || die "did not find test-unstable-4 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-5 -> 0.1.5 (-> v0.1.5)' \
  || die "did not find test-unstable-5 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-6 -> 0.1.6 (-> v0.1.6)' \
  || die "did not find test-unstable-6 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-7 -> 0.1.7 (-> v0.1.7)' \
  || die "did not find test-unstable-7 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-8 -> 0.1.8 (-> v0.1.8)' \
  || die "did not find test-unstable-8 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-9 -> 0.1.9 (-> v0.1.9)' \
  || die "did not find test-unstable-9 alias; got '$NVM_ALIAS_OUTPUT'"
echo "$NVM_ALIAS_OUTPUT" | \grep -F 'test-unstable-10 -> 0.1.10 (-> v0.1.10)' \
  || die "did not find test-unstable-10 alias; got '$NVM_ALIAS_OUTPUT'"
