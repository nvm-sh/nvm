#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

set +e # TODO: fix
\. ../../../nvm.sh
set -e

BIN="$(nvm_get_checksum_binary)"

case "${BIN-}" in
  sha256sum | shasum | sha256 | gsha256sum | openssl | bssl | sha1sum | sha1 | shasum)
    echo "${BIN} found"
  ;;
  *)
    die "sha256sum | shasum | sha256 | gsha256sum | openssl | bssl | sha1sum | sha1 | shasum not found: found ${BIN}"
  ;;
esac
