#!/bin/sh

set -eux

die () { echo "$@" ; exit 1; }

\. ../../nvm.sh

nvm unalias default >/dev/null 2>&1 || die 'unable to unalias default'

set +ex # needed for stderr
OUTPUT="$(nvm install --lts 0.12 2>&1)"
EXIT_CODE="$?"
set -ex
EXPECTED_OUTPUT="Version '0.12' (with LTS filter) not found - try \`nvm ls-remote --lts\` to browse available versions."
[ "${EXIT_CODE}" = 3 ] || die "\`nvm install --lts 0.12\` did not exit with 3, got >${EXIT_CODE}<"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm install --lts 3\` output >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

set +ex # needed for stderr
OUTPUT="$(nvm install --lts=argon 0.12 2>&1)"
EXIT_CODE="$?"
set -x
EXPECTED_OUTPUT="Version '0.12' (with LTS filter 'argon') not found - try \`nvm ls-remote --lts=argon\` to browse available versions."
[ "${EXIT_CODE}" = 3 ] || die "\`nvm install --lts=argon 0.12\` did not exit with 3, got >${EXIT_CODE}<"
[ "${OUTPUT}" = "${EXPECTED_OUTPUT}" ] || die "\`nvm install --lts=argon 0.12\` output >${OUTPUT}<, expected >${EXPECTED_OUTPUT}<"

nvm install --lts 4.2.2 || die 'nvm install --lts 4.2.2 failed'

[ "$(nvm current)" = "v4.2.2" ] || die "v4.2.2 not current, got $(nvm_current)"
