#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm use 0.10.7
NPM_VERSION_TEN="$(npm --version)"

nvm use 1.0.0 && [ "$(node --version)" = "v1.0.0" ] || die "\`nvm use\` failed!"

echo "0.10.7" > .nvmrc

[ "$(nvm exec npm --version | tail -1)" = "$NPM_VERSION_TEN" ] || die "\`nvm exec\` failed to run with the .nvmrc version"

[ "$(nvm exec npm --version | head -1)" = "Found '$PWD/.nvmrc' with version <0.10.7>" ] || die "\`nvm exec\` failed to print out the \"found in .nvmrc\" message"
