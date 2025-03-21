#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm use 0.10
NPM_VERSION_TEN="$(npm --version)"
NODE_VERSION_TEN="$(node --version)"

nvm use 1.0.0 && [ "$(node --version)" = "v1.0.0" ] || die "\`nvm use\` failed!"
NPM_VERSION_ONE="$(npm --version)"

OUTPUT="$(nvm exec 0.10 npm --version)"
EXPECTED_OUTPUT="Running node ${NODE_VERSION_TEN} (npm v${NPM_VERSION_TEN})
${NPM_VERSION_TEN}"
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "\`nvm exec\` failed to report node preamble; expected '$EXPECTED_OUTPUT', got '$OUTPUT'"

OUTPUT="$(nvm exec --silent 0.10 npm --version | head -1)"
EXPECTED_OUTPUT="${NPM_VERSION_TEN}"
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "\`nvm exec --silent\` failed to node suppress preamble; expected '$EXPECTED_OUTPUT', got '$OUTPUT'"

OUTPUT="$(nvm exec 1 npm --version)"
EXPECTED_OUTPUT="Running io.js v1.0.0 (npm v${NPM_VERSION_ONE})
${NPM_VERSION_ONE}"
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "\`nvm exec\` failed to report io.js preamble; expected '$EXPECTED_OUTPUT', got '$OUTPUT'"

OUTPUT="$(nvm exec --silent 1 npm --version | head -1)"
EXPECTED_OUTPUT="${NPM_VERSION_ONE}"
[ "$OUTPUT" = "$EXPECTED_OUTPUT" ] || die "\`nvm exec --silent\` failed to suppress io.js preamble; expected '$EXPECTED_OUTPUT', got '$OUTPUT'"
