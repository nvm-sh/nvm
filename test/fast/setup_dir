#!/bin/sh

set -ex

(
  cd ../..

  # Back up

  mkdir -p bak
  for SRC in v* src alias; do
    [ -e "$SRC" ] && mv "$SRC" bak
  done
  if [ -d versions ]; then
    mv versions bak
  fi
  true
)
