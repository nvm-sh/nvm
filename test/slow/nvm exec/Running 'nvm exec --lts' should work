#!/bin/sh

set -ex

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm install --lts || die 'nvm install --lts failed'

NPM_VERSION_LTS="$(npm --version)"
TEST_STRING="foo bar"

nvm use 1.0.0 && [ "$(node --version)" = "v1.0.0" ] || die "\`nvm use\` failed!"

[ "$(nvm exec --lts npm --version | tail -1)" = "$NPM_VERSION_LTS" ] || die "`nvm exec` failed to run with the correct version"

[ "$(nvm exec --lts bash -c "printf '$TEST_STRING'" | tail -1)" = "$TEST_STRING" ] || die "\`nvm exec\` failed to run with a command including whitespace"
