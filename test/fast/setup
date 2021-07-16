#!/bin/sh

set -ex

(
  cd ../..

  # Back up

  type setopt >/dev/null 2>&1 && setopt NULL_GLOB
  type shopt >/dev/null 2>&1 && shopt -s nullglob
  rm -Rf v* src alias
  mkdir src alias
)
