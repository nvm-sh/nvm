#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate 2>&1 >/dev/null || die 'deactivate failed'

echo "foo" > .nvmrc

# running nvm use with .nvmrc should not print the version information
OUTPUT="$(nvm use 2>&1)"
EXIT_CODE=$?
EXPECTED_OUTPUT="Found '$PWD/.nvmrc' with version <foo>
N/A: version \"foo\" is not yet installed.

You need to run \`nvm install\` to install and use the node version specified in \`.nvmrc\`."
[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] || die "expected 'nvm use' with nvmrc to give $EXPECTED_OUTPUT, got $OUTPUT"
[ "_$EXIT_CODE" = "_3" ] || die "expected 'nvm use' with nvmrc to exit with 3, got $EXIT_CODE"

# --silent should not print anything
OUTPUT=$(nvm use --silent)
EXPECTED_OUTPUT=""

[ "_$OUTPUT" = "_$EXPECTED_OUTPUT" ] \
  || die "'nvm use --silent' output was not silenced to '$EXPECTED_OUTPUT'; got '$OUTPUT'"

rm .nvmrc
