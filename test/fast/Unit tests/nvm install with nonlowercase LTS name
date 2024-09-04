#!/bin/sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

REMOTE="${PWD}/mocks/nvm_ls_remote.txt"
REMOTE_IOJS="${PWD}/mocks/nvm_ls_remote_iojs.txt"

nvm_download() {
  if [ "$*" = "-L -s $(nvm_get_mirror node std)/index.tab -o -" ]; then
    cat "${REMOTE}"
  elif [ "$*" = "-L -s $(nvm_get_mirror iojs)/index.tab -o -" ]; then
    cat "${REMOTE_IOJS}"
  else
    nvm_err "unknown nvm_download call: $*"
    return 42
  fi
}

nvm_install_binary() {
  return 42
}
nvm_install_source() {
  return 42
}

ACTUAL="$(nvm install lts/ARGON 2>&1)"
EXIT_CODE=$?
[ $EXIT_CODE -eq 3 ] || die "Expected exit code of 3, got ${EXIT_CODE}"

EXPECTED="LTS names must be lowercase
Version with LTS filter 'ARGON' not found - try \`nvm ls-remote --lts=ARGON\` to browse available versions."

[ "${ACTUAL}" = "${EXPECTED}" ] || die "Expected >${EXPECTED}<, got >${ACTUAL}<"
