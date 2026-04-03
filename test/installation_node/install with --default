#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

nvm install --default node || die '`nvm install --default` failed'

TERM=dumb nvm alias | grep "default -> node (-> $(nvm version node) \*)" || die 'did not make the expected alias'
