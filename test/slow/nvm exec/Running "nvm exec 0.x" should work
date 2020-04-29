#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm use 0.10
NPM_VERSION_TEN="$(npm --version)"
TEST_STRING="foo bar"

nvm use 1.0.0 && [ "$(node --version)" = "v1.0.0" ] || die "\`nvm use\` failed!"

[ "$(nvm exec 0.10 npm --version | tail -1)" = "$NPM_VERSION_TEN" ] || die "\`nvm exec\` failed to run with the correct version"

[ "$(nvm exec 0.10 bash -c "printf '$TEST_STRING'" | tail -1)" = "$TEST_STRING" ] || die "\`nvm exec\` failed to run with a command including whitespace"
