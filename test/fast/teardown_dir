#!/bin/sh

set -ex

(
  cd ../..

  # Restore
  if [ -d bak ]
    then
    mv bak/* . > /dev/null 2>&1 || sleep 0s
    rmdir bak
  fi
  mkdir -p src alias
)
