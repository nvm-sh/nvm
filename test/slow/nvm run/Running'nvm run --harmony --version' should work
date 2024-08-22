#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm run 0.10.7 --harmony --version
[ "_$(nvm run 0.10.7 --harmony --version 2>/dev/null | tail -1)" = "_v0.10.7" ] || die "\`nvm run --harmony --version\` failed to run with the correct version"
