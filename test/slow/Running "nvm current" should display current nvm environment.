#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

nvm install 0.10

[ "$(nvm current)" = "$(node -v)" ] || die "Failed to find current version: got \"$(nvm current)\", expected \"$(node -v)\""
