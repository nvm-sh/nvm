#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

nvm install --alias=9 9.11.2 || die '`nvm install --alias=9 9.11.2` failed'

TERM=dumb nvm alias | grep '9 -> 9.11.2 (-> v9.11.2 \*)' || die 'did not make the expected alias'
