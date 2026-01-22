#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

export NVM_DIR="$(cd ../.. && pwd)"

\. ../../nvm.sh

nvm deactivate 2>&1

[ "$(nvm current)" = "system" ] || [ "$(nvm current)" = "none" ] || die '"nvm current" did not report "system" or "none" when deactivated'
