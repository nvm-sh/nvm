#!/bin/sh

die () { echo "$@" ; exit 1; }

NVM_ENV=testing \. ../../install.sh

#nvm_do_install is available
type nvm_do_install > /dev/null 2>&1 || die 'nvm_do_install is not available'

FILE_PATH="$(pwd)/nvm_do_install"
echo $FILE_PATH
$(NVM_DIR="${FILE_PATH}" nvm_do_install >/dev/null 2>&1)
EXIT_CODE=$(echo $?)
[ "${EXIT_CODE}" = '1' ] || die "nvm_do_install should fail if NVM_DIR is a file: expected 1, got <${EXIT_CODE}>"

ACTUAL="$(NVM_DIR="${FILE_PATH}" nvm_do_install 2>&1)"
EXPECTED="File \"${FILE_PATH}\" has the same name as installation directory."
[ "${ACTUAL}" = "${EXPECTED}" ] || die "got <${ACTUAL}>, expected <${EXPECTED}>"
