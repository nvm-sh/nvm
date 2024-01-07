#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

unset NVM_NODEJS_ORG_MIRROR
unset NVM_IOJS_ORG_MIRROR

set +e # TODO: fix
\. ../../../nvm.sh
set -e

! nvm_get_mirror || die 'unknown release type did not error'
! nvm_get_mirror node || die 'unknown release type did not error'
! nvm_get_mirror iojs || die 'unknown release type did not error'
! nvm_get_mirror node foo || die 'unknown release type did not error'
! nvm_get_mirror iojs foo || die 'unknown release type did not error'

[ -z "$NVM_NODEJS_ORG_MIRROR" ] || die "MIRROR environment variables should not be exported"
[ -z "$NVM_IOJS_ORG_MIRROR" ] || die "MIRROR environment variables should not be exported"

[ "$(nvm_get_mirror node std)" = "https://nodejs.org/dist" ] || die "incorrect default node-std mirror"
[ "$(nvm_get_mirror iojs std)" = "https://iojs.org/dist" ] || die "incorrect default iojs-std mirror"

NVM_NODEJS_ORG_MIRROR="https://test-domain"
[ "$(nvm_get_mirror node std)" = "https://test-domain" ] || die "node-std mirror should respect NVM_NODEJS_ORG_MIRROR"
unset NVM_NODEJS_ORG_MIRROR

NVM_IOJS_ORG_MIRROR="https://test-domain"
[ "$(nvm_get_mirror iojs std)" = "https://test-domain" ] || die "iojs-std mirror should respect NVM_IOJS_ORG_MIRROR"
unset NVM_IOJS_ORG_MIRROR

testMirrors() {
  NVM_NODEJS_ORG_MIRROR="${1-}"
  ! nvm_get_mirror node std || die "NVM_NODEJS_ORG_MIRROR errors with command injection attempt (${1-})"
  [ "$(nvm_get_mirror node std)" = "" ] || die 'NVM_NODEJS_ORG_MIRROR is protected against command injection'

  NVM_IOJS_ORG_MIRROR="${1-}"
  ! nvm_get_mirror iojs std || die "NVM_IOJS_ORG_MIRROR errors with command injection attempt (${1-})"
  [ "$(nvm_get_mirror iojs std)" = "" ] || die 'NVM_IOJS_ORG_MIRROR is protected against command injection'
}

testMirrors '`do something bad`'
testMirrors 'https://nodejs.org/dist; xdg-open http://www.google.com;'
testMirrors 'https://nodejs.org/dist&&xdg-open http://www.google.com;'
testMirrors 'https://nodejs.org/dist|xdg-open http://www.google.com;'
