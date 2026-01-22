#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

set +e # TODO: fix
\. ../../../nvm.sh
set -e

ALG="$(nvm_get_checksum_alg)"

case "$ALG" in
  'sha-256' | 'sha-1')
    echo 'sha-256 or sha-1 found'
  ;;
  *)
    die "sha-256 or sha-1 not found: found ${ALG}"
  ;;
esac
