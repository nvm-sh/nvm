#!/bin/sh

set -ex

# Remove temporary files
(
  cd ../..

  type setopt >/dev/null 2>&1 && setopt NULL_GLOB
  type shopt >/dev/null 2>&1 && shopt -s nullglob
  rm -fR v* src alias test/test-xz
)
