#!/bin/sh

cleanup() {
  unalias wget
  unset -f wget
  unset WGET_EXPECTED_INFO WGET_COMMAND_INFO
}

die() { echo "$@" ; cleanup ; exit 1; }

\. ../../../nvm.sh


# 1. test wget command
WGET_COMMAND_INFO="$(nvm_command_info wget)"
WGET_EXPECTED_INFO="$(which wget)"
[ "${WGET_COMMAND_INFO}" = "${WGET_EXPECTED_INFO}" ] || die "wget command info wrong(stage 1), expected: '${WGET_EXPECTED_INFO}', got '${WGET_COMMAND_INFO}'"

cleanup

# 2. test aliased wget

# enable expand_aliases/aliases to make alias work in interactive shell
if nvm_has shopt; then
  shopt -s expand_aliases
elif nvm_has setopt; then
  setopt aliases
fi

alias wget="wget -V"
WGET_COMMAND_INFO="$(nvm_command_info wget)"
WGET_EXPECTED_INFO="$(which wget) (wget -V)"
[ "${WGET_COMMAND_INFO}" = "${WGET_EXPECTED_INFO}" ] || die "wget command info wrong(stage 2), expected: '${WGET_EXPECTED_INFO}', got '${WGET_COMMAND_INFO}'"

cleanup

# 3. test wget function
wget() {
    echo "wget function"
}

WGET_COMMAND_INFO="$(nvm_command_info wget)"
WGET_EXPECTED_INFO="$(type wget)"
[ "${WGET_COMMAND_INFO}" = "${WGET_EXPECTED_INFO}" ] || die "wget command info wrong(stage 3), expected: '${WGET_EXPECTED_INFO}', got '${WGET_COMMAND_INFO}'"

cleanup

# 4. nvm_command_info() should not have standard error
OUTPUT="$(nvm_command_info ls   2>&1 >/dev/null)"
[ -z "${OUTPUT}" ] || die "\`nvm_command_info ls\`   expected no stderr; got >${OUTPUT}< (stage 4)"
OUTPUT="$(nvm_command_info rm   2>&1 >/dev/null)"
[ -z "${OUTPUT}" ] || die "\`nvm_command_info rm\`   expected no stderr; got >${OUTPUT}< (stage 4)"
OUTPUT="$(nvm_command_info git  2>&1 >/dev/null)"
[ -z "${OUTPUT}" ] || die "\`nvm_command_info git\`  expected no stderr; got >${OUTPUT}< (stage 4)"
OUTPUT="$(nvm_command_info grep 2>&1 >/dev/null)"
[ -z "${OUTPUT}" ] || die "\`nvm_command_info grep\` expected no stderr; got >${OUTPUT}< (stage 4)"

cleanup
