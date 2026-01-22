#!/bin/sh


die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

echo "0.10.7" > .nvmrc

[ "$(nvm run --version | tail -1)" = "v0.10.7" ] || die "\`nvm run\` failed to run with the .nvmrc version"

[ "$(nvm run --version | head -1)" = "Found '$PWD/.nvmrc' with version <0.10.7>" ] || die "\`nvm run\` failed to print out the \"found in .nvmrc\" message"


echo "foo" > .nvmrc

# running nvm run with .nvmrc should not print the version information when not installed
OUTPUT="$(nvm run --version 2>&1)"
EXIT_CODE=$?
EXPECTED_OUTPUT="Found '$PWD/.nvmrc' with version <foo>
N/A: version \"foo\" is not yet installed.

You need to run \`nvm install\` to install and use the node version specified in \`.nvmrc\`."
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "expected 'nvm use' with nvmrc to give $EXPECTED_OUTPUT, got $OUTPUT"
[ "_$EXIT_CODE" = "_1" ] || die "expected 'nvm use' with nvmrc to exit with 1, got $EXIT_CODE"
