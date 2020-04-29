#!/bin/sh

\. ../../common.sh

die () { echo "$@" ; exit 1; }

\. ../../../nvm.sh

nvm deactivate >/dev/null 2>&1

CURRENT="$(nvm current)"
[ "$CURRENT" = 'none' ] || [ "$CURRENT" = 'system' ] || die "nvm should be using none or system; got $CURRENT"

nvm_ls_current() {
  echo 'none'
}
node() {
  return 1
}
npm() {
  echo '1.2.3'
}

OUTPUT="$(nvm_install_latest_npm 2>&1 >/dev/null)"
EXIT_CODE="$(nvm_install_latest_npm >/dev/null 2>&1 ; echo $?)"

EXPECTED="Unable to obtain node version."
[ "${OUTPUT}" = "${EXPECTED}" ] || die "When node is unavailable, expected >${EXPECTED}<; got >${OUTPUT}"

node() {
  echo 'v4.5.6'
}
nvm_ls_current() {
  node --version
}
npm() {
  return 1
}
OUTPUT="$(nvm_install_latest_npm 2>&1 >/dev/null)"
EXIT_CODE="$(nvm_install_latest_npm >/dev/null 2>&1 ; echo $?)"

EXPECTED="Unable to obtain npm version."
[ "${OUTPUT}" = "${EXPECTED}" ] || die "When node is available and npm is unavailable, expected >${EXPECTED}<; got >${OUTPUT}"

node() {
  echo 'v4.5.6'
}
nvm_ls_current() {
  echo 'system'
}
npm() {
  return 1
}
OUTPUT="$(nvm_install_latest_npm 2>&1 >/dev/null)"
EXIT_CODE="$(nvm_install_latest_npm >/dev/null 2>&1 ; echo $?)"

EXPECTED="Unable to obtain npm version."
[ "${OUTPUT}" = "${EXPECTED}" ] || die "When node is system and npm is unavailable, expected >${EXPECTED}<; got >${OUTPUT}"
